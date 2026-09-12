# frozen_string_literal: true

Facturx::TermDeclarations::DELIVERY = [
  Facturx::TermDeclarations::Declaration.term(
    'BT-134', :period, :start_date, 'BG-26',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:BillingSpecifiedPeriod/ram:StartDateTime' \
    '/udt:DateTimeString',
    :date_102, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-135', :period, :end_date, 'BG-26',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString',
    :date_102, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-71', :delivery, :location_identifier, 'BG-13',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:ID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-71-1', :delivery, :location_identifier, 'BG-13',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:GlobalID/@schemeID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-70', :delivery, :party, 'BG-13',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:Name',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-72', :delivery, :date, 'BG-13-00',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString',
    :date_102, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-73', :period, :start_date, 'BG-14',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:BillingSpecifiedPeriod/ram:StartDateTime/udt:DateTimeString',
    :date_102, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-74', :period, :end_date, 'BG-14',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString',
    :date_102, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  )
].freeze
