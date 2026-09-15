# frozen_string_literal: true

require 'eu_einvoice/validation_context'
require 'eu_einvoice/france/adapter_reporting'
require 'eu_einvoice/france/pipelines'

module EuEinvoice
  module France
    class Adapter
      include AdapterReporting

      def initialize(specifications:, validation:, limits: ResourceLimits.new, schema_root: Manifest::ROOT,
                     rules_root: nil)
        raise ArgumentError, 'Unknown validation coverage' unless %i[structural full].include?(validation)

        @specifications = specifications
        @validation = validation
        @parser = Xml::Parser.new(limits:)
        @pipelines = Pipelines.new(specifications:, validation:, limits:, schema_root:, rules_root:)
      end

      def prepare(xml:)
        Validation::Context.new(source: xml, representation: @parser.call(xml:), syntax: :cii)
      end

      def detect(xml: nil, context: nil)
        candidates((context || prepare(xml:)).representation)
      end

      def can_read?(xml: nil, context: nil)
        root = (context || prepare(xml:)).representation.root
        root&.name == 'CrossIndustryInvoice' && root.namespace&.href == Xml::Namespaces::CII
      end

      def read(source = nil, specification: nil, on_unknown_profile: :fallback, context: nil)
        context ||= prepare(xml: source)
        source = context.source
        parsed = context.representation
        specification = select_specification(parsed, specification)
        detector = Xml::ProfileDetector.new(profiles: selected_profiles(specification))
        reader = Reader.new(parser: ParsedInput.new(parsed), profile_resolver: detector)
        reader.call(source, on_unknown_profile:).with(specification:)
      end

      def compile(document:, specification:)
        check_specification!(specification)
        check_semantic_version!(document, specification)
        result = @pipelines.fetch(specification).writer.compile(document:, profile: specification.profile)
        result.with(report: annotate(result.report, specification))
      rescue InvalidDocumentError => e
        raise_compilation_error(e, specification)
      end

      def validate_document(document:, specification:)
        check_specification!(specification)
        return version_report(document, specification) if document.semantic_version != specification.semantic_version

        annotate(@pipelines.fetch(specification).writer.validate(document:, profile: specification.profile),
                 specification)
      end

      def validate_xml(xml: nil, specification: nil, context: nil)
        context ||= prepare(xml:)
        specification = select_specification(context.representation, specification)
        raise UnknownProfileError, 'Document guideline is unresolved' unless specification

        annotate(xml_validator(context, specification).call(xml: context.source), specification)
      rescue UnknownProfileError => e
        annotate(Xml::ReportBuilder.profile(e), specification)
      rescue InvalidXmlError => e
        annotate(Xml::ReportBuilder.syntax(e), specification)
      end

      private

      ParsedInput = Data.define(:document) do
        def call(**) = document
      end

      def xml_validator(context, specification)
        detector = Xml::ProfileDetector.new(profiles: selected_profiles(specification))
        Xml::Validator.new(parser: ParsedInput.new(context.representation), profile_detector: detector,
                           conformance_validator: @pipelines.fetch(specification).conformance)
      end

      def candidates(parsed)
        urn = parsed.at_xpath(Xml::ProfileDetector::GUIDELINE_XPATH, Xml::Namespaces::MAP)&.text
        @specifications.select { |specification| specification.guideline_urn == urn }
      end

      def select_specification(parsed, requested)
        available = candidates(parsed)
        if requested
          check_specification!(requested)
          return requested if available.include?(requested)

          raise UnknownProfileError.new('Document guideline conflicts with the requested specification',
                                        specification: requested.id)
        end
        return available.first if available.size <= 1

        raise AmbiguousSpecificationError.new('Several specifications match the document',
                                              candidates: available.map(&:id))
      end

      def check_specification!(specification)
        return if @specifications.include?(specification)

        raise UnsupportedProfileError.new('Specification does not belong to this pack',
                                          specification: specification&.id)
      end

      def selected_profiles(specification)
        specification ? [specification.profile] : @specifications.map(&:profile).uniq
      end
    end
  end
end
