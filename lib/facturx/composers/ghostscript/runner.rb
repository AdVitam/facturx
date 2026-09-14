# frozen_string_literal: true

require_relative '../../error'
require_relative '../../subprocess'

module Facturx
  module Composers
    class Ghostscript
      class Runner
        def initialize(
          timeout: Subprocess::Runner::DEFAULT_TIMEOUT,
          output_limit: Subprocess::Runner::DEFAULT_OUTPUT_LIMIT,
          termination_grace: Subprocess::Runner::DEFAULT_TERMINATION_GRACE
        )
          @runner = Subprocess::Runner.new(timeout:, output_limit:, termination_grace:)
        end

        def call(argv)
          result = @runner.call(argv)
          return result if result.exit_status.zero?

          raise_failed(result)
        rescue Subprocess::Error => e
          raise_process_error(e)
        end

        private

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
