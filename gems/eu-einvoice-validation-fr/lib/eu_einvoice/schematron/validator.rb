# frozen_string_literal: true

require 'eu_einvoice/schematron/error'
require 'eu_einvoice/schematron/locator'
require 'eu_einvoice/schematron/registry'
require 'eu_einvoice/schematron/svrl_parser'
require 'eu_einvoice/schematron/runner'

module EuEinvoice
  module Schematron
    class Validator
      SAXON_ARGUMENTS = %w[
        -s:-
        -dtd:off
        -expand:off
        -ext:off
        -xi:off
        -warnings:silent
        -versionmsg:off
      ].freeze
      private_constant :SAXON_ARGUMENTS

      def initialize(
        limits: ResourceLimits.new,
        runner: Runner.new(limits:),
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

      def resources(profile:)
        @registry.resources(profile:)
      end

      def call(document:, profile:)
        result = transform(document, profile)
        raise_truncated_output if result.stdout_truncated
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
        binary = @locator.preflight!
        rule_set = @registry.fetch(profile)
        @runner.call(
          arguments(binary, rule_set.stylesheet),
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

      def raise_truncated_output
        raise ExecutionError.new(
          'SaxonC validation output exceeded the configured limit',
          reason: :output_limit,
          stream: :stdout
        )
      end

      def sanitize(output)
        output.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '?').strip
      end
    end
  end
end
