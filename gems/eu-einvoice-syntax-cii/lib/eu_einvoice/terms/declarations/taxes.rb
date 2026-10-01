# frozen_string_literal: true

EuEinvoice::TermDeclarations::TAXES = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-151',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-152',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-117',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax/ram:CalculatedAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-120',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax/ram:ExemptionReason',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-116',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax/ram:BasisAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-118',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax/ram:CategoryCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-121',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax/ram:ExemptionReasonCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-8',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax/ram:DueDateTypeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-119',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax/ram:RateApplicablePercent',
    :decimal
  )
].freeze
