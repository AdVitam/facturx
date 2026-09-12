# frozen_string_literal: true

require_relative '../profiles'
require_relative '../error'
require_relative 'namespaces'

module Facturx
  module Xml
    class ProfileDetector
      NAMESPACES = Namespaces::MAP
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
