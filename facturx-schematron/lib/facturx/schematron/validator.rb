# frozen_string_literal: true

require_relative 'error'
require_relative 'locator'
require_relative 'registry'
require_relative 'svrl_parser'

module Facturx
  module Schematron
    class Validator
      OUTPUT_LIMIT = 8 * 1_024 * 1_024
      SAXON_ARGUMENTS = %w[
        -s:-
        -dtd:off
        -expand:off
        -ext:off
        -xi:off
        -warnings:silent
        -versionmsg:off
      ].freeze
      private_constant :OUTPUT_LIMIT, :SAXON_ARGUMENTS

      def initialize(
        runner: Subprocess::Runner.new(output_limit: OUTPUT_LIMIT),
        locator: nil,
        registry: Registry.new,
        parser: SvrlParser.new
      )
        @runner = runner
        @locator = locator || Locator.new(runner:)
        @registry = registry
        @parser = parser
      end

      def preflight!
        @locator.preflight!
        self
      end

      def call(document:, profile:)
        result = transform(document, profile)
        raise_failed(result, profile) unless result.exit_status.zero?

        @parser.call(svrl: result.stdout)
      rescue Subprocess::Error => e
        raise ExecutionError.new(
          'SaxonC failed to execute the Factur-X Schematron rules',
          reason: e.details[:reason],
          subprocess_error: e.details
        )
      end

      private

      def transform(document, profile)
        config = @locator.preflight!
        rule_set = @registry.fetch(profile)
        @runner.call(
          arguments(config.binary, rule_set.stylesheet),
          input: document.root.to_xml(encoding: 'UTF-8'),
          chdir: rule_set.directory
        )
      end

      def arguments(binary, stylesheet)
        [binary, *SAXON_ARGUMENTS, "-xsl:#{File.basename(stylesheet)}"]
      end

      def raise_failed(result, profile)
        raise ExecutionError.new(
          "SaxonC failed to validate the Factur-X #{profile.id} profile",
          reason: :nonzero_exit,
          profile: profile.id,
          exit_status: result.exit_status,
          stderr: sanitize(result.stderr)
        )
      end

      def sanitize(output)
        output.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '?').strip
      end
    end
  end
end
