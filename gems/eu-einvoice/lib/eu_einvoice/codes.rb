# frozen_string_literal: true

module EuEinvoice
  module Codes
    module DocumentType
      INVOICE = '380'
      CREDIT_NOTE = '381'
    end

    module PaymentMeans
      CASH = '10'
      CREDIT_TRANSFER = '30'
      PAYMENT_CARD = '48'
      DIRECT_DEBIT = '49'
      SEPA_CREDIT_TRANSFER = '58'
      SEPA_DIRECT_DEBIT = '59'
    end

    module VatCategory
      STANDARD = 'S'
      ZERO_RATED = 'Z'
      EXEMPT = 'E'
      REVERSE_CHARGE = 'AE'
      OUTSIDE_SCOPE = 'O'
      EXPORT = 'G'
      INTRA_COMMUNITY_SUPPLY = 'K'
    end
  end
end
