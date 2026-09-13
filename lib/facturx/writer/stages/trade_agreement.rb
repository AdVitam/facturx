# frozen_string_literal: true

require_relative 'trade_agreement/parties'
require_relative 'trade_agreement/references'

module Facturx
  class Writer
    module Stages
      class TradeAgreement < Stage
        include TradeAgreementSupport::Parties
        include TradeAgreementSupport::References

        SELLER_ADDRESS = {
          postcode: 'BT-38', line_one: 'BT-35', line_two: 'BT-36', line_three: 'BT-162', city: 'BT-37',
          country_code: 'BT-40', country_subdivision: 'BT-39'
        }.freeze
        BUYER_ADDRESS = {
          postcode: 'BT-53', line_one: 'BT-50', line_two: 'BT-51', line_three: 'BT-163', city: 'BT-52',
          country_code: 'BT-55', country_subdivision: 'BT-54'
        }.freeze
        REPRESENTATIVE_ADDRESS = {
          postcode: 'BT-67', line_one: 'BT-64', line_two: 'BT-65', line_three: 'BT-164', city: 'BT-66',
          country_code: 'BT-69', country_subdivision: 'BT-68'
        }.freeze
        SELLER_CONTACT = { name: 'BT-41', telephone: 'BT-42', email: 'BT-43' }.freeze
        BUYER_CONTACT = { name: 'BT-56', telephone: 'BT-57', email: 'BT-58' }.freeze

        term_ids(*%w[
                   BT-10 BT-29 BT-29-1 BT-27 BT-33 BT-30 BT-30-1 BT-28 BT-41 BT-42 BT-43 BT-38 BT-35 BT-36
                   BT-162 BT-37 BT-40 BT-39 BT-34 BT-34-1 BT-31 BT-32 BT-46 BT-46-1 BT-44 BT-47 BT-47-1 BT-45
                   BT-56 BT-57 BT-58 BT-53 BT-50 BT-51 BT-163 BT-52 BT-55 BT-54 BT-49 BT-49-1 BT-48 BT-62 BT-67
                   BT-64 BT-65 BT-164 BT-66 BT-69 BT-68 BT-63 BT-14 BT-13 BT-12 BT-17 BT-18 BT-18-1 BT-122 BT-124
                   BT-123 BT-125 BT-125-1 BT-125-2 BT-11
                 ])

        def call
          agreement = context.element(context.transaction, 'ram:ApplicableHeaderTradeAgreement')
          emit('BT-10', document.buyer_reference, element: 'ram:BuyerReference', parent: agreement)
          write_parties(agreement)
          write_references(agreement)
        end
      end
    end
  end
end
