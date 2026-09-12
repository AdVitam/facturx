# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      module TradeSettlementTaxes
        ADJUSTMENT_IDS = {
          false => %w[BT-94 BT-93 BT-92 BT-98 BT-97 BT-95 BT-96],
          true => %w[BT-101 BT-100 BT-99 BT-105 BT-104 BT-102 BT-103]
        }.freeze
        ADJUSTMENT_FIELDS = [
          [:percentage, 'ram:CalculationPercent'],
          [:base_amount, 'ram:BasisAmount'],
          [:amount, 'ram:ActualAmount'],
          [:reason_code, 'ram:ReasonCode'],
          [:reason, 'ram:Reason']
        ].freeze
        private_constant :ADJUSTMENT_IDS, :ADJUSTMENT_FIELDS

        private

        def taxes(parent)
          first = true
          each_group('BG-23', document.tax_breakdowns, element: 'ram:ApplicableTradeTax', parent:,
                                            represented_attributes: [:type_code]) do |node, item|
            emit_tax(node, item, include_tax_point: first)
            first = false
          end
          report_unrepresentable_attribute('BG-23', model: :document, attribute: :vat_point_date) if first && document.vat_point_date
        end

        def emit_tax(parent, tax, include_tax_point:)
          emit('BT-117', tax.tax_amount, element: 'ram:CalculatedAmount', parent:)
          technical(parent, 'ram:TypeCode', tax.type_code, default: 'VAT')
          emit('BT-120', tax.exemption_reason, element: 'ram:ExemptionReason', parent:)
          emit('BT-116', tax.basis_amount, element: 'ram:BasisAmount', parent:)
          emit('BT-118', tax.category_code, element: 'ram:CategoryCode', parent:)
          emit('BT-121', tax.exemption_reason_code, element: 'ram:ExemptionReasonCode', parent:)
          tax_point_date(parent) if include_tax_point
          tax_due_date_type(parent, tax)
          emit('BT-119', tax.rate, element: 'ram:RateApplicablePercent', parent:)
        end

        def tax_due_date_type(parent, tax)
          value = tax.due_date_type_code || document.vat_point_date_code
          emit('BT-8', value, element: 'ram:DueDateTypeCode', parent:)
        end

        def tax_point_date(parent)
          emit_date(
            parent, 'BT-7', document.vat_point_date, wrapper: 'ram:TaxPointDate', value_element: 'udt:DateString'
          )
        end

        def billing_period(parent)
          within_group('BG-14', document.billing_period, element: 'ram:BillingSpecifiedPeriod', parent:) do |node, item|
            emit_date(node, 'BT-73', item.start_date, wrapper: 'ram:StartDateTime')
            emit_date(node, 'BT-74', item.end_date, wrapper: 'ram:EndDateTime')
          end
        end

        def adjustments(parent, values, group_id, indicator)
          ids = ADJUSTMENT_IDS.fetch(indicator)
          each_group(group_id, values, element: 'ram:SpecifiedTradeAllowanceCharge', parent:,
                                     represented_attributes: [:indicator]) do |node, item|
            emit_adjustment(node, item, group_id, indicator, ids)
          end
        end

        def emit_adjustment(parent, adjustment, group_id, indicator, ids)
          adjustment_indicator(parent, adjustment, group_id, indicator)
          emit_adjustment_values(parent, adjustment, ids)
          adjustment_tax(parent, adjustment.tax, group_id, ids[5], ids[6])
        end

        def emit_adjustment_values(parent, adjustment, ids)
          ADJUSTMENT_FIELDS.each_with_index do |(attribute, element), index|
            emit(ids[index], adjustment.public_send(attribute), element:, parent:)
          end
        end

        def adjustment_indicator(parent, item, group_id, fallback)
          value = item.indicator.nil? ? fallback : item.indicator
          within_group("#{group_id}-0", value, element: 'ram:ChargeIndicator', parent:) do |node, indicator|
            within_group("#{group_id}-1", indicator, element: 'udt:Indicator', parent: node) do |leaf, raw|
              leaf.content = raw ? 'true' : 'false'
            end
          end
        end

        def adjustment_tax(parent, tax, group_id, category_id, rate_id)
          return missing_adjustment_tax?(category_id, rate_id) unless tax

          report_unrepresentable_attributes(group_id, tax, represented_attributes: %i[type_code category_code rate])

          container(parent, 'ram:CategoryTradeTax') do |node|
            technical(node, 'ram:TypeCode', tax.type_code, default: 'VAT')
            emit(category_id, tax.category_code, element: 'ram:CategoryCode', parent: node)
            emit(rate_id, tax.rate, element: 'ram:RateApplicablePercent', parent: node)
          end
        end

        def missing_adjustment_tax?(category_id, rate_id)
          observe?(category_id, nil)
          observe?(rate_id, nil)
        end
      end
    end
  end
end
