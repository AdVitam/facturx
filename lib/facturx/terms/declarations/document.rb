# frozen_string_literal: true

Facturx::TermDeclarations::DOCUMENT = [
  Facturx::TermDeclarations::Declaration.term(
    'BT-23', :document, :business_process, 'BG-2',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext' \
    '/ram:BusinessProcessSpecifiedDocumentContextParameter/ram:ID',
    :string, nil,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-24', :document, :guideline_urn, 'BG-2',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext' \
    '/ram:GuidelineSpecifiedDocumentContextParameter/ram:ID',
    :string, nil,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-1', :document, :invoice_number, nil,
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:ID',
    :string, nil,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-3', :document, :type_code, nil,
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:TypeCode',
    :string, nil,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-2', :document, :issue_date, nil,
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString',
    :date_102, nil,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-22', :note, :content, 'BG-1',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IncludedNote/ram:Content',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-21', :note, :subject_code, 'BG-1',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IncludedNote/ram:SubjectCode',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-10', :document, :buyer_reference, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerReference',
    :string, nil,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-14', :document, :sales_order_reference, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerOrderReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-13', :document, :purchase_order_reference, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-12', :document, :contract_reference, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:ContractReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-17', :document, :tender_or_lot_reference, 'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-18', :document, :invoiced_object_identifier, 'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-18-1', :document, :invoiced_object_identifier, 'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:ReferenceTypeCode',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-11', :document, :project_reference, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SpecifiedProcuringProject/ram:ID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-16', :document, :despatch_advice_reference, 'BG-13-00',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:DespatchAdviceReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-15', :document, :receiving_advice_reference, 'BG-13-00',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ReceivingAdviceReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-6', :document, :tax_currency, 'BG-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:TaxCurrencyCode',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-5', :document, :currency, 'BG-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:InvoiceCurrencyCode',
    :string, nil,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-7', :document, :vat_point_date, 'BG-23',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax/ram:TaxPointDate/udt:DateString',
    :date_102, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-20', :document, :payment_terms, 'BG-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradePaymentTerms/ram:Description',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-9', :document, :payment_due_date, 'BG-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString',
    :date_102, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-19', :document, :buyer_accounting_reference, 'BG-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ReceivableSpecifiedTradeAccountingAccount/ram:ID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  )
].freeze
