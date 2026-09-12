# frozen_string_literal: true

module Facturx
  class Reader
    class SemanticMapper
      private

      def party(group_id, contact_group: nil, address_group: nil)
        node = first_group(group_id)
        return unless node

        base = group_xpath(group_id)
        Party.new(**party_scalar_attributes(node, base, group_id),
                  **party_identifier_attributes(node, base, group_id),
                  **party_group_attributes(node, base, contact_group, address_group))
      end

      def party_scalar_attributes(node, base, group_id)
        scalar_attributes(:party, group_id, context: node, base_xpath: base,
                                            only: %i[name description trading_name])
      end

      def party_identifier_attributes(node, base, group_id)
        {
          identifiers: party_identifiers(node, base, group_id),
          legal_registration: compound_identifier(:legal_registration, node, base, group_id),
          vat_identifier: tax_registration(:vat_identifier, 'VA', node, base, group_id),
          tax_identifier: tax_registration(:tax_identifier, 'FC', node, base, group_id),
          electronic_address: compound_identifier(:electronic_address, node, base, group_id)
        }
      end

      def party_group_attributes(node, base, contact_group, address_group)
        {
          address: address_group && address(node, base, address_group),
          contact: contact_group && contact(node, base, contact_group)
        }
      end

      def party_identifiers(node, base, group_id)
        value_term = term_for(:party, group_id, :identifiers, xpath_suffix: '/ram:ID')
        return [] unless value_term

        identifiers = local_party_identifiers(value_term, node, base)
        scheme_term = term_for(:party, group_id, :identifiers, xpath_suffix: '/@schemeID')
        return identifiers unless scheme_term

        identifiers.concat(global_party_identifiers(node))
      end

      def local_party_identifiers(term, node, base)
        Array(value(term.id, context: node, base_xpath: base)).compact.map { |item| Identifier.new(value: item) }
      end

      def global_party_identifiers(node)
        node.xpath('./ram:GlobalID', NAMESPACES).map do |global_id|
          @terms.mark(global_id)
          @terms.mark(global_id.attribute('schemeID'))
          Identifier.new(value: global_id.text, scheme_id: global_id['schemeID'])
        end
      end

      def compound_identifier(attribute, node, base, group_id)
        value_term = term_for(:party, group_id, attribute, xpath_suffix: '/ram:ID') ||
                     term_for(:party, group_id, attribute, xpath_suffix: '/ram:URIID')
        return unless value_term

        scheme_term = term_for(:party, group_id, attribute, xpath_suffix: '/@schemeID')
        identifier(value_term.id, scheme_term&.id, context: node, base_xpath: base)
      end

      def contact(parent, parent_base, group_id)
        node = first_group(group_id, context: parent, base_xpath: parent_base)
        return unless node

        base = group_xpath(group_id)
        attributes = scalar_attributes(:contact, group_id, context: node, base_xpath: base)
        Contact.new(**attributes)
      end

      def address(parent, parent_base, group_id)
        node = first_group(group_id, context: parent, base_xpath: parent_base)
        return unless node

        base = group_xpath(group_id)
        attributes = scalar_attributes(:address, group_id, context: node, base_xpath: base)
        Address.new(**attributes)
      end
    end
  end
end
