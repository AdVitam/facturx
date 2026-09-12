# frozen_string_literal: true

module Facturx
  class Reader
    class SemanticMapper
      private

      def tax_breakdowns
        group_nodes('BG-23').map do |node|
          base = group_xpath('BG-23')
          attributes = scalar_attributes(:tax_breakdown, 'BG-23', context: node, base_xpath: base)
          TaxBreakdown.new(type_code: technical_value('./ram:TypeCode', node), **attributes)
        end
      end

      def allowance_charges(group_id, charge:, context: @document, base_xpath: nil)
        group_nodes(group_id, context:, base_xpath:) { |node| charge_indicator(node, group_id) == charge }.map do |node|
          base = group_xpath(group_id)
          AllowanceCharge.new(**allowance_attributes(node, base, group_id), indicator: charge,
                                                                            tax: allowance_tax(node, base, group_id))
        end
      end

      def allowance_attributes(node, base, group_id)
        scalar_attributes(:allowance_charge, group_id, context: node, base_xpath: base, except: [:tax])
      end

      def allowance_tax(node, base, group_id)
        technical_value('./ram:CategoryTradeTax/ram:TypeCode', node)
        category = value(term_for(:allowance_charge, group_id, :tax,
                                  xpath_suffix: '/ram:CategoryTradeTax/ram:CategoryCode')&.id,
                         context: node, base_xpath: base)
        rate = value(term_for(:allowance_charge, group_id, :tax,
                              xpath_suffix: '/ram:CategoryTradeTax/ram:RateApplicablePercent')&.id,
                     context: node, base_xpath: base)
        TaxBreakdown.new(category_code: category, rate:) if category || rate
      end

      def charge_indicator(node, group_id)
        @charge_indicators ||= {}.compare_by_identity
        @charge_indicators.fetch(node) do
          path = './ram:ChargeIndicator/udt:Indicator'
          @charge_indicators[node] = technical_boolean(path, node, term_id: "#{group_id}-1", required: true)
        end
      end

      def period(group_id, context: @document, base_xpath: nil)
        node = first_group(group_id, context:, base_xpath:)
        return unless node

        base = group_xpath(group_id)
        Period.new(**scalar_attributes(:period, group_id, context: node, base_xpath: base))
      end

      def totals(currency, tax_currency)
        node = first_group('BG-22')
        return unless node

        base = group_xpath('BG-22')
        attributes = scalar_attributes(:totals, 'BG-22', context: node, base_xpath: base,
                                                         except: %i[tax_total tax_total_in_tax_currency])
        Totals.new(**attributes, **tax_total_attributes(node, base, currency, tax_currency))
      end

      def tax_total_attributes(node, base, currency, tax_currency)
        total_nodes = node.xpath('./ram:TaxTotalAmount', NAMESPACES)
        invoice_tax = total_nodes.select { |item| tax_currency.nil? || item['currencyID'] == currency }
        accounting_tax = total_nodes.select { |item| tax_currency && item['currencyID'] == tax_currency }
        {
          tax_total: value('BT-110', context: node, base_xpath: base, nodes: invoice_tax),
          tax_total_in_tax_currency: value('BT-111', context: node, base_xpath: base, nodes: accounting_tax)
        }
      end
    end
  end
end
