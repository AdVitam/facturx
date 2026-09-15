# frozen_string_literal: true

require 'eu_einvoice/subprocess'
require 'eu_einvoice/resource_limits'

module EuEinvoice
  module Schematron
    class Runner < Subprocess::Runner
      def initialize(limits: ResourceLimits.new)
        @limits = limits
        super(timeout: limits.process_timeout, output_limit: 8192, stdout_limit: 8 * 1024 * 1024)
      end

      def call(argv, **)
        super(argv, **, resource_limits: process_limits)
      end

      private

      def process_limits
        unless Process.const_defined?(:RLIMIT_AS)
          raise ResourceLimitError.new('Process address-space limit is unavailable', resource: :process_memory_bytes,
                                                                                     reason: :unsupported)
        end
        { rlimit_as: @limits.process_memory_bytes }
      end
    end
  end
end
