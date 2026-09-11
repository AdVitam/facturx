# frozen_string_literal: true

require_relative 'profile'

module Facturx
  module Profiles
    SPECIFICATION_VERSION = '1.09.2'
    SCHEMA_ROOT = File.expand_path("schema/#{SPECIFICATION_VERSION}", __dir__).freeze

    ALL = [
      Profile.new(
        id: :minimum,
        guideline_urn: 'urn:factur-x.eu:1p0:minimum',
        xsd_path: File.join(SCHEMA_ROOT, 'minimum/Factur-X_1.09.2_MINIMUM.xsd').freeze,
        conformance_level: 'MINIMUM'
      ),
      Profile.new(
        id: :basic_wl,
        guideline_urn: 'urn:factur-x.eu:1p0:basicwl',
        xsd_path: File.join(SCHEMA_ROOT, 'basic-wl/Factur-X_1.09.2_BASICWL.xsd').freeze,
        conformance_level: 'BASIC WL'
      ),
      Profile.new(
        id: :basic,
        guideline_urn: 'urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic',
        xsd_path: File.join(SCHEMA_ROOT, 'basic/Factur-X_1.09.2_BASIC.xsd').freeze,
        conformance_level: 'BASIC'
      ),
      Profile.new(
        id: :en16931,
        guideline_urn: 'urn:cen.eu:en16931:2017',
        xsd_path: File.join(SCHEMA_ROOT, 'en16931/Factur-X_1.09.2_EN16931.xsd').freeze,
        conformance_level: 'EN 16931'
      ),
      Profile.new(
        id: :extended,
        guideline_urn: 'urn:cen.eu:en16931:2017#conformant#urn:factur-x.eu:1p0:extended',
        xsd_path: File.join(SCHEMA_ROOT, 'extended/Factur-X_1.09.2_EXTENDED.xsd').freeze,
        conformance_level: 'EXTENDED'
      )
    ].freeze

    BY_ID = ALL.to_h { |profile| [profile.id, profile] }.freeze
    BY_GUIDELINE_URN = ALL.to_h { |profile| [profile.guideline_urn, profile] }.freeze

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
