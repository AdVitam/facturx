# frozen_string_literal: true

module Facturx
  module Xml
    module Namespaces
      CII = 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100'
      QUALIFIED = 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100'
      REUSABLE = 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'
      UNQUALIFIED = 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100'

      MAP = {
        'qdt' => QUALIFIED,
        'ram' => REUSABLE,
        'rsm' => CII,
        'udt' => UNQUALIFIED
      }.freeze
    end
  end
end
