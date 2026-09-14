# typed: strict

module Facturx
  module Schematron
    class Error < Facturx::Error; end
    class UnavailableError < Error; end
    class ExecutionError < Error; end
  end
end
