# frozen_string_literal: true

require 'open3'
require 'timeout'
require_relative '../../error'
require_relative 'output_capture'

module Facturx
  module Composers
    class Ghostscript
      class Runner
        Result = Struct.new(:stdout, :stderr, :exit_status, keyword_init: true) do
          def initialize(...)
            super
            freeze
          end
        end

        DEFAULT_TIMEOUT = 60
        DEFAULT_OUTPUT_LIMIT = 8_192
        DEFAULT_TERMINATION_GRACE = 1
        def initialize(
          timeout: DEFAULT_TIMEOUT,
          output_limit: DEFAULT_OUTPUT_LIMIT,
          termination_grace: DEFAULT_TERMINATION_GRACE
        )
          @timeout = timeout
          @output_limit = output_limit
          @termination_grace = termination_grace
        end

        def call(argv)
          result = execute(argv)
          return result if result.exit_status.zero?

          raise_failed(result)
        rescue CompositionError
          raise
        rescue SystemCallError => e
          raise CompositionError.new(
            "Ghostscript could not be executed: #{e.message}",
            cause: e.class.name
          )
        end

        private

        def execute(argv)
          Open3.popen3(*argv, pgroup: true) do |stdin, stdout, stderr, wait_thread|
            capture_process(stdin, stdout, stderr, wait_thread)
          end
        end

        def capture_process(stdin, stdout, stderr, wait_thread)
          stdin.close
          stdout_reader = capture(stdout)
          stderr_reader = capture(stderr)
          build_result(wait_thread, stdout_reader, stderr_reader)
        ensure
          stdout_reader&.join
          stderr_reader&.join
        end

        def build_result(wait_thread, stdout_reader, stderr_reader)
          status = wait_for(wait_thread, stderr_reader)
          Result.new(
            stdout: stdout_reader.value,
            stderr: stderr_reader.value,
            exit_status: status.exitstatus
          )
        end

        def raise_failed(result)
          raise CompositionError.new(
            "Ghostscript failed with exit status #{result.exit_status}",
            exit_status: result.exit_status,
            stdout: sanitize(result.stdout),
            stderr: sanitize(result.stderr)
          )
        end

        def wait_for(wait_thread, stderr_reader)
          Timeout.timeout(@timeout) { wait_thread.value }
        rescue Timeout::Error
          terminate(wait_thread)
          raise CompositionError.new(
            "Ghostscript timed out after #{@timeout} seconds",
            timeout: @timeout,
            stderr: sanitize(stderr_reader.value)
          )
        end

        def capture(stream)
          Thread.new { OutputCapture.new(stream, limit: @output_limit).call }
        end

        def terminate(wait_thread)
          signal('TERM', wait_thread.pid)
          return if wait_thread.join(@termination_grace)

          signal('KILL', wait_thread.pid)
          wait_thread.join
        end

        def signal(name, pid)
          Process.kill(name, -pid)
        rescue Errno::ESRCH
          nil
        rescue SystemCallError
          begin
            Process.kill(name, pid)
          rescue Errno::ESRCH
            nil
          end
        end

        def sanitize(output)
          output.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '?').strip
        end
      end
    end
  end
end
