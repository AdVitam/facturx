# frozen_string_literal: true

module Facturx
  class Reader
    class SemanticMapper
      private

      def lines
        group_nodes('BG-25').map { |node| line(node) }
      end

      def line(node)
        base = group_xpath('BG-25')
        Line.new(
          **scalar_attributes(:line, 'BG-25', context: node, base_xpath: base),
          **line_trade_attributes(node, base),
          **line_reference_attributes(node, base)
        )
      end

      def line_trade_attributes(node, base)
        {
          product: product(node, base),
          quantity: quantity('BT-129', 'BT-130', context: node, base_xpath: base),
          gross_price: price(node, base, gross: true),
          net_price: price(node, base, gross: false),
          tax: line_tax(node, base),
          period: period('BG-26', context: node, base_xpath: base),
          allowances: allowance_charges('BG-27', charge: false, context: node, base_xpath: base),
          charges: allowance_charges('BG-28', charge: true, context: node, base_xpath: base)
        }
      end

      def line_reference_attributes(node, base)
        {
          buyer_order_reference: reference('BT-132', context: node, base_xpath: base, field: :line_id),
          invoiced_object_identifier: identifier('BT-128', 'BT-128-1', context: node, base_xpath: base)
        }
      end

      def product(parent, parent_base)
        node = first_group('BG-31', context: parent, base_xpath: parent_base)
        return unless node

        base = group_xpath('BG-31')
        Product.new(**product_attributes_hash(node, base))
      end

      def product_attributes_hash(node, base)
        identifiers = %i[seller_identifier buyer_identifier global_identifier]
        scalar_attributes(:product, 'BG-31', context: node, base_xpath: base, except: identifiers).merge(
          seller_identifier: identifier('BT-155', context: node, base_xpath: base),
          buyer_identifier: identifier('BT-156', context: node, base_xpath: base),
          global_identifier: identifier('BT-157', 'BT-157-1', context: node, base_xpath: base),
          attributes: product_attributes(node, base),
          classifications: product_classifications(node, base)
        )
      end

      def product_attributes(parent, parent_base)
        group_nodes('BG-32', context: parent, base_xpath: parent_base).map do |node|
          base = group_xpath('BG-32')
          ProductAttribute.new(**scalar_attributes(:product_attribute, 'BG-32', context: node, base_xpath: base))
        end
      end

      def product_classifications(parent, parent_base)
        nodes = parent.xpath('./ram:DesignatedProductClassification', NAMESPACES)
        nodes.map do |node|
          base = "#{parent_base}/ram:DesignatedProductClassification"
          ProductClassification.new(
            code: scalar_value('BT-158', context: node, base_xpath: base),
            list_id: value('BT-158-1', context: node, base_xpath: base),
            list_version_id: value('BT-158-2', context: node, base_xpath: base)
          )
        end
      end

      def price(parent, parent_base, gross:)
        prefix = gross ? 'Gross' : 'Net'
        node = parent.at_xpath("./ram:SpecifiedLineTradeAgreement/ram:#{prefix}PriceProductTradePrice", NAMESPACES)
        return unless node

        base = "#{parent_base}/ram:SpecifiedLineTradeAgreement/ram:#{prefix}PriceProductTradePrice"
        Price.new(**price_attributes(node, base, gross))
      end

      def price_attributes(node, base, gross)
        ids = gross ? %w[BT-148 BT-149-1 BT-150-1 BT-147] : %w[BT-146 BT-149 BT-150]
        {
          amount: value(ids[0], context: node, base_xpath: base),
          basis_quantity: quantity(ids[1], ids[2], context: node, base_xpath: base),
          discount: gross ? price_discount(node, base, ids[3]) : nil
        }
      end

      def price_discount(node, base, amount_id)
        indicator = read_price_allowance_indicator(node, base)
        return value(amount_id, context: node, base_xpath: base) if indicator == false
        return unless indicator == true

        @terms.add(:invalid_value, 'BT-147-02', base, 'Gross price discount cannot be a charge', value: indicator)
        nil
      end

      def line_tax(parent, parent_base)
        node = first_group('BG-30', context: parent, base_xpath: parent_base)
        return unless node

        base = group_xpath('BG-30')
        attributes = scalar_attributes(:tax_breakdown, 'BG-30', context: node, base_xpath: base)
        TaxBreakdown.new(type_code: technical_value('./ram:TypeCode', node), **attributes)
      end
    end
  end
end
