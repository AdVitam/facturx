# frozen_string_literal: true

EuEinvoice::TermDeclarations::PRODUCTS = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-157',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:GlobalID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-157-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-155',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:SellerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-156',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:BuyerAssignedID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-153',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:Name',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-154',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:Description',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-160',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic/ram:Description',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-161',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic/ram:Value',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-158',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:DesignatedProductClassification/ram:ClassCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-158-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:DesignatedProductClassification/ram:ClassCode/@listID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-158-2',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:DesignatedProductClassification/ram:ClassCode/@listVersionID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-159',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:OriginTradeCountry/ram:ID',
    :string
  )
].freeze
