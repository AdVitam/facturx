# frozen_string_literal: true

require_relative 'document'

module Facturx
  module Pdf
    class Inspector
      Result = Data.define(:page_count)

      def call(pdf)
        document = Document.open(pdf)
        raise ProtectedPdfError.new('Signed PDFs are not supported', protection: :signature) if document.signed?

        Result.new(page_count: document.page_count)
      end
    end
  end
end
