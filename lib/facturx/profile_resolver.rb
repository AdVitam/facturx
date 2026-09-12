# frozen_string_literal: true

require_relative 'error'
require_relative 'profile'
require_relative 'profiles'

module Facturx
  class ProfileResolver
    def initialize(profiles: Profiles)
      @profiles = profiles
    end

    def call(profile)
      canonical = resolve(profile)
      return canonical unless profile.is_a?(Profile) && !profile.equal?(canonical)

      unsupported!(profile)
    rescue KeyError
      unsupported!(profile)
    end

    private

    def resolve(profile)
      case profile
      when Symbol then @profiles.fetch(profile)
      when Profile then @profiles.fetch(profile.id)
      else unsupported!(profile)
      end
    end

    def unsupported!(profile)
      identifier = profile.respond_to?(:id) ? profile.id : profile
      raise UnsupportedProfileError.new('Factur-X profile is unsupported', profile: identifier)
    end
  end
end
