# frozen_string_literal: true

module EuEinvoice
  class Reader
    class SemanticMapper
      private

      def line_invoiced_object_identifier(parent, parent_base)
        relative_path = './ram:SpecifiedLineTradeSettlement/ram:AdditionalReferencedDocument'
        node = parent.at_xpath("#{relative_path}[ram:TypeCode='130']", NAMESPACES)
        return unless node

        technical_value('./ram:TypeCode', node)
        base = "#{parent_base}/ram:SpecifiedLineTradeSettlement/ram:AdditionalReferencedDocument"
        identifier('BT-128', 'BT-128-1', context: node, base_xpath: base)
      end
    end
  end
end
