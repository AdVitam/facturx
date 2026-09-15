# frozen_string_literal: true

require 'eu_einvoice/xml/schema_validator'

module EuEinvoice
  module Xml
    class ConformanceValidator
      def initialize(schema_validator:, schematron_validator: nil)
        @schema_validator = schema_validator
        @schematron_validator = schematron_validator
      end

      def call(document:, profile:)
        @schema_validator.call(document:, profile:)
        @schematron_validator ? @schematron_validator.call(document:, profile:) : []
      end

      def steps = @schematron_validator ? %i[xsd schematron] : [:xsd]
    end
  end
end
