# frozen_string_literal: true

require 'base64'
require 'json'
require 'rbconfig'
require 'eu_einvoice/resource_limits'
require 'eu_einvoice/source'
require 'eu_einvoice/subprocess'

module EuEinvoice
  module Pdf
    class IsolatedOperation
      ERRORS = [InvalidPdfError, ProtectedPdfError, ExtractionError, ResourceLimitError].to_h do |type|
        [type.name, type]
      end.freeze

      def initialize(limits: ResourceLimits.new)
        @limits = limits
      end

      def call(operation, pdf, embedding: nil)
        input = Source.read(pdf, limit: @limits.pdf_bytes)
        response = runner.call(command(operation, embedding), input:, resource_limits: process_limits)
        verify_response!(response)
        decode(response.stdout)
      rescue Subprocess::Error => e
        raise ResourceLimitError.new('PDF worker exceeded its execution budget', resource: :pdf_worker, **e.details)
      end

      private

      def verify_response!(response)
        return if response.exit_status.zero? && !response.stdout_truncated

        raise ResourceLimitError.new('PDF worker did not return a bounded result', resource: :pdf_worker,
                                                                                   exit_status: response.exit_status)
      end

      def runner
        Subprocess::Runner.new(timeout: @limits.process_timeout, stdout_limit: (@limits.xml_bytes * 3) + 65_536)
      end

      def command(operation, embedding)
        [RbConfig.ruby, '-I', $LOAD_PATH.join(File::PATH_SEPARATOR),
         File.expand_path('worker.rb', __dir__), operation.to_s, JSON.generate(@limits.to_h),
         JSON.generate(embedding&.to_h)]
      end

      def process_limits
        unless Process.const_defined?(:RLIMIT_AS)
          raise ResourceLimitError.new('Process address-space limit is unavailable', resource: :process_memory_bytes,
                                                                                     reason: :unsupported)
        end
        { rlimit_as: @limits.process_memory_bytes }
      end

      def decode(output)
        data = JSON.parse(output, symbolize_names: true)
        raise_worker_error(data) if data[:error]
        decode_result(data.fetch(:result))
      rescue JSON::ParserError, KeyError, ArgumentError => e
        raise InvalidPdfError.new('PDF worker response is invalid', reason: :worker_protocol, cause: e.class.name)
      end

      def decode_result(result)
        %i[xml metadata].each { |key| result[key] = Base64.strict_decode64(result[key]).freeze if result[key] }
        result[:relationship] = result[:relationship].to_sym if result[:relationship]
        result[:filename]&.freeze
        result
      end

      def raise_worker_error(data)
        type = ERRORS.fetch(data[:error], InvalidPdfError)
        details = data.fetch(:details, {})
        %i[reason resource protection relationship].each do |key|
          details[key] = details[key].to_sym if details[key].is_a?(String)
        end
        raise type.new('PDF operation failed', **details)
      end
    end
  end
end
