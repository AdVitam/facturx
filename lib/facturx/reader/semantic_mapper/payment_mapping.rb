# frozen_string_literal: true

module Facturx
  class Reader
    class SemanticMapper
      private

      def payment
        nodes = group_nodes('BG-16')
        return if nodes.empty?

        diagnose_multiple_payments(nodes)
        node = nodes.first
        base = group_xpath('BG-16')
        PaymentInstructions.new(**payment_attributes(node, base))
      end

      def payment_attributes(node, base)
        scalar = scalar_attributes(:payment_instructions, 'BG-16', context: node, base_xpath: base)
                 .merge(scalar_attributes(:payment_instructions, 'BG-19'))
        scalar.merge(
          credit_transfers: credit_transfers(node, base),
          payment_card: payment_card(node, base),
          direct_debit: direct_debit
        )
      end

      def diagnose_multiple_payments(nodes)
        return unless nodes.size > 1

        @terms.add(:multiple_values, 'BG-16', group_xpath('BG-16'),
                   'Multiple payment instructions cannot fit the EN16931 model', count: nodes.size)
      end

      def credit_transfers(parent, parent_base)
        group_nodes('BG-17', context: parent, base_xpath: parent_base).map do |node|
          credit_transfer(node, parent, parent_base)
        end
      end

      def credit_transfer(node, parent, parent_base)
        base = group_xpath('BG-17')
        account = term_for(:credit_transfer, 'BG-17', :account_identifier)
        provider = term_for(:credit_transfer, 'BG-16', :provider_identifier)
        attributes = scalar_attributes(:credit_transfer, 'BG-17', context: node, base_xpath: base,
                                                                  except: [:account_identifier])
        CreditTransfer.new(**attributes, account_identifier: identifier(account.id, context: node, base_xpath: base),
                                         provider_identifier: identifier(provider&.id, context: parent,
                                                                                       base_xpath: parent_base))
      end

      def payment_card(parent, parent_base)
        node = first_group('BG-18', context: parent, base_xpath: parent_base)
        return unless node

        base = group_xpath('BG-18')
        PaymentCard.new(**scalar_attributes(:payment_card, 'BG-18', context: node, base_xpath: base))
      end

      def direct_debit
        values = %i[mandate_identifier creditor_identifier debtor_account_identifier].to_h do |attribute|
          [attribute, identifier(term_for_attribute(:direct_debit, attribute)&.id)]
        end
        DirectDebit.new(**values) if values.values.any?
      end
    end
  end
end
