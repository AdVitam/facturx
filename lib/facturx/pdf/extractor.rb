# frozen_string_literal: true

require_relative 'document'
require_relative 'name_tree'
require_relative '../embedding'

module Facturx
  module Pdf
    class Extractor
      ACCEPTED_RELATIONSHIPS = %i[Alternative Data].freeze
      Result = Data.define(:xml, :filename, :relationship, :metadata, :page_count)
      Candidate = Data.define(:file_specification, :names)

      def call(pdf)
        document = Document.open(pdf)
        build_result(document, select_candidate(document))
      rescue InvalidPdfError, ExtractionError
        raise
      rescue PDF::Reader::MalformedPDFError => e
        raise InvalidPdfError.new('Invalid PDF', reason: :malformed, cause: e.class.name)
      rescue PDF::Reader::UnsupportedFeatureError => e
        raise ExtractionError.new('Unable to decode the Factur-X attachment', reason: :unsupported_stream,
                                                                              cause: e.class.name)
      end

      private

      def build_result(document, candidate)
        file_specification = candidate.file_specification
        validate_names!(candidate.names)
        validate_relationship!(file_specification)

        Result.new(xml: embedded_xml(document, file_specification),
                   filename: FACTURX_EMBEDDING.filename,
                   relationship: file_specification[:AFRelationship],
                   metadata: document.metadata,
                   page_count: document.page_count)
      end

      def select_candidate(document)
        matches = matching_candidates(associated_file_candidates(document))
        matches = matching_candidates(name_tree_candidates(document)) if matches.empty?

        raise ExtractionError.new('Factur-X XML attachment is missing', reason: :missing_attachment) if matches.empty?
        if matches.length > 1
          raise ExtractionError.new('Factur-X XML attachment is ambiguous', reason: :ambiguous_attachment,
                                                                            count: matches.length)
        end

        matches.first
      end

      def matching_candidates(candidates)
        candidates
          .select { |candidate| candidate.names.include?(FACTURX_EMBEDDING.filename) }
          .uniq { |candidate| candidate.file_specification.object_id }
      end

      def associated_file_candidates(document)
        references = document.objects.deref_array(document.catalog[:AF]) || []
        references.filter_map { |reference| candidate_from(document, reference) }
      end

      def name_tree_candidates(document)
        NameTree.new(document).call.filter_map do |tree_name, file_specification|
          candidate_from(document, file_specification, tree_name)
        end
      end

      def candidate_from(document, reference, tree_name = nil)
        file_specification = document.objects.deref_hash(reference)
        return unless file_specification

        names = [tree_name, file_specification[:F], file_specification[:UF]]
                .compact
                .map { |name| normalize_name(document, name) }
        Candidate.new(file_specification:, names:)
      end

      def normalize_name(document, name)
        value = document.objects.deref(name)
        return value unless value.is_a?(String)
        return value unless value.byteslice(0, 2) == "\xFE\xFF".b

        value.byteslice(2..).force_encoding(Encoding::UTF_16BE).encode(Encoding::UTF_8)
      rescue EncodingError
        raise ExtractionError.new('Factur-X attachment has an invalid filename encoding',
                                  reason: :invalid_filename_encoding)
      end

      def validate_names!(names)
        return if names.all?(FACTURX_EMBEDDING.filename)

        raise ExtractionError.new('Factur-X attachment has an invalid filename', reason: :invalid_filename,
                                                                                 filenames: names)
      end

      def validate_relationship!(file_specification)
        return if ACCEPTED_RELATIONSHIPS.include?(file_specification[:AFRelationship])

        raise ExtractionError.new('Factur-X attachment uses an unsupported relationship',
                                  reason: :invalid_relationship,
                                  relationship: file_specification[:AFRelationship])
      end

      def embedded_xml(document, file_specification)
        embedded_files = document.objects.deref_hash(file_specification[:EF])
        stream_reference = embedded_files && (embedded_files[:UF] || embedded_files[:F])
        stream = document.objects.deref(stream_reference)
        unless stream.is_a?(PDF::Reader::Stream)
          raise ExtractionError.new('Factur-X attachment stream is missing', reason: :missing_stream)
        end

        stream.unfiltered_data.dup.force_encoding(Encoding::BINARY)
      end
    end
  end
end
