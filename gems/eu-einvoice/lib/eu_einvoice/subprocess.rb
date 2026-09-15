# frozen_string_literal: true

require 'open3'
require 'timeout'
require 'eu_einvoice/error'

module EuEinvoice
  module Subprocess
    Result = Data.define(:stdout, :stderr, :exit_status, :stdout_truncated)

    class Error < EuEinvoice::Error; end

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

    class CaptureSession
      attr_reader :completed

      def initialize(streams, output_limit:, stdout_limit:, grace:)
        @streams = streams
        @output_limit = output_limit
        @stdout_limit = stdout_limit
        @grace = grace
        @threads = []
        @completed = false
        @closed = false
      end

      def call(wait_thread, input)
        @threads << write(@streams[0], input)
        @threads << capture(@streams[1], @stdout_limit)
        @threads << capture(@streams[2], @output_limit)
        @threads[0].value
        result = build_result(wait_thread)
        @completed = true
        result
      end

      def close
        return if @closed

        @closed = true
        @streams.each { |stream| stream.close unless stream.closed? }
        @threads.each { |thread| thread.kill unless thread.join(@grace) }
      end

      def stderr
        reader = @threads[2]
        reader.value.content if reader && !reader.alive?
      end

      private

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

      def capture(stream, limit)
        Thread.new { OutputCapture.new(stream, limit:).call }
      end

      def build_result(wait_thread)
        status = wait_thread.value
        stdout = @threads[1].value
        stderr = @threads[2].value
        Result.new(stdout: stdout.content, stderr: stderr.content,
                   exit_status: status.exitstatus || (128 + status.termsig), stdout_truncated: stdout.truncated)
      end
    end

    class Runner
      DEFAULT_TIMEOUT = 60
      DEFAULT_OUTPUT_LIMIT = 8_192
      DEFAULT_TERMINATION_GRACE = 1

      def initialize(
        timeout: DEFAULT_TIMEOUT,
        output_limit: DEFAULT_OUTPUT_LIMIT,
        stdout_limit: output_limit,
        termination_grace: DEFAULT_TERMINATION_GRACE
      )
        @timeout = timeout
        @output_limit = output_limit
        @stdout_limit = stdout_limit
        @termination_grace = termination_grace
        raise ArgumentError, 'Timeout must be positive' unless timeout.positive?
        raise ArgumentError, 'Output limits must be positive' unless output_limit.positive? && stdout_limit.positive?
      end

      def call(argv, input: nil, chdir: nil, resource_limits: {})
        execute(argv, input:, chdir:, resource_limits:)
      rescue SystemCallError => e
        raise Error.new('Process could not be executed', reason: :spawn, cause: e.class.name, message: e.message)
      end

      private

      def execute(argv, input:, chdir:, resource_limits:)
        options = resource_limits.merge(pgroup: true)
        options[:chdir] = chdir if chdir
        Open3.popen3(*argv, **options) do |stdin, stdout, stderr, wait_thread|
          capture_process(stdin, stdout, stderr, wait_thread, input)
        end
      end

      def capture_process(stdin, stdout, stderr, wait_thread, input)
        session = CaptureSession.new([stdin, stdout, stderr], output_limit: @output_limit,
                                                              stdout_limit: @stdout_limit, grace: @termination_grace)
        within_deadline(session, wait_thread, input)
      rescue Timeout::Error
        session.close
        raise Error.new('Process exceeded its operation deadline', reason: :timeout, timeout: @timeout,
                                                                   stderr: sanitize(session.stderr))
      ensure
        session&.close
      end

      def within_deadline(session, wait_thread, input)
        Timeout.timeout(@timeout) { session.call(wait_thread, input) }
      ensure
        terminate(wait_thread) unless session.completed
      end

      def terminate(wait_thread)
        signal('TERM', wait_thread.pid)
        # The process group can outlive its leader and retain our pipes.
        deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + @termination_grace
        loop do
          remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
          break unless remaining.positive?

          sleep([remaining, 0.01].min)
        end
        signal('KILL', wait_thread.pid)
        wait_thread.join(@termination_grace)
      end

      def sanitize(output)
        output.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '?')
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

    private_constant :OutputCapture, :CaptureSession
  end
end
