# frozen_string_literal: true

require 'facturx/version'
require 'facturx/error'
require 'facturx/embedding'
require 'facturx/profile'
require 'facturx/profiles'
require 'facturx/xml/verifier'
require 'facturx/pdf/document'
require 'facturx/pdf/inspector'
require 'facturx/pdf/extractor'
require 'facturx/pdf/verifier'
require 'facturx/composers/ghostscript'
require 'facturx/attach'

module Facturx
  DEFAULT_ATTACHER = Attach.new
  private_constant :DEFAULT_ATTACHER

  class << self
    def verify_xml(xml:)
      Xml::Verifier.new.call(xml:)
      true
    end

    def attach(pdf:, xml:)
      DEFAULT_ATTACHER.call(pdf:, xml:)
    end

    def extract_xml(pdf:)
      Pdf::Extractor.new.call(pdf).xml
    end
  end
end
