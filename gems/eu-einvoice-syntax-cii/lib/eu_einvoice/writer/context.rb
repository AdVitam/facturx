# frozen_string_literal: true

require 'nokogiri'
require 'eu_einvoice/xml/namespaces'

module EuEinvoice
  class Writer
    class Context
      attr_reader :document, :profile, :tracker, :xml, :root

      def initialize(document:, profile:, tracker:)
        @document = document
        @profile = profile
        @tracker = tracker
        @xml = Nokogiri::XML::Document.new
        @xml.encoding = 'UTF-8'
        @root = namespaced_node('rsm', 'CrossIndustryInvoice')
        Xml::Namespaces::MAP.each { |prefix, uri| @root.add_namespace_definition(prefix, uri) }
        @root.namespace = namespace('rsm')
        @xml.root = @root
      end

      def transaction
        @transaction ||= element(@root, 'rsm:SupplyChainTradeTransaction')
      end

      def element(parent, qualified_name, text: nil, attributes: {})
        prefix, name = qualified_name.split(':', 2)
        node = namespaced_node(prefix, name)
        attributes.each { |attribute, value| node[attribute.to_s] = value }
        node.content = text unless text.nil?
        parent.add_child(node)
        node
      end

      def to_xml
        @xml.to_xml(encoding: 'UTF-8')
      end

      private

      def namespaced_node(prefix, name)
        node = Nokogiri::XML::Node.new(name, @xml)
        node.namespace = namespace(prefix) if @root
        node
      end

      def namespace(prefix)
        @root&.namespace_definitions&.find { |item| item.prefix == prefix }
      end
    end
  end
end
