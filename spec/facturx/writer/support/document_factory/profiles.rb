# frozen_string_literal: true

class WriterDocumentFactory
  class << self
    def maximal_document(profile)
      document = complete_document(profile)

      case profile.id
      when :minimum then minimum_document(document)
      when :basic_wl then lower_profile_document(document, lines: [])
      when :basic then lower_profile_document(document, lines: [basic_line(document.lines.first)])
      else document
      end
    end

    private

    def minimum_document(document)
      Facturx::Document.new(
        guideline_urn: document.guideline_urn, business_process: document.business_process,
        invoice_number: document.invoice_number, issue_date: document.issue_date, type_code: document.type_code,
        buyer_reference: document.buyer_reference, purchase_order_reference: document.purchase_order_reference,
        currency: document.currency, tax_currency: document.tax_currency, seller: minimum_seller(document.seller),
        buyer: minimum_buyer(document.buyer), delivery: Facturx::Delivery.new,
        totals: minimum_totals(document.totals)
      )
    end

    def lower_profile_document(document, lines:)
      document.with(
        sales_order_reference: nil, tender_or_lot_reference: nil, invoiced_object_identifier: nil,
        project_reference: nil, receiving_advice_reference: nil, vat_point_date: nil,
        supporting_documents: [], seller: lower_profile_seller(document.seller),
        buyer: lower_profile_buyer(document.buyer), payment: lower_profile_payment(document.payment),
        lines:, totals: document.totals.with(rounding: nil)
      )
    end

    def minimum_seller(party)
      Facturx::Party.new(
        name: party.name, legal_registration: party.legal_registration,
        address: Facturx::Address.new(country_code: party.address.country_code),
        vat_identifier: party.vat_identifier, tax_identifier: party.tax_identifier
      )
    end

    def minimum_buyer(party)
      Facturx::Party.new(name: party.name, legal_registration: party.legal_registration)
    end

    def minimum_totals(totals)
      Facturx::Totals.new(
        tax_basis_total: totals.tax_basis_total, tax_total: totals.tax_total,
        tax_total_in_tax_currency: totals.tax_total_in_tax_currency,
        grand_total: totals.grand_total, due_payable: totals.due_payable
      )
    end

    def lower_profile_seller(party)
      party.with(description: nil, contact: nil)
    end

    def lower_profile_buyer(party)
      party.with(trading_name: nil, contact: nil)
    end

    def lower_profile_payment(payment)
      transfers = payment.credit_transfers.map do |transfer|
        transfer.with(account_name: nil, provider_identifier: nil)
      end
      payment.with(means_text: nil, credit_transfers: transfers, payment_card: nil)
    end

    def basic_line(line)
      line.with(
        product: basic_product(line.product), allowances: basic_adjustments(line.allowances),
        charges: basic_adjustments(line.charges), buyer_order_reference: nil,
        buyer_accounting_reference: nil, invoiced_object_identifier: nil
      )
    end

    def basic_product(product)
      product.with(
        description: nil, seller_identifier: nil, buyer_identifier: nil, origin_country_code: nil,
        attributes: [], classifications: []
      )
    end

    def basic_adjustments(adjustments)
      adjustments.map { |item| item.with(base_amount: nil, percentage: nil, tax: nil) }
    end
  end
end
