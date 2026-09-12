# frozen_string_literal: true

Facturx::TermDeclarations::GROUPS = [
  Facturx::TermDeclarations::Declaration.group(
    'BG-2', :document, nil, nil,
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext',
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-1', :note, :notes, nil,
    '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IncludedNote',
    basic_wl: '0..n',
    basic: '0..n',
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-25', :line, :lines, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem',
    basic: '1..n',
    en16931: '1..n',
    extended: '1..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-31', :product, :product, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-32', :product_attribute, :attributes, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic',
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-29', :line, nil, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-30', :tax_breakdown, :tax, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-26', :period, :period, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:BillingSpecifiedPeriod',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-27', :allowance_charge, :allowances, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge',
    basic: '0..n',
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-27-0', :allowance_charge, nil, 'BG-27',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-27-1', :allowance_charge, nil, 'BG-27',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator' \
    '/udt:Indicator',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-28', :allowance_charge, :charges, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge',
    basic: '0..n',
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-28-0', :allowance_charge, nil, 'BG-28',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-28-1', :allowance_charge, nil, 'BG-28',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator' \
    '/udt:Indicator',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-4', :party, :seller, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty',
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-6', :contact, :contact, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:DefinedTradeContact',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-5', :address, :address, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress',
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-7', :party, :buyer, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty',
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-9', :contact, :contact, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:DefinedTradeContact',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-8', :address, :address, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-11', :party, :tax_representative, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-12', :address, :address, 'BG-11',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-24', :supporting_document, :supporting_documents, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:AdditionalReferencedDocument',
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-13-00', :delivery, :delivery, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery',
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-13', :party, :party, 'BG-13-00',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-15', :address, :address, 'BG-13',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-19', :document, nil, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement',
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-10', :party, :payee, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-16', :payment_instructions, :payment, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-18', :payment_card, :payment_card, 'BG-16',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-17', :credit_transfer, :credit_transfers, 'BG-16',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount',
    basic_wl: '0..n',
    basic: '0..n',
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-23', :tax_breakdown, :tax_breakdowns, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:ApplicableTradeTax',
    basic_wl: '1..n',
    basic: '1..n',
    en16931: '1..n',
    extended: '1..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-14', :period, :billing_period, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:BillingSpecifiedPeriod',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-20', :allowance_charge, :allowances, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge',
    basic_wl: '0..n',
    basic: '0..n',
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-20-0', :allowance_charge, nil, 'BG-20',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-20-1', :allowance_charge, nil, 'BG-20',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-21', :allowance_charge, :charges, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge',
    basic_wl: '0..n',
    basic: '0..n',
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-21-0', :allowance_charge, nil, 'BG-21',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-21-1', :allowance_charge, nil, 'BG-21',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-22', :totals, :totals, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementHeaderMonetarySummation',
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.group(
    'BG-3', :document_reference, :preceding_invoices, nil,
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:InvoiceReferencedDocument',
    basic_wl: '0..n',
    basic: '0..n',
    en16931: '0..n',
    extended: '0..n'
  )
].freeze
