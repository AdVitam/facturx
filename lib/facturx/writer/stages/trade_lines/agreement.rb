# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      class TradeLines
        class Agreement < Stage
          PRICES = {
            gross: { ids: %w[BT-148 BT-149-1 BT-150-1], element: 'ram:GrossPriceProductTradePrice' },
            net: { ids: %w[BT-146 BT-149 BT-150], element: 'ram:NetPriceProductTradePrice' }
          }.freeze

          def initialize(context, quantity:)
            super(context)
            @quantity = quantity
          end

          def call(parent:, line:)
            within_group('BG-29', line, element: 'ram:SpecifiedLineTradeAgreement', parent:) do |node, item|
              buyer_order_reference(node, item.buyer_order_reference)
              price(node, item.gross_price, kind: :gross)
              price(node, item.net_price, kind: :net)
            end
          end

          private

          def buyer_order_reference(parent, value)
            return observe?('BT-132', nil) unless value

            container(parent, 'ram:BuyerOrderReferencedDocument') do |node|
              emit('BT-132', value.line_id, element: 'ram:LineID', parent: node)
            end
          end

          def price(parent, value, kind:)
            config = PRICES.fetch(kind)
            return observe_missing_price(config, kind:) unless value
            return unrepresentable(config.fetch(:ids).first, 'Price requires an amount') unless value.amount

            container(parent, config.fetch(:element)) do |node|
              emit_price(node, value, config.fetch(:ids))
              gross_discount(node, value.discount) if kind == :gross
            end
          end

          def emit_price(parent, value, ids)
            emit(ids[0], value.amount, element: 'ram:ChargeAmount', parent:)
            @quantity.call(parent:, value: value.basis_quantity, amount_id: ids[1], unit_id: ids[2],
                           element: 'ram:BasisQuantity')
          end

          def observe_missing_price(config, kind:)
            config.fetch(:ids).each { |id| observe?(id, nil) }
            return unless kind == :gross

            observe?('BT-147-01', nil)
            observe?('BT-147', nil)
          end

          def gross_discount(parent, value)
            return observe_missing_discount unless value
            return unless observe?('BT-147-01', false) && observe?('BT-147-02', false)

            emit_discount(parent, value)
          end

          def observe_missing_discount
            observe?('BT-147-01', nil)
            observe?('BT-147-02', nil, group_present: false)
            observe?('BT-147', nil)
          end

          def emit_discount(parent, value)
            container(parent, 'ram:AppliedTradeAllowanceCharge') do |node|
              container(node, 'ram:ChargeIndicator') do |indicator|
                technical(indicator, 'udt:Indicator', format_identifier_value('BT-147-02', false))
              end
              emit('BT-147', value, element: 'ram:ActualAmount', parent: node)
            end
          end
        end
      end
    end
  end
end
