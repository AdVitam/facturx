# frozen_string_literal: true

module Facturx
  CreditTransfer = Model.define(:account_identifier, :account_name, :provider_identifier)
  PaymentCard = Model.define(:primary_account_number, :holder_name)
  DirectDebit = Model.define(:mandate_identifier, :creditor_identifier, :debtor_account_identifier)
  PaymentInstructions = Model.define(:means_code, :means_text, :remittance_information, :credit_transfers,
                                     :payment_card, :direct_debit, collections: [:credit_transfers])
end
