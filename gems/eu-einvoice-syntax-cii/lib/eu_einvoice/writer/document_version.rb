# frozen_string_literal: true

module EuEinvoice
  class Writer
    module DocumentVersion
      private

      def check_semantic_version(document)
        return if document.semantic_version == Semantic::En16931::VERSION

        add(:semantic_version_mismatch, 'Document semantic version is not supported by this binding',
            details: { expected: Semantic::En16931::VERSION, actual: document.semantic_version })
      end
    end
  end
end
