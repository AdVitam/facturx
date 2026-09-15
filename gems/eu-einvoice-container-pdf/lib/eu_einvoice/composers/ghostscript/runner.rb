# frozen_string_literal: true

require 'eu_einvoice/error'
require 'eu_einvoice/subprocess'
require 'eu_einvoice/resource_limits'

module EuEinvoice
  module Composers
    class Ghostscript
      class Runner
        def initialize(
          limits: ResourceLimits.new,
          timeout: limits.process_timeout,
          output_limit: Subprocess::Runner::DEFAULT_OUTPUT_LIMIT,
          termination_grace: Subprocess::Runner::DEFAULT_TERMINATION_GRACE
        )
          @runner = Subprocess::Runner.new(timeout:, output_limit:, termination_grace:)
          @limits = limits
        end

        def call(argv)
          result = @runner.call(argv, resource_limits: process_limits)
          return result if result.exit_status.zero?

          raise_failed(result)
        rescue Subprocess::Error => e
          raise_process_error(e)
        end

        private

        def process_limits
          unless Process.const_defined?(:RLIMIT_AS) && Process.const_defined?(:RLIMIT_FSIZE)
            raise ResourceLimitError.new('Required process limits are unavailable', resource: :ghostscript,
                                                                                    reason: :unsupported)
          end
          { rlimit_as: @limits.process_memory_bytes, rlimit_fsize: @limits.output_pdf_bytes }
        end

        def raise_failed(result)
          raise CompositionError.new(
            "Ghostscript failed with exit status #{result.exit_status}",
            exit_status: result.exit_status,
            stdout: sanitize(result.stdout),
            stderr: sanitize(result.stderr)
          )
        end

        def raise_process_error(error)
          return raise_timeout(error) if error.details[:reason] == :timeout

          raise CompositionError.new(
            "Ghostscript could not be executed: #{error.details[:message]}",
            cause: error.details[:cause]
          )
        end

        def raise_timeout(error)
          raise CompositionError.new(
            "Ghostscript timed out after #{error.details[:timeout]} seconds",
            timeout: error.details[:timeout],
            stderr: sanitize(error.details[:stderr])
          )
        end

        def sanitize(output)
          output.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '?').strip
        end
      end
    end
  end
end
