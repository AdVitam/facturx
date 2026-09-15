# frozen_string_literal: true

module EuEinvoice
  module France
    class Pipelines
      Pipeline = Data.define(:writer, :conformance, :schematron)

      def initialize(specifications:, validation:, limits:, schema_root:, rules_root:)
        rules = validation == :full ? rule_validators(specifications, limits, rules_root) : {}
        @pipelines = specifications.to_h do |specification|
          registry = Xml::SchemaRegistry.new(specification:, root: schema_root)
          schema = Xml::SchemaValidator.new(registry:)
          schematron = rules[specification.fingerprint]
          conformance = Xml::ConformanceValidator.new(schema_validator: schema, schematron_validator: schematron)
          [specification.fingerprint, Pipeline.new(writer: Writer.new(conformance_validator: conformance),
                                                   conformance:, schematron:)]
        end.freeze
        freeze
      end

      def fetch(specification)
        @pipelines.fetch(specification.fingerprint)
      end

      private

      def rule_validators(specifications, limits, root)
        require 'eu_einvoice/validation/fr'
        options = root ? { root: } : {}
        Validation::France.validators(specifications:, limits:, **options)
      rescue LoadError => e
        raise Error.new('Complete validation requires eu-einvoice-validation-fr', reason: :missing_validation_pack,
                                                                                  dependency: e.path)
      end
    end
  end
end
