# frozen_string_literal: true

Facturx::TermDeclarations::LINES = [
  Facturx::TermDeclarations::Declaration.term(
    'BT-126', :line, :id, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:AssociatedDocumentLineDocument/ram:LineID',
    :string, nil,
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-127', :line, :note, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:AssociatedDocumentLineDocument/ram:IncludedNote/ram:Content',
    :string, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-132', :line, :buyer_order_reference, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:LineID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-148', :line, :gross_price, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:ChargeAmount',
    :decimal, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-149-1', :line, :gross_price, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:BasisQuantity',
    :decimal, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-150-1', :line, :gross_price, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:BasisQuantity/@unitCode',
    :string, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-147-01', :line, :gross_price, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge' \
    '/ram:ChargeIndicator',
    :boolean, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-147-02', :line, :gross_price, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge' \
    '/ram:ChargeIndicator/udt:Indicator',
    :boolean, nil,
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-147', :line, :gross_price, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge' \
    '/ram:ActualAmount',
    :decimal, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-146', :line, :net_price, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount',
    :decimal, nil,
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-149', :line, :net_price, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:BasisQuantity',
    :decimal, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-150', :line, :net_price, 'BG-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:BasisQuantity/@unitCode',
    :string, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-129', :line, :quantity, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity',
    :decimal, nil,
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-130', :line, :quantity, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity/@unitCode',
    :string, nil,
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-131', :line, :net_amount, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation' \
    '/ram:LineTotalAmount',
    :decimal, 2,
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-128', :line, :invoiced_object_identifier, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:AdditionalReferencedDocument/ram:IssuerAssignedID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-128-1', :line, :invoiced_object_identifier, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:AdditionalReferencedDocument/ram:ReferenceTypeCode',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-133', :line, :buyer_accounting_reference, 'BG-25',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:ReceivableSpecifiedTradeAccountingAccount/ram:ID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  )
].freeze
