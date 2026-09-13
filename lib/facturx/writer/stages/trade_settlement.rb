# frozen_string_literal: true

require_relative 'trade_settlement/parties'
require_relative 'trade_settlement/payment'
require_relative 'trade_settlement/taxes'
require_relative 'trade_settlement/summary'

module Facturx
  class Writer
    module Stages
      class TradeSettlement < Stage
        include TradeSettlementParties
        include TradeSettlementPayment
        include TradeSettlementTaxes
        include TradeSettlementSummary

        term_ids(*%w[
                   BT-90 BT-83 BT-6 BT-5 BT-60 BT-60-1 BT-59 BT-61 BT-61-1 BT-81 BT-82 BT-87 BT-88 BT-91 BT-84
                   BT-85 BT-86 BT-117 BT-120 BT-116 BT-118 BT-121 BT-7 BT-8 BT-119 BT-73 BT-74 BT-94 BT-93 BT-92
                   BT-98 BT-97 BT-95 BT-96 BT-101 BT-100 BT-99 BT-105 BT-104 BT-102 BT-103 BT-20 BT-9 BT-89 BT-106
                   BT-108 BT-107 BT-109 BT-110 BT-111 BT-114 BT-112 BT-113 BT-115 BT-25 BT-26 BT-19
                 ])

        def call
          node = context.element(context.transaction, 'ram:ApplicableHeaderTradeSettlement')
          payment = document.payment
          emit_header(node, payment)
          emit_content(node, payment)
        end

        private

        def emit_header(parent, payment)
          direct_debit = payment&.direct_debit
          emit_identifier_value('BT-90', direct_debit&.creditor_identifier, 'ram:CreditorReferenceID', parent)
          emit('BT-83', payment&.remittance_information, element: 'ram:PaymentReference', parent:)
          emit('BT-6', tax_currency_term_value, element: 'ram:TaxCurrencyCode', parent:)
          emit('BT-5', document.currency, element: 'ram:InvoiceCurrencyCode', parent:)
        end

        def tax_currency_term_value
          return if profile.id == :minimum && document.totals&.tax_total_in_tax_currency

          document.tax_currency
        end

        def emit_content(parent, payment)
          payee(parent)
          payment_means(parent, payment)
          taxes(parent)
          billing_period(parent)
          document_adjustments(parent)
          settlement_summary(parent, payment&.direct_debit)
        end

        def document_adjustments(parent)
          adjustments(parent, document.allowances, 'BG-20', false)
          adjustments(parent, document.charges, 'BG-21', true)
        end

        def settlement_summary(parent, direct_debit)
          payment_terms(parent, direct_debit)
          totals(parent)
          preceding_invoices(parent)
          accounting_reference(parent)
        end
      end
    end
  end
end
