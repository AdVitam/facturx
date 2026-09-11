# frozen_string_literal: true

require 'pdf/reader'
require 'stringio'

require_relative '../error'

module Facturx
  module Pdf
    class Document
      attr_reader :catalog, :reader

      class << self
        def open(pdf)
          parse(pdf)
        rescue InvalidPdfError
          raise
        rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError,
               ArgumentError, IOError => e
          raise invalid_error(e)
        end

        private

        def parse(pdf)
          raise InvalidPdfError.new('PDF must be a byte string', reason: :invalid_input) unless pdf.is_a?(String)

          reader = build_reader(pdf)
          raise encrypted_error if reader.objects.encrypted?

          new(reader).tap(&:validate!)
        end

        def build_reader(pdf)
          PDF::Reader.new(StringIO.new(pdf.b))
        rescue PDF::Reader::EncryptedPDFError
          raise encrypted_error
        end

        def encrypted_error
          ProtectedPdfError.new('Encrypted PDFs are not supported', protection: :encryption)
        end

        def invalid_error(error)
          InvalidPdfError.new('Invalid PDF', reason: :malformed, cause: error.class.name)
        end
      end

      def initialize(reader)
        @reader = reader
        @catalog = reader.objects.deref_hash(reader.objects.trailer[:Root])
      end

      def objects
        reader.objects
      end

      def page_count
        reader.page_count
      end

      def metadata
        stream = objects.deref_stream(catalog[:Metadata])
        return unless stream

        stream.unfiltered_data.dup.force_encoding(Encoding::BINARY)
      rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError
        nil
      end

      def validate!
        raise PDF::Reader::MalformedPDFError, 'PDF catalog is missing' unless catalog

        reader.page_count
      end

      def signed?
        return true if catalog.key?(:Perms)

        objects.any? do |_reference, object|
          dictionary = object.is_a?(PDF::Reader::Stream) ? object.hash : object
          signature_dictionary?(dictionary)
        end
      end

      private

      def signature_dictionary?(dictionary)
        return false unless dictionary.is_a?(Hash)

        dictionary[:Type] == :Sig || (dictionary.key?(:ByteRange) && dictionary.key?(:Contents))
      end
    end
  end
end
