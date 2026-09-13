# frozen_string_literal: true

require_relative 'xml/verifier'
require_relative 'pdf/composer'

module Facturx
  class Attach
    def initialize(xml_verifier: Xml::Verifier.new, pdf_composer: Pdf::Composer.new)
      @xml_verifier = xml_verifier
      @pdf_composer = pdf_composer
    end

    def call(pdf:, xml:)
      profile = @xml_verifier.call(xml:)
      @pdf_composer.call(pdf:, xml:, profile:)
    end
  end
end
