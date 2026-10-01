# frozen_string_literal: true

require 'eu_einvoice/validation'
require 'eu_einvoice/xml/parser'
require 'eu_einvoice/xml/profile_detector'
require 'eu_einvoice/xml/report_builder'
require 'eu_einvoice/xml/conformance_validator'

module EuEinvoice
  module Xml
    class Validator
      def initialize(
        profile_detector:, conformance_validator:, parser: Parser.new
      )
        @parser = parser
        @profile_detector = profile_detector
        @conformance_validator = conformance_validator
      end

      def call(xml:)
        document = @parser.call(xml:)
        profile = @profile_detector.call(document:)
        issues = @conformance_validator.call(document:, profile:)
        Validation::Report.new(profile:, issues:, executed_steps: [:syntax, :profile, *@conformance_validator.steps])
      rescue UnknownProfileError => e
        ReportBuilder.profile(e)
      rescue XsdValidationError => e
        ReportBuilder.xsd(profile, e)
      rescue InvalidXmlError => e
        ReportBuilder.syntax(e)
      end
    end
  end
end
