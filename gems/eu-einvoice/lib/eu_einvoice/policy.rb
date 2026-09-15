# frozen_string_literal: true

require 'eu_einvoice/model/immutable'

module EuEinvoice
  class Policy
    attr_reader :preferences

    def initialize(preferences: {})
      unless preferences.all? { |countries, id| countries.is_a?(Array) && countries.size == 2 && id.is_a?(String) }
        raise ArgumentError, 'Preferences map seller/buyer country pairs to specification identities'
      end

      @preferences = Model.copy_and_freeze(preferences)
      freeze
    end

    def preferred_id(document)
      preferences[[document.seller&.address&.country_code, document.buyer&.address&.country_code]]
    end
  end
end
