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
require 'facturx/validation'
require 'facturx/xml/validator'
require 'facturx/xml/verifier'
require 'facturx/pdf/document'
require 'facturx/pdf/inspector'
require 'facturx/pdf/extractor'
require 'facturx/pdf/verifier'
require 'facturx/pdf/composer'
require 'facturx/composers/ghostscript'
require 'facturx/attach'
require 'facturx/reader'
require 'facturx/writer'
require 'facturx/generate'

module Facturx
  DEFAULT_XML_VALIDATOR = Xml::Validator.new
  DEFAULT_PDF_COMPOSER = Pdf::Composer.new
  DEFAULT_ATTACHER = Attach.new(pdf_composer: DEFAULT_PDF_COMPOSER)
  DEFAULT_READER = Reader.new
  DEFAULT_PROFILE_RESOLVER = ProfileResolver.new
  DEFAULT_WRITER = Writer.new
  DEFAULT_GENERATOR = Generate.new(writer: DEFAULT_WRITER, pdf_composer: DEFAULT_PDF_COMPOSER,
                                   profile_resolver: DEFAULT_PROFILE_RESOLVER)
  private_constant :DEFAULT_XML_VALIDATOR
  private_constant :DEFAULT_PDF_COMPOSER
  private_constant :DEFAULT_ATTACHER
  private_constant :DEFAULT_READER
  private_constant :DEFAULT_PROFILE_RESOLVER
  private_constant :DEFAULT_WRITER
  private_constant :DEFAULT_GENERATOR

  class << self
    def validate_xml(xml:)
      DEFAULT_XML_VALIDATOR.call(xml:)
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

    def build_xml(document:, profile:)
      canonical_profile = DEFAULT_PROFILE_RESOLVER.call(profile)
      DEFAULT_WRITER.call(document:, profile: canonical_profile)
    end

    def generate(pdf:, document:, profile:)
      DEFAULT_GENERATOR.call(pdf:, document:, profile:)
    end
  end

  private_constant :Attach, :Builders, :Coerce, :CoercionError, :Composers, :Format, :FormattingError,
                   :Generate, :Group, :Model, :Pdf, :ProfileResolver, :Reader, :SourceReader, :Term,
                   :TermDeclarations, :Terms, :Writer, :Xml
end
