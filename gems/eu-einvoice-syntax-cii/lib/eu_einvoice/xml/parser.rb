# frozen_string_literal: true

require 'nokogiri'
require 'eu_einvoice/error'
require 'eu_einvoice/resource_limits'
require 'eu_einvoice/source'

module EuEinvoice
  module Xml
    class Parser
      def initialize(limits: ResourceLimits.new)
        @limits = limits
      end

      def call(xml:)
        xml = Source.read(xml, limit: @limits.xml_bytes)
        preflight(xml)
        Nokogiri::XML::Document.parse(xml) { |config| config.strict.nonet }
      rescue Nokogiri::XML::SyntaxError => e
        raise InvalidXmlError.new(
          'XML is malformed',
          errors: [{ message: e.message, line: e.line, column: e.column }.freeze].freeze
        )
      end

      private

      def preflight(xml)
        options = Nokogiri::XML::ParseOptions::NONET
        nodes = 0
        Nokogiri::XML::Reader(xml, nil, nil, options).each do |node|
          if node.node_type == Nokogiri::XML::Reader::TYPE_DOCUMENT_TYPE
            raise InvalidXmlError.new('Document types are prohibited', reason: :doctype)
          end

          nodes += 1
          @limits.check!(:xml_nodes, nodes)
          @limits.check!(:xml_depth, node.depth + 1)
        end
      end
    end
  end
end
