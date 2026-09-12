# frozen_string_literal: true

module Facturx
  class Reader
    class SemanticMapper
      private

      def payment
        nodes = group_nodes('BG-16')
        base = group_xpath('BG-16')
        attributes = settlement_payment_attributes(nodes.first, base)
        attributes.merge!(payment_means_attributes(nodes.first, base)) if nodes.first
        return if attributes.empty?

        PaymentInstructions.new(**attributes)
      end

      def settlement_payment_attributes(payment_means, base)
        attributes = scalar_attributes(:payment_instructions, 'BG-19')
        direct_debit_details = direct_debit(payment_means, base)
        attributes[:direct_debit] = direct_debit_details if direct_debit_details
        attributes.compact
      end

      def payment_means_attributes(node, base)
        scalar_attributes(:payment_instructions, 'BG-16', context: node, base_xpath: base).merge(
          credit_transfers: credit_transfers(node, base),
          payment_card: payment_card(node, base)
        )
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

      def direct_debit(payment_means, base)
        values = %i[mandate_identifier creditor_identifier].to_h do |attribute|
          [attribute, identifier(term_for_attribute(:direct_debit, attribute)&.id)]
        end
        if payment_means
          values[:debtor_account_identifier] = identifier(
            term_for(:direct_debit, 'BG-16', :debtor_account_identifier)&.id,
            context: payment_means, base_xpath: base
          )
        end
        DirectDebit.new(**values) if values.values.any?
      end
    end
  end
end
