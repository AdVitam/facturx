# frozen_string_literal: true

require 'eu_einvoice/pdf/document'
require 'eu_einvoice/pdf/isolated_operation'

module EuEinvoice
  module Pdf
    class Inspector
      Result = Data.define(:page_count)

      def initialize(limits: ResourceLimits.new, isolate: true)
        @limits = limits
        @isolate = isolate
      end

      def call(pdf)
        return Result.new(**IsolatedOperation.new(limits: @limits).call(:inspect, pdf)) if @isolate

        document = Document.open(pdf, reject_signed: true, limits: @limits)

        Result.new(page_count: document.page_count)
      rescue InvalidSourceError
        raise InvalidPdfError.new('PDF input is invalid', reason: :invalid_input)
      end
    end
  end
end
