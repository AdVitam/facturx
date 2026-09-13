# frozen_string_literal: true

require 'facturx'

module FacturxSpec
  INTERNAL_CONSTANTS = %i[
    Attach Builders Coerce CoercionError Composers Format FormattingError Generate Group Model Pdf ProfileResolver
    Reader SourceReader Term TermDeclarations Terms Writer Xml
  ].freeze

  module_function

  def internal_constant(path)
    path.split('::').reduce(Facturx) { |namespace, name| namespace.const_get(name, false) }
  end

  Attach = internal_constant('Attach')
  Builders = internal_constant('Builders')
  Coerce = internal_constant('Coerce')
  CoercionError = internal_constant('CoercionError')
  Format = internal_constant('Format')
  FormattingError = internal_constant('FormattingError')
  Generate = internal_constant('Generate')
  Ghostscript = internal_constant('Composers::Ghostscript')
  GhostscriptLocator = internal_constant('Composers::Ghostscript::Locator')
  GhostscriptRunner = internal_constant('Composers::Ghostscript::Runner')
  GhostscriptVersionProbe = internal_constant('Composers::Ghostscript::VersionProbe')
  Group = internal_constant('Group')
  ModelImmutability = internal_constant('Model::Immutability')
  PdfComposer = internal_constant('Pdf::Composer')
  PdfExtractor = internal_constant('Pdf::Extractor')
  PdfInspector = internal_constant('Pdf::Inspector')
  PdfVerifier = internal_constant('Pdf::Verifier')
  ProfileResolver = internal_constant('ProfileResolver')
  Reader = internal_constant('Reader')
  SourceReader = internal_constant('SourceReader')
  Term = internal_constant('Term')
  Terms = internal_constant('Terms')
  ValidationTracker = internal_constant('Validation::Tracker')
  Writer = internal_constant('Writer')
  WriterContext = internal_constant('Writer::Context')
  WriterStage = internal_constant('Writer::Stage')
  XmlParser = internal_constant('Xml::Parser')
  XmlProfileDetector = internal_constant('Xml::ProfileDetector')
  XmlSchemaRegistry = internal_constant('Xml::SchemaRegistry')
  XmlSchemaValidator = internal_constant('Xml::SchemaValidator')
  XmlValidator = internal_constant('Xml::Validator')
  XmlVerifier = internal_constant('Xml::Verifier')
end

FacturxSpec::INTERNAL_CONSTANTS.each { |name| Facturx.public_constant(name) }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.order = :random
end
