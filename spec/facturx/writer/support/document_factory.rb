# frozen_string_literal: true

require_relative 'document_factory/lines'
require_relative 'document_factory/parties'
require_relative 'document_factory/settlement'

class WriterDocumentFactory
  class << self
    def complete_document(profile)
      Facturx::Document.new(
        **header_attributes(profile), **reference_attributes, **party_attributes,
        **trade_attributes, **settlement_attributes
      )
    end

    def conforming_fixture_document(profile_id)
      document = fixture_document(profile_id)
      document.with(**conforming_attributes(document, profile_id))
    end

    private

    def header_attributes(profile)
      {
        guideline_urn: profile.guideline_urn, business_process: 'PROCESS', invoice_number: 'INV-1',
        issue_date: Date.new(2026, 9, 12), type_code: '380', currency: 'EUR', tax_currency: 'USD',
        vat_point_date: Date.new(2026, 9, 11), vat_point_date_code: '35',
        payment_due_date: Date.new(2026, 10, 12), buyer_reference: 'BUYER'
      }
    end

    def reference_attributes
      {
        project_reference: reference('PROJECT', name: 'Project'), contract_reference: reference('CONTRACT'),
        purchase_order_reference: reference('PURCHASE'), sales_order_reference: reference('SALES'),
        receiving_advice_reference: reference('RECEIVING'), despatch_advice_reference: reference('DESPATCH'),
        tender_or_lot_reference: reference('TENDER'), invoiced_object_identifier: identifier('OBJECT', 'OBJ'),
        buyer_accounting_reference: 'ACCOUNTING',
        preceding_invoices: [reference('PREVIOUS', issue_date: Date.new(2026, 8, 12))],
        supporting_documents: [supporting_document]
      }
    end

    def trade_attributes
      {
        delivery: delivery, billing_period: period, lines: [line], notes: [note]
      }
    end

    def note
      Facturx::Note.new(content: 'Note', subject_code: 'AAI')
    end

    def identifier(value, scheme_id = nil)
      Facturx::Identifier.new(value:, scheme_id:)
    end

    def reference(id, name: nil, issue_date: nil)
      Facturx::DocumentReference.new(id:, name:, issue_date:)
    end

    def delivery
      party = Facturx::Party.new(name: 'Delivery party', address: address)
      Facturx::Delivery.new(location_identifier: identifier('DELIVERY', '0088'), party:,
                            date: Date.new(2026, 9, 13))
    end

    def period
      Facturx::Period.new(start_date: Date.new(2026, 9, 1), end_date: Date.new(2026, 9, 30))
    end

    def supporting_document
      Facturx::SupportingDocument.new(
        reference: 'SUPPORT', description: 'Attachment', external_location: 'https://example.test/document',
        content: "binary\x00".b, mime_code: 'application/pdf', filename: 'document.pdf'
      )
    end

    def fixture_document(profile_id)
      Facturx::Reader.new.call(File.binread("spec/fixtures/xml/#{profile_id}.xml")).document
    end

    def conforming_attributes(document, profile_id)
      {
        seller: document.seller.with(address: conforming_seller_address(profile_id)),
        buyer: conforming_buyer(document, profile_id),
        tax_breakdowns: conforming_taxes(document), lines: conforming_lines(document.lines, profile_id)
      }
    end

    def conforming_seller_address(profile_id)
      return Facturx::Address.new(country_code: 'FR') if profile_id == :minimum

      address
    end

    def conforming_buyer(document, profile_id)
      return document.buyer if profile_id == :minimum

      document.buyer.with(address: address)
    end

    def conforming_taxes(document)
      document.tax_breakdowns.map do |tax_breakdown|
        tax_breakdown.with(tax_amount: BigDecimal('20'), basis_amount: BigDecimal('100'))
      end
    end

    def conforming_lines(lines, profile_id)
      return lines unless profile_id == :extended

      exemplar = fixture_document(:en16931).lines.first
      lines.map do |line_item|
        line_item.with(net_price: exemplar.net_price, quantity: exemplar.quantity, tax: exemplar.tax)
      end
    end
  end
end
