# frozen_string_literal: true

class WriterDocumentFactory
  class << self
    private

    def settlement_attributes
      {
        payment_terms: 'Thirty days', payment: payment, tax_breakdowns: [tax],
        allowances: [adjustment(false)], charges: [adjustment(true)], totals: totals
      }
    end

    def payment
      EuEinvoice::PaymentInstructions.new(
        means_code: '58', means_text: 'Credit transfer', remittance_information: 'INV-1',
        credit_transfers: [credit_transfer], payment_card: payment_card, direct_debit: direct_debit
      )
    end

    def credit_transfer
      EuEinvoice::CreditTransfer.new(
        account_identifier: identifier('FR761234'), account_name: 'Main account',
        provider_identifier: identifier('BIC')
      )
    end

    def payment_card
      EuEinvoice::PaymentCard.new(primary_account_number: '1234', holder_name: 'Buyer')
    end

    def direct_debit
      EuEinvoice::DirectDebit.new(
        mandate_identifier: identifier('MANDATE'), creditor_identifier: identifier('CREDITOR'),
        debtor_account_identifier: identifier('FR769876')
      )
    end

    def tax
      EuEinvoice::TaxBreakdown.new(
        type_code: 'VAT', category_code: 'S', rate: decimal('20'), basis_amount: decimal('200'),
        tax_amount: decimal('40'), exemption_reason: 'None', exemption_reason_code: 'VATEX-EU-O',
        due_date_type_code: '35'
      )
    end

    def adjustment(indicator, tax: true)
      EuEinvoice::AllowanceCharge.new(
        indicator: indicator, amount: decimal('5'), base_amount: decimal('100'), percentage: decimal('5'),
        reason: 'Adjustment', reason_code: '95', tax: adjustment_tax(tax)
      )
    end

    def adjustment_tax(present)
      EuEinvoice::TaxBreakdown.new(category_code: 'S', rate: decimal('20')) if present
    end

    def totals
      EuEinvoice::Totals.new(
        line_total: decimal('200'), charge_total: decimal('5'), allowance_total: decimal('5'),
        tax_basis_total: decimal('200'), tax_total: decimal('40'), tax_total_in_tax_currency: decimal('44'),
        grand_total: decimal('240'), prepaid: decimal('10'), rounding: decimal('0'), due_payable: decimal('230')
      )
    end

    def decimal(value)
      BigDecimal(value)
    end
  end
end
