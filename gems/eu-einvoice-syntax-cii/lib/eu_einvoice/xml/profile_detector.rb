# frozen_string_literal: true

require 'eu_einvoice/error'
require 'eu_einvoice/xml/namespaces'

module EuEinvoice
  module Xml
    class ProfileDetector
      NAMESPACES = Namespaces::MAP
      GUIDELINE_XPATH = '/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext/' \
                        'ram:GuidelineSpecifiedDocumentContextParameter/ram:ID'

      def initialize(profiles:)
        @profiles = profiles.to_h { |profile| [profile.guideline_urn, profile] }.freeze
      end

      def call(document:)
        guideline_urn = document.at_xpath(GUIDELINE_XPATH, NAMESPACES)&.text
        profile = @profiles[guideline_urn]
        return profile if profile

        message = guideline_urn.nil? || guideline_urn.empty? ? 'Factur-X BT-24 is missing' : 'Factur-X BT-24 is unknown'
        raise UnknownProfileError.new(message, guideline_urn: guideline_urn)
      end
    end
  end
end
