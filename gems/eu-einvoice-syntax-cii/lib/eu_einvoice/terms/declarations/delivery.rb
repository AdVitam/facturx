# frozen_string_literal: true

EuEinvoice::TermDeclarations::DELIVERY = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-134',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:BillingSpecifiedPeriod/ram:StartDateTime' \
    '/udt:DateTimeString',
    :date_102
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-135',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedLineTradeSettlement/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString',
    :date_102
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-71',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-71-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:GlobalID/@schemeID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-70',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:Name',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-72',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString',
    :date_102
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-73',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:BillingSpecifiedPeriod/ram:StartDateTime/udt:DateTimeString',
    :date_102
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-74',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString',
    :date_102
  )
].freeze
