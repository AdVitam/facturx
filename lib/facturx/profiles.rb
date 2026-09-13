# frozen_string_literal: true

require_relative 'profile'

module Facturx
  module Profiles
    ALL = [
      Profile.new(
        id: :minimum,
        guideline_urn: 'urn:factur-x.eu:1p0:minimum',
        conformance_level: 'MINIMUM'
      ),
      Profile.new(
        id: :basic_wl,
        guideline_urn: 'urn:factur-x.eu:1p0:basicwl',
        conformance_level: 'BASIC WL'
      ),
      Profile.new(
        id: :basic,
        guideline_urn: 'urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic',
        conformance_level: 'BASIC'
      ),
      Profile.new(
        id: :en16931,
        guideline_urn: 'urn:cen.eu:en16931:2017',
        conformance_level: 'EN 16931'
      ),
      Profile.new(
        id: :extended,
        guideline_urn: 'urn:cen.eu:en16931:2017#conformant#urn:factur-x.eu:1p0:extended',
        conformance_level: 'EXTENDED'
      )
    ].freeze

    BY_ID = ALL.to_h { |profile| [profile.id, profile] }.freeze
    BY_GUIDELINE_URN = ALL.to_h { |profile| [profile.guideline_urn, profile] }.freeze
    private_constant :ALL, :BY_ID, :BY_GUIDELINE_URN

    module_function

    def all
      ALL
    end

    def fetch(id)
      BY_ID.fetch(id.to_sym)
    end

    def for_guideline_urn(guideline_urn)
      BY_GUIDELINE_URN[guideline_urn]
    end
  end
end
