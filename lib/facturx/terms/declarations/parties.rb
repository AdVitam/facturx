# frozen_string_literal: true

Facturx::TermDeclarations::PARTIES = [
  Facturx::TermDeclarations::Declaration.term(
    'BT-29', :party, :identifiers, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:ID',
    :string, nil,
    basic_wl: '0..n',
    basic: '0..n',
    en16931: '0..n',
    extended: '0..n'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-29-1', :party, :identifiers, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:GlobalID/@schemeID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-27', :party, :name, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:Name',
    :string, nil,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-33', :party, :description, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:Description',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-30', :party, :legal_registration, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedLegalOrganization/ram:ID',
    :string, nil,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-30-1', :party, :legal_registration, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedLegalOrganization/ram:ID/@schemeID',
    :string, nil,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-28', :party, :trading_name, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedLegalOrganization/ram:TradingBusinessName',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-41', :contact, :name, 'BG-6',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:DefinedTradeContact/ram:PersonName',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-42', :contact, :telephone, 'BG-6',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication' \
    '/ram:CompleteNumber',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-43', :contact, :email, 'BG-6',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-38', :address, :postcode, 'BG-5',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-35', :address, :line_one, 'BG-5',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:LineOne',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-36', :address, :line_two, 'BG-5',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:LineTwo',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-162', :address, :line_three, 'BG-5',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:LineThree',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-37', :address, :city, 'BG-5',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:CityName',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-40', :address, :country_code, 'BG-5',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:CountryID',
    :string, nil,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-39', :address, :country_subdivision, 'BG-5',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-34', :party, :electronic_address, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-34-1', :party, :electronic_address, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-31', :party, :vat_identifier, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedTaxRegistration/ram:ID',
    :string, nil,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-32', :party, :tax_identifier, 'BG-4',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedTaxRegistration/ram:ID',
    :string, nil,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-46', :party, :identifiers, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:ID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-46-1', :party, :identifiers, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:GlobalID/@schemeID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-44', :party, :name, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:Name',
    :string, nil,
    minimum: '1..1',
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-47', :party, :legal_registration, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:SpecifiedLegalOrganization/ram:ID',
    :string, nil,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-47-1', :party, :legal_registration, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:SpecifiedLegalOrganization/ram:ID/@schemeID',
    :string, nil,
    minimum: '0..1',
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-45', :party, :trading_name, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:SpecifiedLegalOrganization/ram:TradingBusinessName',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-56', :contact, :name, 'BG-9',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:DefinedTradeContact/ram:PersonName',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-57', :contact, :telephone, 'BG-9',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication' \
    '/ram:CompleteNumber',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-58', :contact, :email, 'BG-9',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-53', :address, :postcode, 'BG-8',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-50', :address, :line_one, 'BG-8',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:LineOne',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-51', :address, :line_two, 'BG-8',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:LineTwo',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-163', :address, :line_three, 'BG-8',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:LineThree',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-52', :address, :city, 'BG-8',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:CityName',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-55', :address, :country_code, 'BG-8',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:CountryID',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-54', :address, :country_subdivision, 'BG-8',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-49', :party, :electronic_address, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-49-1', :party, :electronic_address, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-48', :party, :vat_identifier, 'BG-7',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:SpecifiedTaxRegistration/ram:ID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-62', :party, :name, 'BG-11',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:Name',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-67', :address, :postcode, 'BG-12',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-64', :address, :line_one, 'BG-12',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:LineOne',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-65', :address, :line_two, 'BG-12',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:LineTwo',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-164', :address, :line_three, 'BG-12',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:LineThree',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-66', :address, :city, 'BG-12',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:CityName',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-69', :address, :country_code, 'BG-12',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:CountryID',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-68', :address, :country_subdivision, 'BG-12',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-63', :party, :vat_identifier, 'BG-11',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:SpecifiedTaxRegistration/ram:ID',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-78', :address, :postcode, 'BG-15',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-75', :address, :line_one, 'BG-15',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:LineOne',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-76', :address, :line_two, 'BG-15',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:LineTwo',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-165', :address, :line_three, 'BG-15',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:LineThree',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-77', :address, :city, 'BG-15',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:CityName',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-80', :address, :country_code, 'BG-15',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:CountryID',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-79', :address, :country_subdivision, 'BG-15',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-60', :party, :identifiers, 'BG-10',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:ID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-60-1', :party, :identifiers, 'BG-10',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:GlobalID/@schemeID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-59', :party, :name, 'BG-10',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:Name',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-61', :party, :legal_registration, 'BG-10',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:ID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-61-1', :party, :legal_registration, 'BG-10',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:ID/@schemeID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  )
].freeze
