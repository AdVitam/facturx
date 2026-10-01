# typed: strict

module EuEinvoice
  module Codes
    module DocumentType
      INVOICE = T.let('380', String)
      CREDIT_NOTE = T.let('381', String)
    end

    module PaymentMeans
      CASH = T.let('10', String)
      CREDIT_TRANSFER = T.let('30', String)
      PAYMENT_CARD = T.let('48', String)
      DIRECT_DEBIT = T.let('49', String)
      SEPA_CREDIT_TRANSFER = T.let('58', String)
      SEPA_DIRECT_DEBIT = T.let('59', String)
    end

    module VatCategory
      STANDARD = T.let('S', String)
      ZERO_RATED = T.let('Z', String)
      EXEMPT = T.let('E', String)
      REVERSE_CHARGE = T.let('AE', String)
      OUTSIDE_SCOPE = T.let('O', String)
      EXPORT = T.let('G', String)
      INTRA_COMMUNITY_SUPPLY = T.let('K', String)
    end
  end
end
