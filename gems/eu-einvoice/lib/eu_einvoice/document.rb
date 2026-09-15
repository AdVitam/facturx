# frozen_string_literal: true

require 'eu_einvoice/model'

module EuEinvoice
  Document = Model.define(
    :semantic_version,
    :guideline_urn,
    :business_process,
    :invoice_number,
    :issue_date,
    :type_code,
    :currency,
    :tax_currency,
    :vat_point_date,
    :vat_point_date_code,
    :payment_due_date,
    :buyer_reference,
    :project_reference,
    :contract_reference,
    :purchase_order_reference,
    :sales_order_reference,
    :receiving_advice_reference,
    :despatch_advice_reference,
    :tender_or_lot_reference,
    :invoiced_object_identifier,
    :buyer_accounting_reference,
    :payment_terms,
    :notes,
    :seller,
    :buyer,
    :payee,
    :tax_representative,
    :delivery,
    :billing_period,
    :payment,
    :lines,
    :tax_breakdowns,
    :allowances,
    :charges,
    :totals,
    :preceding_invoices,
    :supporting_documents,
    collections: %i[notes lines tax_breakdowns allowances charges preceding_invoices supporting_documents],
    defaults: { semantic_version: '2017' }
  )
end
