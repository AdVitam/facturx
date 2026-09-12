# frozen_string_literal: true

Facturx::TermDeclarations::REFERENCES = [
  Facturx::TermDeclarations::Declaration.term(
    'BT-122', :supporting_document, :reference, 'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-124', :supporting_document, :external_location, 'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:URIID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-123', :supporting_document, :description, 'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:Name',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-125', :supporting_document, :content, 'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject',
    :binary, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-125-1', :supporting_document, :mime_code, 'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject/@mimeCode',
    :string, nil,
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-125-2', :supporting_document, :filename, 'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject/@filename',
    :string, nil,
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-25', :document_reference, :id, 'BG-3',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:InvoiceReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-26', :document_reference, :issue_date, 'BG-3',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:InvoiceReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString',
    :date_102, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  )
].freeze
