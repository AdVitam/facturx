# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      class TradeLines
        class Product < Stage
          def call(parent:, value:)
            within_group('BG-31', value, element: 'ram:SpecifiedTradeProduct', parent:,
                                       represented_attributes: [:classifications]) do |node, item|
              identifiers(node, item)
              emit('BT-153', item.name, element: 'ram:Name', parent: node)
              emit('BT-154', item.description, element: 'ram:Description', parent: node)
              attributes(node, item.attributes)
              classifications(node, item.classifications)
              origin_country(node, item.origin_country_code)
            end
          end

          private

          def identifiers(parent, item)
            emit_compound_identifier(parent, item.global_identifier, value_id: 'BT-157', scheme_id: 'BT-157-1',
                                                                     element: 'ram:GlobalID')
            emit_identifier(parent, 'BT-155', item.seller_identifier, 'ram:SellerAssignedID')
            emit_identifier(parent, 'BT-156', item.buyer_identifier, 'ram:BuyerAssignedID')
          end

          def emit_identifier(parent, id, identifier, element)
            emit(id, identifier&.value, element:, parent:)
          end

          def attributes(parent, values)
            each_group('BG-32', values, element: 'ram:ApplicableProductCharacteristic', parent:) do |node, item|
              emit('BT-160', item.name, element: 'ram:Description', parent: node)
              emit('BT-161', item.value, element: 'ram:Value', parent: node)
            end
          end

          def classifications(parent, values)
            items = Array(values)
            return unless observe?('BT-158', items.map(&:code))

            items.each { |item| classification(parent, item) }
          end

          def classification(parent, item)
            container(parent, 'ram:DesignatedProductClassification') do |node|
              code = technical(node, 'ram:ClassCode', format_identifier_value('BT-158', item.code))
              emit_attribute('BT-158-1', item.list_id, node: code, attribute: 'listID', group_present: !item.code.nil?)
              emit_attribute('BT-158-2', item.list_version_id, node: code, attribute: 'listVersionID',
                                                               group_present: !item.code.nil?)
            end
          end

          def origin_country(parent, value)
            return observe?('BT-159', nil) unless value

            container(parent, 'ram:OriginTradeCountry') do |node|
              emit('BT-159', value, element: 'ram:ID', parent: node)
            end
          end
        end
      end
    end
  end
end
