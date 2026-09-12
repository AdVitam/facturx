# frozen_string_literal: true

require 'facturx/version'
require 'facturx/error'
require 'facturx/embedding'
require 'facturx/profile'
require 'facturx/profiles'
require 'facturx/profile_resolver'
require 'facturx/term'
require 'facturx/group'
require 'facturx/terms'
require 'facturx/model'
require 'facturx/document'
require 'facturx/builders'
require 'facturx/diagnostic'
require 'facturx/reading'
require 'facturx/coerce'
require 'facturx/format'
require 'facturx/conformance'
require 'facturx/xml/verifier'
require 'facturx/pdf/document'
require 'facturx/pdf/inspector'
require 'facturx/pdf/extractor'
require 'facturx/pdf/verifier'
require 'facturx/composers/ghostscript'
require 'facturx/attach'
require 'facturx/reader'
require 'facturx/writer'
require 'facturx/generate'

module Facturx
  DEFAULT_ATTACHER = Attach.new
  DEFAULT_READER = Reader.new
  DEFAULT_PROFILE_RESOLVER = ProfileResolver.new
  DEFAULT_WRITER = Writer.new
  DEFAULT_GENERATOR = Generate.new(writer: DEFAULT_WRITER, attacher: DEFAULT_ATTACHER,
                                   profile_resolver: DEFAULT_PROFILE_RESOLVER)
  private_constant :DEFAULT_ATTACHER
  private_constant :DEFAULT_READER
  private_constant :DEFAULT_PROFILE_RESOLVER
  private_constant :DEFAULT_WRITER
  private_constant :DEFAULT_GENERATOR

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

    def validate_document(document:, profile:)
      canonical_profile = DEFAULT_PROFILE_RESOLVER.call(profile)
      DEFAULT_WRITER.validate(document:, profile: canonical_profile)
    end

    def build_xml(document, profile:)
      canonical_profile = DEFAULT_PROFILE_RESOLVER.call(profile)
      DEFAULT_WRITER.call(document:, profile: canonical_profile)
    end

    def generate(pdf:, document:, profile:)
      DEFAULT_GENERATOR.call(pdf:, document:, profile:)
    end
  end
end
