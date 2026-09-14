# frozen_string_literal: true

require_relative 'error'

module Facturx
  module Schematron
    class Registry
      RuleSet = Data.define(:directory, :stylesheet, :code_db)
      RULES_ROOT = File.expand_path('rules/1.09.2', __dir__)
      ENTRIES = {
        minimum: %w[minimum FACTUR-X_MINIMUM],
        basic_wl: %w[basic-wl FACTUR-X_BASIC-WL],
        basic: %w[basic FACTUR-X_BASIC],
        en16931: %w[en16931 FACTUR-X_EN16931],
        extended: %w[extended FACTUR-X_EXTENDED]
      }.freeze
      private_constant :RULES_ROOT, :ENTRIES

      def initialize
        @rule_sets = {}
        @mutex = Mutex.new
      end

      def fetch(profile)
        @rule_sets[profile.id] || @mutex.synchronize do
          @rule_sets[profile.id] ||= build(profile)
        end
      end

      private

      def build(profile)
        directory_name, basename = ENTRIES.fetch(profile.id) { raise_unknown_profile(profile) }
        directory = File.join(RULES_ROOT, directory_name)
        rule_set = RuleSet.new(
          directory:,
          stylesheet: File.join(directory, "#{basename}.xslt"),
          code_db: File.join(directory, "#{basename}_codedb.xml")
        )
        ensure_readable!(rule_set, profile)
      end

      def ensure_readable!(rule_set, profile)
        missing = missing_artifacts(rule_set)
        return rule_set if missing.empty?

        raise RulePackError.new(
          "The Factur-X #{profile.id} Schematron rule pack is incomplete",
          reason: :missing_artifacts,
          profile: profile.id,
          missing:
        )
      end

      def missing_artifacts(rule_set)
        %i[stylesheet code_db].reject { |name| readable?(rule_set.public_send(name)) }
      end

      def readable?(path)
        File.file?(path) && File.readable?(path)
      end

      def raise_unknown_profile(profile)
        raise RulePackError.new(
          "No Schematron rule pack is registered for Factur-X profile #{profile.id.inspect}",
          reason: :unknown_profile,
          profile: profile.id
        )
      end
    end
  end
end
