# frozen_string_literal: true

require 'eu_einvoice/france/manifest'
require 'eu_einvoice/france/adapter'

module EuEinvoice
  module France
    class Pack
      include EuEinvoice::Pack

      VERSION = '1.09.2'

      attr_reader :specifications

      def initialize(version: VERSION, ghostscript_locator: nil)
        raise UnsupportedProfileError.new('Unsupported Factur-X version', version:) unless version == VERSION

        @ghostscript_locator = ghostscript_locator || Composers::Ghostscript::Locator.new
        @specifications = Profiles.all.map do |profile|
          Specification.new(id: "factur-x/#{version}/#{profile.id}", version:, profile:,
                            manifest: Manifest.for_profile(profile, version:))
        end.freeze
        freeze
      end

      def specification(profile: :en16931)
        specifications.find { |item| item.profile.id == profile.to_sym } ||
          raise(UnsupportedProfileError.new('Unsupported Factur-X profile', profile:))
      end

      def adapter(validation:, limits: ResourceLimits.new)
        Adapter.new(specifications:, validation:, limits:)
      end

      def policy(profile: :en16931)
        Policy.new(preferences: { %w[FR FR] => specification(profile:).id })
      end

      def extract_xml(pdf:, limits: ResourceLimits.new)
        Pdf::Extractor.new(limits:, embedding: EMBEDDING).call(pdf).xml
      end

      def compose(pdf:, xml:, specification:, limits: ResourceLimits.new)
        backend = Composers::Ghostscript.new(embedding: EMBEDDING, limits:, locator: @ghostscript_locator)
        Pdf::Composer.new(limits:, embedding: EMBEDDING, backend:).call(pdf:, xml:, profile: specification.profile)
      end
    end
  end
end
