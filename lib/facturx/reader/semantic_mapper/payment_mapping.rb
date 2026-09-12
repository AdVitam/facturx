# frozen_string_literal: true

module Facturx
  class Reader
    class SemanticMapper
      private

      def payment
        nodes = group_nodes('BG-16', collapse_if: method(:projected_credit_transfers?))
        base = group_xpath('BG-16')
        attributes = settlement_payment_attributes(nodes.first, base)
        attributes.merge!(payment_means_attributes(nodes, base)) if nodes.any?
        return if attributes.empty?

        PaymentInstructions.new(**attributes)
      end

      def settlement_payment_attributes(payment_means, base)
        attributes = scalar_attributes(:payment_instructions, 'BG-19')
        direct_debit_details = direct_debit(payment_means, base)
        attributes[:direct_debit] = direct_debit_details if direct_debit_details
        attributes.compact
      end

      def payment_means_attributes(nodes, base)
        attributes = scalar_attributes(:payment_instructions, 'BG-16', context: nodes.first, base_xpath: base)
        mark_repeated_payment_attributes(nodes.drop(1), base)
        attributes.merge(
          credit_transfers: credit_transfers(nodes, base),
          payment_card: nodes.filter_map { |node| payment_card(node, base) }.first
        )
      end

      def mark_repeated_payment_attributes(nodes, base)
        %w[BT-81 BT-82].each do |term_id|
          nodes.each { |node| @terms.mark_value(term_id, context: node, base_xpath: base) }
        end
      end

      def projected_credit_transfers?(nodes)
        return false unless nodes.size > 1
        return false unless nodes.all? { |node| payment_account_count(node) == 1 }

        repeated_payment_attributes?(nodes) && nodes.drop(1).all? { |node| supplemental_payment_node?(node) }
      end

      def repeated_payment_attributes?(nodes)
        %w[ram:TypeCode ram:Information].all? do |xpath|
          nodes.map { |node| node.at_xpath("./#{xpath}", NAMESPACES)&.text }.uniq.one?
        end
      end

      def supplemental_payment_node?(node)
        allowed = %w[TypeCode Information PayeePartyCreditorFinancialAccount
                     PayeeSpecifiedCreditorFinancialInstitution]
        node.element_children.all? { |child| allowed.include?(child.name) }
      end

      def payment_account_count(node)
        node.xpath('./ram:PayeePartyCreditorFinancialAccount', NAMESPACES).size
      end

      def credit_transfers(parents, parent_base)
        provider = term_for(:credit_transfer, 'BG-16', :provider_identifier)
        parents.flat_map do |parent|
          provider_identifier = identifier(provider&.id, context: parent, base_xpath: parent_base)
          group_nodes('BG-17', context: parent, base_xpath: parent_base).map do |node|
            credit_transfer(node, provider_identifier)
          end
        end
      end

      def credit_transfer(node, provider_identifier)
        base = group_xpath('BG-17')
        account = term_for(:credit_transfer, 'BG-17', :account_identifier)
        attributes = scalar_attributes(:credit_transfer, 'BG-17', context: node, base_xpath: base,
                                                                  except: [:account_identifier])
        CreditTransfer.new(**attributes, account_identifier: identifier(account.id, context: node, base_xpath: base),
                                         provider_identifier:)
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
