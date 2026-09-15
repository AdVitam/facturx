# frozen_string_literal: true

require 'eu_einvoice/pdf/inspector'
require 'eu_einvoice/pdf/extractor'
require 'eu_einvoice/pdf/verifier'
require 'eu_einvoice/composers/ghostscript'

module EuEinvoice
  module Pdf
    class Composer
      Adapters = Data.define(:inspector, :backend, :extractor, :verifier)

      def initialize(embedding:, limits: ResourceLimits.new, backend: nil, adapters: nil)
        raise ArgumentError, 'backend and adapters are mutually exclusive' if backend && adapters

        @limits = limits
        @adapters = adapters || default_adapters(embedding, backend)
      end

      def call(pdf:, xml:, profile:)
        pdf = Source.read(pdf, limit: @limits.pdf_bytes)
        xml = Source.read(xml, limit: @limits.xml_bytes)
        inspection = @adapters.inspector.call(pdf)
        output = @adapters.backend.call(pdf:, xml:, profile:)
        @limits.check!(:output_pdf_bytes, output.bytesize)
        result = @adapters.extractor.call(output)
        @adapters.verifier.call(result:, expected_xml: xml, expected_page_count: inspection.page_count, profile:)
        output
      end

      private

      def default_adapters(embedding, backend)
        extraction_limits = ResourceLimits.new(**@limits.to_h, pdf_bytes: @limits.output_pdf_bytes)
        Adapters.new(inspector: Inspector.new(limits: @limits),
                     backend: backend || Composers::Ghostscript.new(embedding:, limits: @limits),
                     extractor: Extractor.new(embedding:, limits: extraction_limits),
                     verifier: Verifier.new(embedding:, limits: @limits))
      end
    end
  end
end
