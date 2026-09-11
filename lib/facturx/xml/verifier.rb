# frozen_string_literal: true

require_relative 'parser'
require_relative 'profile_detector'
require_relative 'schema_validator'

module Facturx
  module Xml
    class Verifier
      def initialize(parser: Parser.new, profile_detector: ProfileDetector.new, schema_validator: SchemaValidator.new)
        @parser = parser
        @profile_detector = profile_detector
        @schema_validator = schema_validator
      end

      def call(xml:)
        document = @parser.call(xml: xml)
        profile = @profile_detector.call(document: document)
        @schema_validator.call(document: document, profile: profile)
        profile
      end
    end
  end
end
