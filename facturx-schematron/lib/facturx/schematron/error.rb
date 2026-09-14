# frozen_string_literal: true

module Facturx
  module Schematron
    class Error < Facturx::Error; end
    class UnavailableError < Error; end
    class ExecutionError < Error; end
    class InvalidOutputError < ExecutionError; end
    class RulePackError < ExecutionError; end
  end
end
