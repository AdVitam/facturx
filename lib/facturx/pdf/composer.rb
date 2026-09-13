# frozen_string_literal: true

require_relative 'inspector'
require_relative 'extractor'
require_relative 'verifier'
require_relative '../composers/ghostscript'

module Facturx
  module Pdf
    class Composer
      def initialize(
        inspector: Inspector.new,
        backend: Composers::Ghostscript.new,
        extractor: Extractor.new,
        verifier: Verifier.new
      )
        @inspector = inspector
        @backend = backend
        @extractor = extractor
        @verifier = verifier
      end

      def call(pdf:, xml:, profile:)
        inspection = @inspector.call(pdf)
        output = @backend.call(pdf:, xml:, profile:)
        result = @extractor.call(output)
        @verifier.call(result:, expected_xml: xml, expected_page_count: inspection.page_count, profile:)
        output
      end
    end
  end
end
