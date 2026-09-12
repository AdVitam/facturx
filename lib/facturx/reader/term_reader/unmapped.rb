# frozen_string_literal: true

module Facturx
  class Reader
    class TermReader
      IGNORED_ATTRIBUTES = %w[currencyID schemeID].freeze

      def add_unmapped(root)
        add_unmapped_elements(root)
        add_unmapped_attributes(root)
      end

      private

      def add_unmapped_elements(root)
        root.xpath('.//*[not(*)]').each do |node|
          next if node.text.empty? || matched?(node)

          add(:unmapped_element, nil, node.path, 'Element is not mapped to the EN16931 model', value: node.text)
        end
      end

      def add_unmapped_attributes(root)
        root.xpath('.//@*').each do |attribute|
          next if IGNORED_ATTRIBUTES.include?(attribute.name) || matched?(attribute)

          add(:unmapped_element, nil, attribute.path, 'Attribute is not mapped to the EN16931 model',
              value: attribute.value)
        end
      end

      def matched?(node)
        @matched_nodes.key?(node)
      end
    end
  end
end
