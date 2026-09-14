# frozen_string_literal: true

require_relative '../validation'
require_relative 'parser'
require_relative 'profile_detector'
require_relative 'report_builder'
require_relative 'conformance_validator'

module Facturx
  module Xml
    class Validator
      def initialize(
        parser: Parser.new,
        profile_detector: ProfileDetector.new,
        conformance_validator: ConformanceValidator.new
      )
        @parser = parser
        @profile_detector = profile_detector
        @conformance_validator = conformance_validator
      end

      def call(xml:)
        document = @parser.call(xml:)
        profile = @profile_detector.call(document:)
        issues = @conformance_validator.call(document:, profile:)
        Validation::Report.new(profile:, issues:)
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
