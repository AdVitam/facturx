# frozen_string_literal: true

require_relative 'pdf/composer'
require_relative 'profile_resolver'
require_relative 'writer'

module Facturx
  class Generate
    def initialize(writer: Writer.new, pdf_composer: Pdf::Composer.new, profile_resolver: ProfileResolver.new)
      @writer = writer
      @pdf_composer = pdf_composer
      @profile_resolver = profile_resolver
    end

    def call(pdf:, document:, profile:)
      canonical_profile = @profile_resolver.call(profile)
      xml = @writer.call(document:, profile: canonical_profile)
      @pdf_composer.call(pdf:, xml:, profile: canonical_profile)
    end
  end
end
