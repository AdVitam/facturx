# frozen_string_literal: true

Facturx::TermDeclarations::PRODUCTS = [
  Facturx::TermDeclarations::Declaration.term(
    'BT-157', :product, :global_identifier, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:GlobalID',
    :string, nil,
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-157-1', :product, :global_identifier, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID',
    :string, nil,
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-155', :product, :seller_identifier, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:SellerAssignedID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-156', :product, :buyer_identifier, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:BuyerAssignedID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-153', :product, :name, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:Name',
    :string, nil,
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-154', :product, :description, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:Description',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-160', :product_attribute, :name, 'BG-32',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic/ram:Description',
    :string, nil,
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-161', :product_attribute, :value, 'BG-32',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic/ram:Value',
    :string, nil,
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-158', :product_classification, :code, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:DesignatedProductClassification/ram:ClassCode',
    :string, nil,
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-158-1', :product_classification, :list_id, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:DesignatedProductClassification/ram:ClassCode/@listID',
    :string, nil,
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-158-2', :product_classification, :list_version_id, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:DesignatedProductClassification/ram:ClassCode/@listVersionID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-159', :product, :origin_country_code, 'BG-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem' \
    '/ram:SpecifiedTradeProduct/ram:OriginTradeCountry/ram:ID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  )
].freeze
