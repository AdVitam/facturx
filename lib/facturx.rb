# frozen_string_literal: true

require 'facturx/version'
require 'facturx/error'
require 'facturx/embedding'
require 'facturx/profile'
require 'facturx/profiles'
require 'facturx/term'
require 'facturx/group'
require 'facturx/terms'
require 'facturx/model'
require 'facturx/diagnostic'
require 'facturx/reading'
require 'facturx/coerce'
require 'facturx/xml/verifier'
require 'facturx/pdf/document'
require 'facturx/pdf/inspector'
require 'facturx/pdf/extractor'
require 'facturx/pdf/verifier'
require 'facturx/composers/ghostscript'
require 'facturx/attach'
require 'facturx/reader'

module Facturx
  DEFAULT_ATTACHER = Attach.new
  DEFAULT_READER = Reader.new
  private_constant :DEFAULT_ATTACHER
  private_constant :DEFAULT_READER

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

    def read(source, on_unknown_profile: :fallback)
      DEFAULT_READER.call(source, on_unknown_profile:)
    end
  end
end
