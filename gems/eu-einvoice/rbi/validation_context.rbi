# typed: strict

module EuEinvoice
  module Validation
    class Context
      sig { params(source: String, representation: Object, syntax: Symbol).void }
      def initialize(source:, representation:, syntax:); end

      sig { returns(String) }
      attr_reader :source

      sig { returns(Object) }
      attr_reader :representation

      sig { returns(Symbol) }
      attr_reader :syntax

      sig { params(source: String, representation: Object, syntax: Symbol).returns(Context) }
      def with(source: self.source, representation: self.representation, syntax: self.syntax); end
    end
  end
end
