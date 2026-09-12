# frozen_string_literal: true

Facturx::TermDeclarations::PAYMENT = [
  Facturx::TermDeclarations::Declaration.term(
    'BT-90', :direct_debit, :creditor_identifier, 'BG-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:CreditorReferenceID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-83', :payment_instructions, :remittance_information, 'BG-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:PaymentReference',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-81', :payment_instructions, :means_code, 'BG-16',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-82', :payment_instructions, :means_text, 'BG-16',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:Information',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-87', :payment_card, :primary_account_number, 'BG-18',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:ID',
    :string, nil,
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-88', :payment_card, :holder_name, 'BG-18',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard' \
    '/ram:CardholderName',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-91', :direct_debit, :debtor_account_identifier, 'BG-16',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerPartyDebtorFinancialAccount/ram:IBANID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-84', :credit_transfer, :account_identifier, 'BG-17',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount/ram:IBANID',
    :string, nil,
    basic_wl: '1..1',
    basic: '1..1',
    en16931: '1..1',
    extended: '1..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-85', :credit_transfer, :account_name, 'BG-17',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount/ram:AccountName',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-86', :credit_transfer, :provider_identifier, 'BG-16',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeeSpecifiedCreditorFinancialInstitution' \
    '/ram:BICID',
    :string, nil,
    en16931: '0..1',
    extended: '0..1'
  ),
  Facturx::TermDeclarations::Declaration.term(
    'BT-89', :direct_debit, :mandate_identifier, 'BG-19',
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
    '/ram:SpecifiedTradePaymentTerms/ram:DirectDebitMandateID',
    :string, nil,
    basic_wl: '0..1',
    basic: '0..1',
    en16931: '0..1',
    extended: '0..1'
  )
].freeze
