# frozen_string_literal: true

require_relative '../schematron_adapter'
require_relative 'schema_validator'

module Facturx
  module Xml
    class ConformanceValidator
      def initialize(schema_validator: SchemaValidator.new, schematron_validator: SchematronAdapter)
        @schema_validator = schema_validator
        @schematron_validator = schematron_validator
      end

      def call(document:, profile:)
        @schema_validator.call(document:, profile:)
        @schematron_validator.call(document:, profile:)
      end
    end
  end
end
