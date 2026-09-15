# frozen_string_literal: true

EuEinvoice::TermDeclarations::GROUPS = [
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-2',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-1',
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IncludedNote'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-32',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-30',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-26',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:BillingSpecifiedPeriod'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-27',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-27-0',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-27-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator' \
    '/udt:Indicator'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-28',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-28-0',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-28-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator' \
    '/udt:Indicator'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-6',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:DefinedTradeContact'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-5',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-9',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:DefinedTradeContact'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-8',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-11',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-12',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-24',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-13-00',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-13',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-15',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-10',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-16',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-18',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-17',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-23',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-14',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:BillingSpecifiedPeriod'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-20',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-20-0',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-20-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-21',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-21-0',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-21-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-22',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation'
  ),
  EuEinvoice::TermDeclarations::Declaration.group(
    'BG-3',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:InvoiceReferencedDocument'
  )
].freeze
