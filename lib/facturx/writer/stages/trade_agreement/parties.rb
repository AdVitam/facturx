# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      module TradeAgreementSupport
        module Parties
          private

          def write_parties(parent)
            seller(parent)
            buyer(parent)
            tax_representative(parent)
          end

          def seller(parent)
            within_group('BG-4', document.seller, element: 'ram:SellerTradeParty', parent:,
                                      represented_attributes: %i[address contact]) do |node, party|
              write_seller_identity(node, party)
              write_seller_details(node, party)
            end
          end

          def write_seller_identity(node, party)
            emit_party_identifiers(node, party.identifiers, 'BT-29', 'BT-29-1')
            emit('BT-27', party.name, element: 'ram:Name', parent: node)
            emit('BT-33', party.description, element: 'ram:Description', parent: node)
            legal_organization(node, party, 'BT-30', 'BT-30-1', trading_name_id: 'BT-28')
          end

          def write_seller_details(node, party)
            emit_contact(node, party.contact, 'BG-6', self.class::SELLER_CONTACT)
            emit_address(node, party.address, 'BG-5', self.class::SELLER_ADDRESS)
            electronic_address(node, party.electronic_address, 'BT-34', 'BT-34-1')
            emit_tax_registration(node, 'BT-31', party.vat_identifier, 'VA')
            emit_tax_registration(node, 'BT-32', party.tax_identifier, 'FC')
          end

          def buyer(parent)
            within_group('BG-7', document.buyer, element: 'ram:BuyerTradeParty', parent:,
                                      represented_attributes: %i[address contact]) do |node, party|
              write_buyer_identity(node, party)
              write_buyer_details(node, party)
            end
          end

          def write_buyer_identity(node, party)
            emit_party_identifiers(node, party.identifiers, 'BT-46', 'BT-46-1')
            emit('BT-44', party.name, element: 'ram:Name', parent: node)
            legal_organization(node, party, 'BT-47', 'BT-47-1', trading_name_id: 'BT-45')
          end

          def write_buyer_details(node, party)
            emit_contact(node, party.contact, 'BG-9', self.class::BUYER_CONTACT)
            emit_address(node, party.address, 'BG-8', self.class::BUYER_ADDRESS)
            electronic_address(node, party.electronic_address, 'BT-49', 'BT-49-1')
            emit_tax_registration(node, 'BT-48', party.vat_identifier, 'VA')
          end

          def tax_representative(parent)
            within_group('BG-11', document.tax_representative, element: 'ram:SellerTaxRepresentativeTradeParty',
                                                               parent:, represented_attributes: [:address]) do |node, party|
              emit('BT-62', party.name, element: 'ram:Name', parent: node)
              emit_address(node, party.address, 'BG-12', self.class::REPRESENTATIVE_ADDRESS)
              emit_tax_registration(node, 'BT-63', party.vat_identifier, 'VA')
            end
          end

          def legal_organization(parent, party, value_id, scheme_id, trading_name_id:)
            legal = party.legal_registration
            trading = party.trading_name
            return observe_missing_legal_organization(value_id, scheme_id, trading_name_id) unless legal || trading

            container(parent, 'ram:SpecifiedLegalOrganization') do |node|
              emit_compound_identifier(node, legal, value_id:, scheme_id:, element: 'ram:ID')
              emit(trading_name_id, trading, element: 'ram:TradingBusinessName', parent: node)
            end
          end

          def observe_missing_legal_organization(value_id, scheme_id, trading_name_id)
            observe?(value_id, nil)
            observe?(scheme_id, nil, group_present: false)
            observe?(trading_name_id, nil)
            nil
          end

          def electronic_address(parent, identifier, value_id, scheme_id)
            return observe_missing_identifier(value_id, scheme_id) unless identifier

            container(parent, 'ram:URIUniversalCommunication') do |node|
              emit_compound_identifier(node, identifier, value_id:, scheme_id:, element: 'ram:URIID')
            end
          end

          def observe_missing_identifier(value_id, scheme_id)
            observe?(value_id, nil)
            observe?(scheme_id, nil, group_present: false)
            nil
          end
        end
      end
    end
  end
end
