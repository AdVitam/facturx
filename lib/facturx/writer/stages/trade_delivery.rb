# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      class TradeDelivery < Stage
        ADDRESS_IDS = {
          postcode: 'BT-78', line_one: 'BT-75', line_two: 'BT-76', line_three: 'BT-165', city: 'BT-77',
          country_code: 'BT-80', country_subdivision: 'BT-79'
        }.freeze

        term_ids(*%w[BT-71 BT-71-1 BT-70 BT-78 BT-75 BT-76 BT-165 BT-77 BT-80 BT-79 BT-72 BT-16 BT-15])

        def call
          value = document.delivery
          node = context.element(context.transaction, 'ram:ApplicableHeaderTradeDelivery')
          delivery(node, value) if delivery_accepted?(value)
          references(node)
        end

        private

        def delivery_accepted?(value)
          group = Terms.group('BG-13-00')
          tracker.observe_group?(group, count: value ? 1 : 0, path: group.xpath)
        end

        def references(parent)
          emit_document_reference(parent, 'BT-16', document.despatch_advice_reference,
                                  'ram:DespatchAdviceReferencedDocument')
          emit_document_reference(parent, 'BT-15', document.receiving_advice_reference,
                                  'ram:ReceivingAdviceReferencedDocument')
        end

        def delivery(parent, value)
          ship_to(parent, value)
          delivery_date(parent, value.date)
        end

        def delivery_date(parent, value)
          unless value
            observe?('BT-72', nil)
            return
          end

          container(parent, 'ram:ActualDeliverySupplyChainEvent') do |event|
            emit_date(event, 'BT-72', value, wrapper: 'ram:OccurrenceDateTime')
          end
        end

        def ship_to(parent, delivery)
          party = delivery.party
          location = delivery.location_identifier
          present = party || location
          within_group('BG-13', present, element: 'ram:ShipToTradeParty', parent:,
                                     represented_attributes: [:name]) do |node,|
            delivery_identifier(node, location)
            emit('BT-70', party&.name, element: 'ram:Name', parent: node)
            emit_address(node, party&.address, 'BG-15', ADDRESS_IDS)
          end
        end

        def delivery_identifier(parent, value)
          if value&.scheme_id
            return unless observe?('BT-71', value.value)

            node = technical(parent, 'ram:GlobalID', format_identifier_value('BT-71', value.value))
            emit_attribute('BT-71-1', value.scheme_id, node:, attribute: 'schemeID', group_present: true)
          else
            emit('BT-71', value&.value, element: 'ram:ID', parent:)
            observe?('BT-71-1', nil, group_present: false)
          end
        end
      end
    end
  end
end
