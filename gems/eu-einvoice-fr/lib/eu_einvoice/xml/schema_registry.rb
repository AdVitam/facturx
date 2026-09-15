# frozen_string_literal: true

require 'eu_einvoice/france/manifest'

module EuEinvoice
  module Xml
    class SchemaRegistry
      PACKAGE_ROOT = File.expand_path('../../..', __dir__).freeze

      def initialize(specification: nil, root: France::Manifest::ROOT)
        @specification = specification
        @root = root
        @verified = {}
        @mutex = Mutex.new
        France::Licensing.verify!(package: 'eu-einvoice-fr', root: PACKAGE_ROOT)
      end

      def fetch(profile)
        manifest = manifest_for(profile)
        @mutex.synchronize { @verified[profile.id] ||= verified_resources(manifest) }
        File.join(@root, manifest.fetch(:schema_entrypoint))
      end

      def fingerprint(profile)
        resources = manifest_for(profile).fetch(:resources)
        Digest::SHA256.hexdigest(resources.sort.flatten.join("\0"))
      end

      private

      def manifest_for(profile)
        return France::Manifest.for_profile(profile, version: '1.09.2') unless @specification
        return @specification.manifest if @specification.profile == profile

        raise SchemaLoadError.new('Schema profile conflicts with its specification', profile: profile.id)
      end

      def verified_resources(manifest)
        resources = manifest.fetch(:resources)
        entrypoint = manifest.fetch(:schema_entrypoint)
        unless resources.key?(entrypoint)
          raise SchemaLoadError.new('Schema entrypoint is not checksummed',
                                    resource: entrypoint)
        end

        verify_checksums!(resources)
        resources
      end

      def verify_checksums!(resources)
        resources.each do |path, digest|
          next if Digest::SHA256.file(File.join(@root, path)).hexdigest == digest

          raise SchemaLoadError.new('Schema checksum mismatch', reason: :checksum_mismatch, resource: path)
        end
      end
    end
  end
end
