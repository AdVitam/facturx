# frozen_string_literal: true

Facturx::TermDeclarations::TOTALS = [
  Facturx::TermDeclarations::Declaration.term(
    'BT-106', :totals, :line_total, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount',
    :decimal, 2,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-108', :totals, :charge_total, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:ChargeTotalAmount',
    :decimal, 2,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-107', :totals, :allowance_total, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:AllowanceTotalAmount',
    :decimal, 2,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-109', :totals, :tax_basis_total, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount',
    :decimal, 2,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-110', :totals, :tax_total, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount',
    :decimal, 2,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-111', :totals, :tax_total_in_tax_currency, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount',
    :decimal, 2,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-114', :totals, :rounding, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RoundingAmount',
    :decimal, 2,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-112', :totals, :grand_total, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount',
    :decimal, 2,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-113', :totals, :prepaid, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalPrepaidAmount',
    :decimal, 2,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-115', :totals, :due_payable, 'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount',
    :decimal, 2,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  )
].freeze
