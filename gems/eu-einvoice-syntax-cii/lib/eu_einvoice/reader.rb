# frozen_string_literal: true

require 'eu_einvoice/diagnostic'
require 'eu_einvoice/document'
require 'eu_einvoice/coerce'
require 'eu_einvoice/error'
require 'eu_einvoice/reading'
require 'eu_einvoice/source_reader'
require 'eu_einvoice/terms'
require 'eu_einvoice/xml/parser'
require 'eu_einvoice/xml/namespaces'
require 'eu_einvoice/xml/profile_detector'

module EuEinvoice
  class Reader
    CII_NAMESPACE = Xml::Namespaces::CII
    NAMESPACES = Xml::Namespaces::MAP
    UNKNOWN_PROFILE_POLICIES = %i[fallback raise].freeze

    def initialize(profile_resolver:, parser: Xml::Parser.new, registry: Terms, coercer: Coerce)
      @parser = parser
      @source_reader = SourceReader.new
      @profile_resolver = profile_resolver
      @registry = registry
      @coercer = coercer
    end

    def call(source, on_unknown_profile: :fallback)
      validate_unknown_profile_policy!(on_unknown_profile)
      input = @source_reader.call(source)
      parsed = parse(input.xml)
      diagnostics = []
      profile = resolve_profile(parsed, on_unknown_profile, diagnostics)
      document = map(parsed, profile, diagnostics)

      Reading.new(document:, profile:, diagnostics:, source: input.xml, source_type: input.source_type)
    end

    private

    def validate_unknown_profile_policy!(policy)
      return if UNKNOWN_PROFILE_POLICIES.include?(policy)

      raise ArgumentError, "on_unknown_profile must be one of #{UNKNOWN_PROFILE_POLICIES.inspect}"
    end

    def cross_industry_invoice(document)
      root = document.root
      return root if root&.name == 'CrossIndustryInvoice' && root.namespace&.href == CII_NAMESPACE

      raise InvalidXmlError.new('XML is not a CrossIndustryInvoice', reason: :unsupported_document)
    end

    def parse(xml)
      document = @parser.call(xml:)
      cross_industry_invoice(document)
      document
    end

    def map(parsed, profile, diagnostics)
      mapper = SemanticMapper.new(
        document: parsed, profile:, registry: @registry, coercer: @coercer, diagnostics:
      )
      document = mapper.call
      mapper.add_unmapped(parsed.root)
      document
    end

    def resolve_profile(document, policy, diagnostics)
      @profile_resolver.call(document:)
    rescue UnknownProfileError => e
      raise if policy == :raise

      diagnostics << profile_diagnostic(e)
      nil
    end

    def profile_diagnostic(error)
      guideline_urn = error.details[:guideline_urn]
      Diagnostic.new(
        code: guideline_urn.nil? || guideline_urn.empty? ? :missing_profile : :unknown_profile,
        term_id: 'BT-24', path: Xml::ProfileDetector::GUIDELINE_XPATH,
        message: error.message, details: error.details
      )
    end
  end
end

require 'eu_einvoice/reader/term_reader'
require 'eu_einvoice/reader/semantic_mapper'
