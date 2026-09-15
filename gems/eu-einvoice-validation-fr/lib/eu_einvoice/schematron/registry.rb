# frozen_string_literal: true

require 'eu_einvoice/schematron/error'
require 'eu_einvoice/france/manifest'
require 'digest'

module EuEinvoice
  module Schematron
    class Registry
      RuleSet = Data.define(:directory, :stylesheet, :code_db)
      ROOT = File.expand_path('rules', __dir__).freeze
      PACKAGE_ROOT = File.expand_path('../../..', __dir__).freeze

      def initialize(specification: nil, root: ROOT)
        @specification = specification
        @root = root
        @rule_sets = {}
        @mutex = Mutex.new
        France::Licensing.verify!(package: 'eu-einvoice-validation-fr', root: PACKAGE_ROOT)
      end

      def fetch(profile)
        @mutex.synchronize { @rule_sets[profile.id] ||= build(profile) }
      end

      def resources(profile:)
        manifest_for(profile).fetch(:optional_resources).transform_keys { |path| "schematron/#{path}" }.freeze
      end

      private

      def manifest_for(profile)
        return France::Manifest.for_profile(profile, version: '1.09.2') unless @specification
        return @specification.manifest if @specification.profile == profile

        raise RulePackError.new('Rule profile conflicts with its specification', profile: profile.id)
      rescue KeyError
        raise RulePackError.new('No rule pack is registered for this profile', reason: :unknown_profile,
                                                                               profile: profile.id)
      end

      def build(profile)
        manifest = manifest_for(profile)
        stylesheet = File.join(@root, manifest.fetch(:rule_entrypoint))
        rule_set = RuleSet.new(directory: File.dirname(stylesheet), stylesheet:,
                               code_db: File.join(@root, manifest.fetch(:code_list_entrypoint)))
        ensure_readable!(rule_set, profile)
        verify_checksums!(manifest)
        rule_set
      end

      def verify_checksums!(manifest)
        resources = manifest.fetch(:optional_resources)
        required = manifest.fetch_values(:rule_entrypoint, :code_list_entrypoint)
        unless required.all? { |path| resources.key?(path) }
          raise RulePackError.new('Rule entrypoints must be checksummed', reason: :missing_checksum)
        end

        resources.each do |path, expected|
          next if Digest::SHA256.file(File.join(@root, path)).hexdigest == expected

          raise RulePackError.new('Schematron resource checksum mismatch', reason: :checksum_mismatch, resource: path)
        end
      end

      def ensure_readable!(rule_set, profile)
        missing = %i[stylesheet code_db].reject { |name| readable?(rule_set.public_send(name)) }
        return rule_set if missing.empty?

        raise RulePackError.new('Schematron rule pack is incomplete', reason: :missing_artifacts, profile: profile.id,
                                                                      missing:)
      end

      def readable?(path)
        File.file?(path) && File.readable?(path)
      end
    end
  end
end
