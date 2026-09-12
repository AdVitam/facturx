# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      class TradeLines
        class Settlement < Stage
          ADJUSTMENT_IDS = {
            'BG-27' => %w[BT-138 BT-137 BT-136 BT-140 BT-139],
            'BG-28' => %w[BT-143 BT-142 BT-141 BT-145 BT-144]
          }.freeze

          def call(parent:, line:)
            node = context.element(parent, 'ram:SpecifiedLineTradeSettlement')
            line_tax(node, line.tax)
            period(node, line.period)
            adjustment_groups(node, line.allowances, 'BG-27', false)
            adjustment_groups(node, line.charges, 'BG-28', true)
            monetary_sum(node, line.net_amount)
            line_invoiced_object(node, line.invoiced_object_identifier)
            accounting_reference(node, 'BT-133', line.buyer_accounting_reference)
          end

          private

          def line_tax(parent, value)
            within_group('BG-30', value, element: 'ram:ApplicableTradeTax', parent:) do |node, item|
              technical(node, 'ram:TypeCode', item.type_code || 'VAT')
              emit('BT-151', item.category_code, element: 'ram:CategoryCode', parent: node)
              emit('BT-152', item.rate, element: 'ram:RateApplicablePercent', parent: node)
            end
          end

          def period(parent, value)
            within_group('BG-26', value, element: 'ram:BillingSpecifiedPeriod', parent:) do |node, item|
              emit_date(node, 'BT-134', item.start_date, wrapper: 'ram:StartDateTime')
              emit_date(node, 'BT-135', item.end_date, wrapper: 'ram:EndDateTime')
            end
          end

          def adjustment_groups(parent, values, group_id, indicator)
            ids = ADJUSTMENT_IDS.fetch(group_id)
            each_group(group_id, values, element: 'ram:SpecifiedTradeAllowanceCharge', parent:) do |node, item|
              adjustment_indicator(node, item, group_id, indicator)
              emit_adjustment_fields(node, item, ids)
            end
          end

          def emit_adjustment_fields(parent, item, ids)
            emit(ids[0], item.percentage, element: 'ram:CalculationPercent', parent:)
            emit(ids[1], item.base_amount, element: 'ram:BasisAmount', parent:)
            emit(ids[2], item.amount, element: 'ram:ActualAmount', parent:)
            emit(ids[3], item.reason_code, element: 'ram:ReasonCode', parent:)
            emit(ids[4], item.reason, element: 'ram:Reason', parent:)
          end

          def adjustment_indicator(parent, item, group_id, fallback)
            value = item.indicator.nil? ? fallback : item.indicator
            within_group("#{group_id}-0", value, element: 'ram:ChargeIndicator', parent:) do |node, indicator|
              within_group("#{group_id}-1", indicator, element: 'udt:Indicator', parent: node) do |leaf, raw|
                leaf.content = raw ? 'true' : 'false'
              end
            end
          end

          def monetary_sum(parent, value)
            container(parent, 'ram:SpecifiedTradeSettlementLineMonetarySummation') do |node|
              emit('BT-131', value, element: 'ram:LineTotalAmount', parent: node)
            end
          end

          def line_invoiced_object(parent, value)
            return observe_missing_invoiced_object unless value

            container(parent, 'ram:AdditionalReferencedDocument') do |node|
              emit('BT-128', value.value, element: 'ram:IssuerAssignedID', parent: node)
              technical(node, 'ram:TypeCode', '130')
              emit('BT-128-1', value.scheme_id, element: 'ram:ReferenceTypeCode', parent: node)
            end
          end

          def observe_missing_invoiced_object
            observe('BT-128', nil)
            observe('BT-128-1', nil, group_present: false)
          end

          def accounting_reference(parent, id, value)
            raw = value.respond_to?(:value) ? value.value : value
            return observe(id, nil) unless raw

            container(parent, 'ram:ReceivableSpecifiedTradeAccountingAccount') do |node|
              emit(id, raw, element: 'ram:ID', parent: node)
            end
          end
        end
      end
    end
  end
end
