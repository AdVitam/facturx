# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      module TradeSettlementParties
        private

        def payee(parent)
          within_group('BG-10', document.payee, element: 'ram:PayeeTradeParty', parent:) do |node, party|
            emit_party_identifiers(node, party.identifiers, 'BT-60', 'BT-60-1')
            emit('BT-59', party.name, element: 'ram:Name', parent: node)
            payee_legal_organization(node, party)
          end
        end

        def payee_legal_organization(parent, party)
          legal = party.legal_registration
          return missing_payee_registration unless legal

          container(parent, 'ram:SpecifiedLegalOrganization') do |node|
            emit_compound_identifier(node, legal, value_id: 'BT-61', scheme_id: 'BT-61-1', element: 'ram:ID')
          end
        end

        def missing_payee_registration
          observe?('BT-61', nil)
          observe?('BT-61-1', nil, group_present: false)
        end
      end
    end
  end
end
