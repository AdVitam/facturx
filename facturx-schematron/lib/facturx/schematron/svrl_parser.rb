# frozen_string_literal: true

require 'nokogiri'
require_relative 'error'

module Facturx
  module Schematron
    class SvrlParser
      NAMESPACES = { 'svrl' => 'http://purl.oclc.org/dsdl/svrl' }.freeze
      ASSERTION_XPATH = '//svrl:failed-assert | //svrl:successful-report'
      PARSE_OPTIONS = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NONET
      private_constant :NAMESPACES, :ASSERTION_XPATH, :PARSE_OPTIONS

      def call(svrl:)
        document = parse(svrl)
        validate_root!(document)
        document.xpath(ASSERTION_XPATH, NAMESPACES).map { |node| issue(node) }
      rescue Nokogiri::XML::SyntaxError => e
        raise InvalidOutputError.new(
          'SaxonC returned invalid Schematron output',
          reason: :invalid_svrl,
          cause: e.class.name
        )
      end

      private

      def parse(svrl)
        Nokogiri::XML::Document.parse(svrl, nil, nil, PARSE_OPTIONS)
      end

      def validate_root!(document)
        root = document.root
        valid_root = root&.name == 'schematron-output' && root.namespace&.href == NAMESPACES.fetch('svrl')
        return if valid_root && document.internal_subset.nil?

        raise InvalidOutputError.new(
          'SaxonC returned unexpected Schematron output',
          reason: :unexpected_svrl
        )
      end

      def issue(node)
        Validation::Issue.new(
          code: :schematron_violation,
          message: message(node),
          layer: :schematron,
          severity: severity(node),
          path: node['location'],
          details: details(node)
        )
      end

      def details(node)
        { rule_id: node['id'], test: node['test'], flag: node['flag'] }
      end

      def message(node)
        value = node.at_xpath('svrl:text', NAMESPACES)&.text.to_s.gsub(/\s+/, ' ').strip
        return value unless value.empty?

        raise InvalidOutputError.new(
          'A Schematron result is missing its message',
          reason: :missing_message,
          rule_id: node['id']
        )
      end

      def severity(node)
        return :error unless node.key?('flag')
        return :warning if node['flag'] == 'warning'

        raise RulePackError.new(
          "The Schematron rule pack returned an unknown flag: #{node['flag'].inspect}",
          reason: :unknown_flag,
          rule_id: node['id'],
          flag: node['flag']
        )
      end
    end
  end
end
