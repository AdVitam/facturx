# frozen_string_literal: true

require 'pdf/reader'
require 'stringio'

require 'eu_einvoice/error'
require 'eu_einvoice/resource_limits'
require 'eu_einvoice/source'

module EuEinvoice
  module Pdf
    class Document
      attr_reader :catalog, :reader, :limits

      class << self
        def open(pdf, reject_signed: false, limits: ResourceLimits.new)
          parse(pdf, reject_signed:, limits:)
        rescue InvalidPdfError
          raise
        rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError,
               ArgumentError, IOError => e
          raise invalid_error(e)
        end

        private

        def parse(pdf, reject_signed:, limits:)
          pdf = Source.read(pdf, limit: limits.pdf_bytes)
          reader = build_reader(pdf)
          raise encrypted_error if reader.objects.encrypted?

          limits.check!(:pdf_objects, reader.objects.size)
          document = new(reader, limits:)
          document.validate!
          raise signed_error if reject_signed && document.signed?

          document
        end

        def build_reader(pdf)
          PDF::Reader.new(StringIO.new(pdf.b))
        rescue PDF::Reader::EncryptedPDFError
          raise encrypted_error
        end

        def encrypted_error
          ProtectedPdfError.new('Encrypted PDFs are not supported', protection: :encryption)
        end

        def signed_error
          ProtectedPdfError.new('Signed PDFs are not supported', protection: :signature)
        end

        def invalid_error(error)
          InvalidPdfError.new('Invalid PDF', reason: :malformed, cause: error.class.name)
        end
      end

      def initialize(reader, limits: ResourceLimits.new)
        @reader = reader
        @limits = limits
        @catalog = reader.objects.deref_hash(reader.objects.trailer[:Root])
      end

      def objects
        reader.objects
      end

      def page_count
        @page_count ||= count_pages(catalog[:Pages], {}, 0)
      end

      def metadata
        stream = objects.deref_stream(catalog[:Metadata])
        return unless stream

        bytes = stream.unfiltered_data
        limits.check!(:xml_bytes, bytes.bytesize)
        bytes.b
      rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError
        nil
      end

      def validate!
        raise PDF::Reader::MalformedPDFError, 'PDF catalog is missing' unless catalog

        page_count
      end

      def signed?
        return true if catalog.key?(:Perms)

        objects.any? do |_reference, object|
          dictionary = object.is_a?(PDF::Reader::Stream) ? object.hash : object
          signature_dictionary?(dictionary)
        end
      end

      private

      def count_pages(reference, visited, depth)
        node = page_node(reference, visited, depth)
        return 1 if node[:Type] == :Page

        children = objects.deref_array(node[:Kids])
        raise InvalidPdfError.new('Missing page tree children', reason: :invalid_page_tree) unless children

        children.reduce(0) do |total, child|
          count = total + count_pages(child, visited, depth + 1)
          limits.check!(:pdf_pages, count)
          count
        end
      end

      def page_node(reference, visited, depth)
        limits.check!(:tree_depth, depth + 1)
        key = reference_key(reference)
        raise InvalidPdfError.new('Repeated page tree node', reason: :invalid_page_tree) if visited.key?(key)

        visited[key] = true
        limits.check!(:pdf_objects, visited.size)
        node = objects.deref_hash(reference)
        raise InvalidPdfError.new('Missing page tree node', reason: :invalid_page_tree) unless node

        node
      end

      def reference_key(reference)
        reference.is_a?(PDF::Reader::Reference) ? [reference.id, reference.gen] : reference.object_id
      end

      def signature_dictionary?(dictionary)
        return false unless dictionary.is_a?(Hash)

        dictionary[:Type] == :Sig || (dictionary.key?(:ByteRange) && dictionary.key?(:Contents))
      end
    end
  end
end
