# frozen_string_literal: true

require 'rubygems/version'
require_relative 'runner'

module Facturx
  module Composers
    class Ghostscript
      class VersionProbe
        MINIMUM_VERSION = Gem::Version.new('9.54')
        VERSION_PATTERN = /\A\d+(?:\.\d+)+\z/

        def initialize(runner: Runner.new)
          @runner = runner
        end

        def call(binary)
          validate(parse(@runner.call([binary, '--version']).stdout))
        rescue CompositionError => e
          raise_probe_failure(e)
        end

        private

        def parse(output)
          value = output.to_s.lines.first.to_s.strip
          raise_missing_version if value.empty?
          raise_invalid_version unless VERSION_PATTERN.match?(value)
          Gem::Version.new(value)
        end

        def validate(version)
          return version if version >= MINIMUM_VERSION

          raise ComposerUnavailableError.new(
            "Ghostscript #{version} is unsupported; version #{MINIMUM_VERSION} or newer is required",
            reason: :unsupported_version,
            detected_version: version.to_s,
            minimum_version: MINIMUM_VERSION.to_s
          )
        end

        def raise_missing_version
          raise ComposerUnavailableError.new('Ghostscript did not report its version', reason: :missing_version)
        end

        def raise_invalid_version
          raise ComposerUnavailableError.new('Ghostscript reported an invalid version', reason: :invalid_version)
        end

        def raise_probe_failure(error)
          raise ComposerUnavailableError.new(
            'Unable to determine the Ghostscript version',
            reason: :version_unavailable,
            probe_error: error.details
          ), cause: error
        end
      end
    end
  end
end
