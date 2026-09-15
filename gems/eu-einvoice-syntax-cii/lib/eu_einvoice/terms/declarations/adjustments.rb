# frozen_string_literal: true

EuEinvoice::TermDeclarations::ADJUSTMENTS = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-138',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:CalculationPercent',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-137',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:BasisAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-136',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ActualAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-140',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ReasonCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-139',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:Reason',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-143',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:CalculationPercent',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-142',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:BasisAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-141',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ActualAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-145',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ReasonCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-144',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:Reason',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-94',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:CalculationPercent',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-93',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:BasisAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-92',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ActualAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-98',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ReasonCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-97',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:Reason',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-95',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:CategoryTradeTax/ram:CategoryCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-96',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:CategoryTradeTax/ram:RateApplicablePercent',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-101',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:CalculationPercent',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-100',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:BasisAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-99',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ActualAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-105',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ReasonCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-104',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:Reason',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-102',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:CategoryTradeTax/ram:CategoryCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-103',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:CategoryTradeTax/ram:RateApplicablePercent',
    :decimal
  )
].freeze
