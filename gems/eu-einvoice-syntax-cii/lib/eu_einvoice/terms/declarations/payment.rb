# frozen_string_literal: true

EuEinvoice::TermDeclarations::PAYMENT = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-90',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:CreditorReferenceID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-83',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PaymentReference',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-81',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-82',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:Information',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-87',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-88',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard' \
    '/ram:CardholderName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-91',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerPartyDebtorFinancialAccount/ram:IBANID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-84',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount/ram:IBANID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-85',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount' \
    '/ram:AccountName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-86',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeeSpecifiedCreditorFinancialInstitution' \
    '/ram:BICID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-89',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradePaymentTerms/ram:DirectDebitMandateID',
    :string
  )
].freeze
