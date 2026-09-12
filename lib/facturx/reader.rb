# frozen_string_literal: true

require_relative 'diagnostic'
require_relative 'document'
require_relative 'coerce'
require_relative 'error'
require_relative 'profiles'
require_relative 'reading'
require_relative 'source_reader'
require_relative 'terms'
require_relative 'xml/parser'
require_relative 'xml/profile_detector'

module Facturx
  class Reader
    CII_NAMESPACE = 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100'
    NAMESPACES = {
      'qdt' => 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100',
      'ram' => 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100',
      'rsm' => CII_NAMESPACE,
      'udt' => 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100'
    }.freeze
    UNKNOWN_PROFILE_POLICIES = %i[fallback raise].freeze

    COLLABORATORS = %i[profile_resolver registry coercer profiles].freeze

    def initialize(parser: Xml::Parser.new, extractor: Pdf::Extractor.new, **collaborators)
      unknown = collaborators.keys - COLLABORATORS
      raise ArgumentError, "Unknown collaborators: #{unknown.join(', ')}" unless unknown.empty?

      @parser = parser
      @source_reader = SourceReader.new(extractor:)
      @profile_resolver = collaborators.fetch(:profile_resolver) { Xml::ProfileDetector.new }
      @registry = collaborators.fetch(:registry, Terms)
      @coercer = collaborators.fetch(:coercer, Coerce)
      @profiles = collaborators.fetch(:profiles, Profiles)
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
      @profiles.fetch(:extended)
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

require_relative 'reader/term_reader'
require_relative 'reader/semantic_mapper'
