# frozen_string_literal: true

require 'eu_einvoice/builders/association'

module EuEinvoice
  module Builders
    module Schema
      module_function

      def singular(model)
        Association.new(model:, collection: false, helper: nil)
      end

      def collection(model, helper)
        Association.new(model:, collection: true, helper:)
      end

      ASSOCIATIONS = {
        Note => {},
        Identifier => {},
        Period => {},
        Quantity => {},
        Contact => {},
        Address => {},
        Party => {
          identifiers: collection(Identifier, :identifier),
          legal_registration: singular(Identifier),
          address: singular(Address),
          vat_identifier: singular(Identifier),
          tax_identifier: singular(Identifier),
          electronic_address: singular(Identifier),
          contact: singular(Contact)
        },
        CreditTransfer => {
          account_identifier: singular(Identifier),
          provider_identifier: singular(Identifier)
        },
        PaymentCard => {},
        DirectDebit => {
          mandate_identifier: singular(Identifier),
          creditor_identifier: singular(Identifier),
          debtor_account_identifier: singular(Identifier)
        },
        PaymentInstructions => {
          credit_transfers: collection(CreditTransfer, :credit_transfer),
          payment_card: singular(PaymentCard),
          direct_debit: singular(DirectDebit)
        },
        DocumentReference => {},
        Delivery => {
          location_identifier: singular(Identifier),
          party: singular(Party)
        },
        SupportingDocument => {},
        ProductAttribute => {},
        ProductClassification => {},
        Product => {
          seller_identifier: singular(Identifier),
          buyer_identifier: singular(Identifier),
          global_identifier: singular(Identifier),
          attributes: collection(ProductAttribute, :attribute),
          classifications: collection(ProductClassification, :classification)
        },
        Price => {
          basis_quantity: singular(Quantity)
        },
        TaxBreakdown => {},
        AllowanceCharge => {
          tax: singular(TaxBreakdown)
        },
        Totals => {},
        Line => {
          product: singular(Product),
          quantity: singular(Quantity),
          gross_price: singular(Price),
          net_price: singular(Price),
          tax: singular(TaxBreakdown),
          period: singular(Period),
          allowances: collection(AllowanceCharge, :allowance),
          charges: collection(AllowanceCharge, :charge),
          buyer_order_reference: singular(DocumentReference),
          invoiced_object_identifier: singular(Identifier)
        },
        Document => {
          project_reference: singular(DocumentReference),
          contract_reference: singular(DocumentReference),
          purchase_order_reference: singular(DocumentReference),
          sales_order_reference: singular(DocumentReference),
          receiving_advice_reference: singular(DocumentReference),
          despatch_advice_reference: singular(DocumentReference),
          tender_or_lot_reference: singular(DocumentReference),
          invoiced_object_identifier: singular(Identifier),
          seller: singular(Party),
          buyer: singular(Party),
          payee: singular(Party),
          tax_representative: singular(Party),
          delivery: singular(Delivery),
          billing_period: singular(Period),
          payment: singular(PaymentInstructions),
          totals: singular(Totals),
          notes: collection(Note, :note),
          lines: collection(Line, :line),
          tax_breakdowns: collection(TaxBreakdown, :tax_breakdown),
          allowances: collection(AllowanceCharge, :allowance),
          charges: collection(AllowanceCharge, :charge),
          preceding_invoices: collection(DocumentReference, :preceding_invoice),
          supporting_documents: collection(SupportingDocument, :supporting_document)
        }
      }.transform_values(&:freeze).freeze
    end
  end
end
