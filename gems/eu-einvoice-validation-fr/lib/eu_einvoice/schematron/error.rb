# frozen_string_literal: true

module EuEinvoice
  module Schematron
    class Error < EuEinvoice::Error; end
    class UnavailableError < Error; end
    class ExecutionError < Error; end
    class InvalidOutputError < ExecutionError; end
    class RulePackError < ExecutionError; end
  end
end
