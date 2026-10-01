# frozen_string_literal: true

module EuEinvoice
  module Pdf
    Embedding = Data.define(:filename, :relationship, :accepted_relationships, :document_type, :version,
                            :xmp_namespace) do
      def initialize(**attributes)
        validate_filename!(attributes.fetch(:filename))
        relationship = attributes.fetch(:relationship).to_sym
        accepted = attributes.fetch(:accepted_relationships) { [relationship] }.map(&:to_sym).freeze
        super(**immutable_fields(attributes), relationship:, accepted_relationships: accepted)
      end

      private

      def immutable_fields(attributes)
        attributes.merge(%i[filename document_type version xmp_namespace].to_h do |key|
          [key, immutable_string(attributes.fetch(key))]
        end)
      end

      def validate_filename!(filename)
        return if filename.is_a?(String) && filename.match?(/\A[a-zA-Z0-9_.-]+\z/) && !%w[. ..].include?(filename)

        raise ArgumentError, 'Embedding filename must be a plain filename'
      end

      def immutable_string(value)
        raise ArgumentError, 'Embedding metadata must be a String' unless value.is_a?(String)

        value.dup.freeze
      end
    end
  end
end
