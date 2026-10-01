# frozen_string_literal: true

require 'nokogiri'
require 'eu_einvoice/resource_limits'
require 'eu_einvoice/source'

module EuEinvoice
  module Pdf
    class MetadataParser
      def initialize(limits: ResourceLimits.new)
        @limits = limits
      end

      def call(metadata)
        bytes = Source.read(metadata, limit: @limits.xml_bytes)
        preflight(bytes)
        Nokogiri::XML::Document.parse(bytes) { |config| config.strict.nonet }
      end

      private

      def preflight(bytes)
        nodes = 0
        Nokogiri::XML::Reader(bytes, nil, nil, Nokogiri::XML::ParseOptions::NONET).each do |node|
          if node.node_type == Nokogiri::XML::Reader::TYPE_DOCUMENT_TYPE
            raise VerificationError.new('XMP document types are prohibited', reason: :invalid_xmp)
          end

          nodes += 1
          @limits.check!(:xml_nodes, nodes)
          @limits.check!(:xml_depth, node.depth + 1)
        end
      end
    end
  end
end
