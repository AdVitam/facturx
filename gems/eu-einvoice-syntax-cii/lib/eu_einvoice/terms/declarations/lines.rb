# frozen_string_literal: true

EuEinvoice::TermDeclarations::LINES = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-126',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:AssociatedDocumentLineDocument/ram:LineID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-127',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:AssociatedDocumentLineDocument/ram:IncludedNote/ram:Content',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-132',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:LineID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-148',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:ChargeAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-149-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:BasisQuantity',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-150-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:BasisQuantity/@unitCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-147-01',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice' \
    '/ram:AppliedTradeAllowanceCharge/ram:ChargeIndicator',
    :boolean
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-147-02',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice' \
    '/ram:AppliedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator',
    :boolean
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-147',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice' \
    '/ram:AppliedTradeAllowanceCharge/ram:ActualAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-146',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-149',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:BasisQuantity',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-150',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:BasisQuantity/@unitCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-129',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-130',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity/@unitCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-131',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation' \
    '/ram:LineTotalAmount',
    :decimal
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-128',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:AdditionalReferencedDocument/ram:IssuerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-128-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:AdditionalReferencedDocument/ram:ReferenceTypeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-133',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:ReceivableSpecifiedTradeAccountingAccount/ram:ID',
    :string
  )
].freeze
