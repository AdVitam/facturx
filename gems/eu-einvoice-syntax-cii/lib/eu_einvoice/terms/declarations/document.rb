# frozen_string_literal: true

EuEinvoice::TermDeclarations::DOCUMENT = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-23',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext' \
    '/ram:BusinessProcessSpecifiedDocumentContextParameter/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-24',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext' \
    '/ram:GuidelineSpecifiedDocumentContextParameter/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-1',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-3',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:TypeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-2',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString',
    :date_102
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-22',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IncludedNote/ram:Content',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-21',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IncludedNote/ram:SubjectCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-10',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerReference',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-14',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerOrderReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-13',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-12',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:ContractReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-17',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-18',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-18-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument/ram:ReferenceTypeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-11',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SpecifiedProcuringProject/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-16',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:DespatchAdviceReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-15',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ReceivingAdviceReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-6',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:TaxCurrencyCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-5',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:InvoiceCurrencyCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax/ram:TaxPointDate/udt:DateString',
    :date_102
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-20',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradePaymentTerms/ram:Description',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-9',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString',
    :date_102
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ReceivableSpecifiedTradeAccountingAccount/ram:ID',
    :string
  )
].freeze
