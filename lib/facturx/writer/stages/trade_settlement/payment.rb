# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      module TradeSettlementPayment
        private

        def payment_means(parent, payment)
          value = payment if payment_means_present?(payment)
          within_group('BG-16', value, element: 'ram:SpecifiedTradeSettlementPaymentMeans', parent:) do |node, item|
            emit_payment_means(parent, node, item)
          end
        end

        def emit_payment_means(parent, node, payment)
          transfers = payment.credit_transfers
          nodes = [node, *additional_payment_means(parent, transfers)]
          means_code, means_text = payment_descriptions(node, payment)
          duplicate_payment_terms(nodes.drop(1), means_code, means_text)
          payment_card(node, payment.payment_card)
          debtor_account(node, payment.direct_debit)
          credit_transfers(nodes, transfers)
        end

        def payment_descriptions(parent, payment)
          code = emit('BT-81', payment.means_code, element: 'ram:TypeCode', parent:).first&.text
          text = emit('BT-82', payment.means_text, element: 'ram:Information', parent:).first&.text
          [code, text]
        end

        def additional_payment_means(parent, transfers)
          Array.new([Array(transfers).size - 1, 0].max) do
            context.element(parent, 'ram:SpecifiedTradeSettlementPaymentMeans')
          end
        end

        def duplicate_payment_terms(nodes, means_code, means_text)
          nodes.each do |node|
            technical(node, 'ram:TypeCode', means_code)
            technical(node, 'ram:Information', means_text)
          end
        end

        def payment_means_present?(payment)
          return false unless payment

          [payment.means_code, payment.means_text, payment.payment_card,
           payment.direct_debit&.debtor_account_identifier, *payment.credit_transfers].any?
        end

        def payment_card(parent, value)
          within_group('BG-18', value, element: 'ram:ApplicableTradeSettlementFinancialCard', parent:) do |node, card|
            emit('BT-87', card.primary_account_number, element: 'ram:ID', parent: node)
            emit('BT-88', card.holder_name, element: 'ram:CardholderName', parent: node)
          end
        end

        def debtor_account(parent, value)
          identifier = value&.debtor_account_identifier
          return observe('BT-91', nil) unless identifier

          container(parent, 'ram:PayerPartyDebtorFinancialAccount') do |node|
            emit('BT-91', identifier.value, element: 'ram:IBANID', parent: node)
          end
        end

        def credit_transfers(parents, values)
          transfers = Array(values)
          group = Terms.group('BG-17')
          return unless tracker.observe_group?(group, count: transfers.size, path: group.xpath)

          transfers.zip(parents).each { |item, parent| emit_credit_transfer(parent, item) }
        end

        def emit_credit_transfer(parent, transfer)
          container(parent, 'ram:PayeePartyCreditorFinancialAccount') do |node|
            emit_identifier_value('BT-84', transfer.account_identifier, 'ram:IBANID', node)
            emit('BT-85', transfer.account_name, element: 'ram:AccountName', parent: node)
          end
          emit_provider(parent, transfer.provider_identifier)
        end

        def emit_provider(parent, identifier)
          return observe('BT-86', nil) unless identifier

          container(parent, 'ram:PayeeSpecifiedCreditorFinancialInstitution') do |node|
            emit('BT-86', identifier.value, element: 'ram:BICID', parent: node)
          end
        end

        def emit_identifier_value(id, identifier, element, parent)
          emit(id, identifier&.value, element:, parent:)
        end
      end
    end
  end
end
