# frozen_string_literal: true

module EuEinvoice
  class Reader
    class SemanticMapper
      private

      def delivery
        node = first_group('BG-13-00')
        return unless node

        base = group_xpath('BG-13-00')
        party_node = first_group('BG-13', context: node, base_xpath: base)
        party = delivery_party(party_node) if party_node
        Delivery.new(
          location_identifier: party_node && delivery_identifier(party_node),
          party:,
          date: value('BT-72', context: node, base_xpath: base)
        )
      end

      def delivery_party(node)
        base = group_xpath('BG-13')
        Party.new(
          name: value('BT-70', context: node, base_xpath: base),
          address: address(node, base, 'BG-15')
        )
      end

      def delivery_identifier(node)
        base = group_xpath('BG-13')
        global_id = node.at_xpath('./ram:GlobalID', NAMESPACES)
        @terms.mark(global_id) if global_id
        local_id = value('BT-71', context: node, base_xpath: base)
        return Identifier.new(value: local_id) if local_id

        return unless global_id

        Identifier.new(value: global_id.text, scheme_id: global_id['schemeID'])
      end
    end
  end
end
