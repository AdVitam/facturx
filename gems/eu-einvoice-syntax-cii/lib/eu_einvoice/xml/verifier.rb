# frozen_string_literal: true

require 'eu_einvoice/xml/validator'

module EuEinvoice
  module Xml
    class Verifier
      ERROR_CLASSES = {
        syntax: InvalidXmlError,
        profile: UnknownProfileError,
        xsd: XsdValidationError,
        schematron: SchematronValidationError
      }.freeze
      private_constant :ERROR_CLASSES

      def initialize(validator:)
        @validator = validator
      end

      def call(xml:)
        report = @validator.call(xml:)
        return report.profile if report.valid?

        issue = report.issues.find { |candidate| candidate.severity == :error }
        error_class = ERROR_CLASSES.fetch(issue.layer)
        raise error_class.new(issue.message, report:, issues: report.issues)
      end
    end
  end
end
