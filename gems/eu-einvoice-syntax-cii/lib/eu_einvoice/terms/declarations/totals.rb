# frozen_string_literal: true

EuEinvoice::TermDeclarations::TOTALS = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-106',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-108',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:ChargeTotalAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-107',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:AllowanceTotalAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-109',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-110',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-111',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-114',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RoundingAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-112',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-113',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalPrepaidAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-115',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount',
    :decimal
  )
].freeze
