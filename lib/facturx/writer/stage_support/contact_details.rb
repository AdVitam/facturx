# frozen_string_literal: true

module Facturx
  class Writer
    module StageSupport
      module ContactDetails
        ADDRESS_ELEMENTS = {
          postcode: 'ram:PostcodeCode',
          line_one: 'ram:LineOne',
          line_two: 'ram:LineTwo',
          line_three: 'ram:LineThree',
          city: 'ram:CityName',
          country_code: 'ram:CountryID',
          country_subdivision: 'ram:CountrySubDivisionName'
        }.freeze

        private

        def emit_date(parent, id, value, wrapper:, value_element: 'udt:DateTimeString')
          unless value
            emit(id, nil, element: value_element, parent:)
            return
          end

          container(parent, wrapper) do |node|
            emit(id, value, element: value_element, parent: node, attributes: { 'format' => '102' })
          end
        end

        def emit_address(parent, address, group_id, ids)
          within_group(group_id, address, element: 'ram:PostalTradeAddress', parent:) do |node, item|
            ADDRESS_ELEMENTS.each do |attribute, element|
              emit(ids.fetch(attribute), item.public_send(attribute), element:, parent: node)
            end
          end
        end

        def emit_contact(parent, contact, group_id, ids)
          within_group(group_id, contact, element: 'ram:DefinedTradeContact', parent:) do |node, item|
            emit(ids.fetch(:name), item.name, element: 'ram:PersonName', parent: node)
            communication(node, ids.fetch(:telephone), item.telephone,
                          'ram:TelephoneUniversalCommunication', 'ram:CompleteNumber')
            communication(node, ids.fetch(:email), item.email, 'ram:EmailURIUniversalCommunication', 'ram:URIID')
          end
        end

        def communication(parent, id, value, wrapper, element)
          if value
            container(parent, wrapper) { |node| emit(id, value, element:, parent: node) }
          else
            emit(id, nil, element:, parent:)
          end
        end
      end
    end
  end
end
