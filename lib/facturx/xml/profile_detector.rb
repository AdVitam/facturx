# frozen_string_literal: true

require_relative '../profiles'
require_relative '../error'

module Facturx
  module Xml
    class ProfileDetector
      NAMESPACES = {
        'ram' => 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100',
        'rsm' => 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100'
      }.freeze
      GUIDELINE_XPATH = '/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext/' \
                        'ram:GuidelineSpecifiedDocumentContextParameter/ram:ID'

      def call(document:)
        guideline_urn = document.at_xpath(GUIDELINE_XPATH, NAMESPACES)&.text
        profile = Profiles.for_guideline_urn(guideline_urn)
        return profile if profile

        message = guideline_urn.nil? || guideline_urn.empty? ? 'Factur-X BT-24 is missing' : 'Factur-X BT-24 is unknown'
        raise UnknownProfileError.new(message, guideline_urn: guideline_urn)
      end
    end
  end
end
