# frozen_string_literal: true

require_relative 'document'

module Facturx
  module Pdf
    class Inspector
      Result = Data.define(:page_count)

      def call(pdf)
        document = Document.open(pdf, reject_signed: true)

        Result.new(page_count: document.page_count)
      end
    end
  end
end
