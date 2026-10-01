# frozen_string_literal: true

EuEinvoice::TermDeclarations::PARTIES = [
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-29',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-29-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:GlobalID/@schemeID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-27',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:Name',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-33',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:Description',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-30',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedLegalOrganization/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-30-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedLegalOrganization/ram:ID/@schemeID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-28',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedLegalOrganization/ram:TradingBusinessName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-41',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:DefinedTradeContact/ram:PersonName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-42',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication' \
    '/ram:CompleteNumber',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-43',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-38',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-35',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:LineOne',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-36',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:LineTwo',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-162',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:LineThree',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-37',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:CityName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-40',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:CountryID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-39',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-34',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-34-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-31',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedTaxRegistration/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-32',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTradeParty/ram:SpecifiedTaxRegistration/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-46',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-46-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:GlobalID/@schemeID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-44',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:Name',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-47',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:SpecifiedLegalOrganization/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-47-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:SpecifiedLegalOrganization/ram:ID/@schemeID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-45',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:SpecifiedLegalOrganization/ram:TradingBusinessName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-56',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:DefinedTradeContact/ram:PersonName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-57',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication' \
    '/ram:CompleteNumber',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-58',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-53',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-50',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:LineOne',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-51',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:LineTwo',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-163',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:LineThree',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-52',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:CityName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-55',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:CountryID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-54',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-49',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-49-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-48',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:BuyerTradeParty/ram:SpecifiedTaxRegistration/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-62',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:Name',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-67',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-64',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:LineOne',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-65',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:LineTwo',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-164',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:LineThree',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-66',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:CityName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-69',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:CountryID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-68',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-63',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement' \
    '/ram:SellerTaxRepresentativeTradeParty/ram:SpecifiedTaxRegistration/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-78',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-75',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:LineOne',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-76',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:LineTwo',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-165',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:LineThree',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-77',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:CityName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-80',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:CountryID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-79',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery' \
    '/ram:ShipToTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-60',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-60-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:GlobalID/@schemeID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-59',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:Name',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-61',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:ID',
    :string
  ),
  EuEinvoice::TermDeclarations::Declaration.term(
    'BT-61-1',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:ID/@schemeID',
    :string
  )
].freeze
