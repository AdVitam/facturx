# frozen_string_literal: true

require 'nokogiri'
require_relative '../error'

module Facturx
  module Xml
    class Parser
      def call(xml:)
        unless xml.is_a?(String)
          raise InvalidXmlError.new('XML must be provided as a byte String', input_class: xml.class.name)
        end

        Nokogiri::XML::Document.parse(xml) { |config| config.strict.nonet }
      rescue Nokogiri::XML::SyntaxError => e
        raise InvalidXmlError.new(
          'XML is malformed',
          errors: [{ message: e.message, line: e.line, column: e.column }.freeze].freeze
        ), cause: e
      end
    end
  end
end
