# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      module TradeSettlementSummary
        private

        def payment_terms(parent, direct_debit)
          values = [document.payment_terms, document.payment_due_date, direct_debit&.mandate_identifier]
          return missing_payment_terms? unless values.any?

          container(parent, 'ram:SpecifiedTradePaymentTerms') do |node|
            emit('BT-20', document.payment_terms, element: 'ram:Description', parent: node)
            emit_date(node, 'BT-9', document.payment_due_date, wrapper: 'ram:DueDateDateTime')
            emit_identifier_value('BT-89', direct_debit&.mandate_identifier, 'ram:DirectDebitMandateID', node)
          end
        end

        def missing_payment_terms?
          observe?('BT-20', nil)
          observe?('BT-9', nil)
          observe?('BT-89', nil)
        end

        def totals(parent)
          within_group('BG-22', document.totals, element: 'ram:SpecifiedTradeSettlementHeaderMonetarySummation',
                                                 parent:) do |node, item|
            emit_subtotals(node, item)
            emit_tax_totals(node, item)
            emit_balance(node, item)
          end
        end

        def emit_subtotals(parent, totals)
          emit('BT-106', totals.line_total, element: 'ram:LineTotalAmount', parent:)
          emit('BT-108', totals.charge_total, element: 'ram:ChargeTotalAmount', parent:)
          emit('BT-107', totals.allowance_total, element: 'ram:AllowanceTotalAmount', parent:)
          emit('BT-109', totals.tax_basis_total, element: 'ram:TaxBasisTotalAmount', parent:)
        end

        def emit_tax_totals(parent, totals)
          emit('BT-110', totals.tax_total, element: 'ram:TaxTotalAmount', parent:,
                                           attributes: { 'currencyID' => document.currency })
          emit_tax_total_in_tax_currency(parent, totals.tax_total_in_tax_currency)
        end

        def emit_tax_total_in_tax_currency(parent, value)
          return observe?('BT-111', nil) unless value
          return unrepresentable('BT-111', 'Tax total requires a distinct tax currency') unless distinct_tax_currency?

          emit('BT-111', value, element: 'ram:TaxTotalAmount', parent:,
                               attributes: { 'currencyID' => document.tax_currency })
        end

        def distinct_tax_currency?
          tax_currency = document.tax_currency
          !tax_currency.to_s.strip.empty? && tax_currency != document.currency
        end

        def emit_balance(parent, totals)
          emit('BT-114', totals.rounding, element: 'ram:RoundingAmount', parent:)
          emit('BT-112', totals.grand_total, element: 'ram:GrandTotalAmount', parent:)
          emit('BT-113', totals.prepaid, element: 'ram:TotalPrepaidAmount', parent:)
          emit('BT-115', totals.due_payable, element: 'ram:DuePayableAmount', parent:)
        end

        def preceding_invoices(parent)
          each_group('BG-3', document.preceding_invoices,
                     element: 'ram:InvoiceReferencedDocument', parent:) do |node, item|
            emit('BT-25', item.id, element: 'ram:IssuerAssignedID', parent: node)
            emit_date(node, 'BT-26', item.issue_date, wrapper: 'ram:FormattedIssueDateTime',
                                                      value_element: 'qdt:DateTimeString')
          end
        end

        def accounting_reference(parent)
          value = document.buyer_accounting_reference
          return observe?('BT-19', nil) unless value

          container(parent, 'ram:ReceivableSpecifiedTradeAccountingAccount') do |node|
            emit('BT-19', value, element: 'ram:ID', parent: node)
          end
        end
      end
    end
  end
end
