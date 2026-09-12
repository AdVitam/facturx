# frozen_string_literal: true

require_relative 'attach'
require_relative 'profile_resolver'
require_relative 'writer'

module Facturx
  class Generate
    def initialize(writer: Writer.new, attacher: Attach.new, profile_resolver: ProfileResolver.new)
      @writer = writer
      @attacher = attacher
      @profile_resolver = profile_resolver
    end

    def call(pdf:, document:, profile:)
      canonical_profile = @profile_resolver.call(profile)
      xml = @writer.call(document:, profile: canonical_profile)
      @attacher.call(pdf:, xml:)
    end
  end
end
