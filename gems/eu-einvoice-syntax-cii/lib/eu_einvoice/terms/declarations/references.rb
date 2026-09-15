# frozen_string_literal: true

EuEinvoice::TermDeclarations::REFERENCES = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-122',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-124',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:URIID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-123',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:Name',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-125',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject',
    :binary
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-125-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject/@mimeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-125-2',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject/@filename',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:InvoiceReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-26',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:InvoiceReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString',
    :date_102
  )
].freeze
