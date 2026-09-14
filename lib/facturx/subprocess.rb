# frozen_string_literal: true

require 'open3'
require 'timeout'
require_relative 'error'

module Facturx
  module Subprocess
    Result = Data.define(:stdout, :stderr, :exit_status, :stdout_truncated, :stderr_truncated)

    class Error < Facturx::Error; end

    class OutputCapture
      TRUNCATION_MARKER = '...[truncated]'
      Output = Data.define(:content, :truncated)

      def initialize(stream, limit:)
        @stream = stream
        @limit = limit
      end

      def call
        buffer = +''.b
        truncated = false
        while (chunk = @stream.read(4_096))
          remaining = @limit - buffer.bytesize
          buffer << chunk.byteslice(0, remaining) if remaining.positive?
          truncated ||= chunk.bytesize > remaining
        end
        Output.new(content: truncate(buffer, truncated), truncated:)
      rescue IOError
        Output.new(content: buffer, truncated:)
      end

      private

      def truncate(buffer, truncated)
        return buffer unless truncated

        marker = TRUNCATION_MARKER.byteslice(0, @limit)
        kept_bytes = [@limit - marker.bytesize, 0].max
        buffer.byteslice(0, kept_bytes).to_s << marker
      end
    end

    class Runner
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

      def call(argv, input: nil, chdir: nil)
        execute(argv, input:, chdir:)
      rescue SystemCallError => e
        raise Error.new('Process could not be executed', reason: :spawn, cause: e.class.name, message: e.message)
      end

      private

      def execute(argv, input:, chdir:)
        options = { pgroup: true }
        options[:chdir] = chdir if chdir
        Open3.popen3(*argv, **options) do |stdin, stdout, stderr, wait_thread|
          capture_process(stdin, stdout, stderr, wait_thread, input)
        end
      end

      def capture_process(stdin, stdout, stderr, wait_thread, input)
        stdin_writer = write(stdin, input)
        stdout_reader = capture(stdout)
        stderr_reader = capture(stderr)
        build_result(wait_thread, stdout_reader, stderr_reader)
      ensure
        stdin_writer&.join
        stdout_reader&.join
        stderr_reader&.join
      end

      def write(stdin, input)
        Thread.new do
          stdin.binmode
          stdin.write(input) if input
        rescue Errno::EPIPE, IOError
          nil
        ensure
          stdin.close
        end
      end

      def capture(stream)
        Thread.new { OutputCapture.new(stream, limit: @output_limit).call }
      end

      def build_result(wait_thread, stdout_reader, stderr_reader)
        status = wait_for(wait_thread, stderr_reader)
        stdout = stdout_reader.value
        stderr = stderr_reader.value
        Result.new(
          stdout: stdout.content,
          stderr: stderr.content,
          exit_status: status.exitstatus || (128 + status.termsig),
          stdout_truncated: stdout.truncated,
          stderr_truncated: stderr.truncated
        )
      end

      def wait_for(wait_thread, stderr_reader)
        Timeout.timeout(@timeout) { wait_thread.value }
      rescue Timeout::Error
        terminate(wait_thread)
        raise Error.new(
          "Process timed out after #{@timeout} seconds",
          reason: :timeout,
          timeout: @timeout,
          stderr: stderr_reader.value.content
        )
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
    end

    private_constant :OutputCapture
  end
end
