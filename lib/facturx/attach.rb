# frozen_string_literal: true

require_relative 'xml/verifier'
require_relative 'pdf/inspector'
require_relative 'pdf/extractor'
require_relative 'pdf/verifier'
require_relative 'composers/ghostscript'

module Facturx
  class Attach
    def initialize(
      xml_verifier: Xml::Verifier.new,
      pdf_inspector: Pdf::Inspector.new,
      composer: Composers::Ghostscript.new,
      extractor: Pdf::Extractor.new,
      pdf_verifier: Pdf::Verifier.new
    )
      @xml_verifier = xml_verifier
      @pdf_inspector = pdf_inspector
      @composer = composer
      @extractor = extractor
      @pdf_verifier = pdf_verifier
    end

    def call(pdf:, xml:)
      profile = @xml_verifier.call(xml:)
      inspection = @pdf_inspector.call(pdf)
      output = @composer.call(pdf:, xml:, profile:)
      result = @extractor.call(output)
      @pdf_verifier.call(result:, expected_xml: xml, expected_page_count: inspection.page_count, profile:)
      output
    end
  end
end
