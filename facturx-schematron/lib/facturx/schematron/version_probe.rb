# frozen_string_literal: true

require 'rubygems/version'
require_relative 'error'

module Facturx
  module Schematron
    class VersionProbe
      MINIMUM_VERSION = Gem::Version.new('12.10')
      VERSION_PATTERN = /SaxonC-(?<edition>HE|PE|EE)\s+(?<version>\d+(?:\.\d+)+)/
      private_constant :VERSION_PATTERN

      def initialize(runner:)
        @runner = runner
      end

      def call(binary)
        probe(binary)
      rescue Subprocess::Error => e
        raise UnavailableError.new(
          'Unable to execute SaxonC Transform',
          reason: :probe_failed,
          probe_error: e.details
        )
      end

      private

      def probe(binary)
        result = @runner.call([binary, '-?'])
        raise_failed(result) unless result.exit_status.zero?

        version = extract_version(result)
        raise_unsupported(version) if version < MINIMUM_VERSION

        version
      end

      def extract_version(result)
        match = VERSION_PATTERN.match([result.stdout, result.stderr].join("\n"))
        raise_unrecognized unless match

        Gem::Version.new(match[:version])
      end

      def raise_failed(result)
        raise UnavailableError.new(
          "SaxonC Transform probe failed with exit status #{result.exit_status}",
          reason: :probe_failed,
          exit_status: result.exit_status
        )
      end

      def raise_unrecognized
        raise UnavailableError.new(
          'Transform did not identify itself as SaxonC',
          reason: :unrecognized_engine
        )
      end

      def raise_unsupported(version)
        raise UnavailableError.new(
          "SaxonC #{version} is unsupported; version #{MINIMUM_VERSION} or newer is required",
          reason: :unsupported_version,
          detected_version: version.to_s,
          minimum_version: MINIMUM_VERSION.to_s
        )
      end
    end
  end
end
