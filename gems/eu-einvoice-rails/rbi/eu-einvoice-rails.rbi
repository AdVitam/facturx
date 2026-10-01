# typed: strict

module Rails
  class Application
    class Configuration
      sig { returns(EuEinvoice::Rails::Configuration) }
      attr_accessor :eu_einvoice
    end
  end
end

module EuEinvoice
  module Rails
    class Configuration
      sig { void }
      def initialize; end

      sig do
        params(name: T.any(Symbol, String), packs: T::Array[EuEinvoice::Pack],
               policy: T.nilable(EuEinvoice::Policy), validation: Symbol,
               limits: EuEinvoice::ResourceLimits, instrumenter: T.nilable(EuEinvoice::Instrumenter))
          .returns(EuEinvoice::Client)
      end
      def register(name, packs:, policy: EuEinvoice::Policy.new, validation: :full,
                   limits: EuEinvoice::ResourceLimits.new, instrumenter: nil); end

      sig { params(name: T.any(Symbol, String)).returns(EuEinvoice::Client) }
      def [](name); end

      sig { returns(EuEinvoice::Rails::Configuration) }
      def seal!; end
    end

    class Instrumenter
      include EuEinvoice::Instrumenter

      sig do
        override.type_parameters(:Result)
          .params(event: Symbol, payload: T::Hash[Symbol, T.any(String, Symbol, Integer, Float, T::Boolean)],
                  block: T.proc.returns(T.type_parameter(:Result))).returns(T.type_parameter(:Result))
      end
      def call(event, payload, &block); end
    end

    class ErrorAdapter
      class << self
        sig do
          params(record: ActiveModel::Validations, report: EuEinvoice::Validation::Report,
                 attributes: T::Hash[T.nilable(String), Symbol]).returns(ActiveModel::Errors)
        end
        def apply(record, report:, attributes: {}); end
      end
    end

    module ActiveStorage
      sig do
        params(artifact: EuEinvoice::Artifact)
          .returns({ io: StringIO, filename: String, content_type: String, identify: FalseClass })
      end
      def self.attachable(artifact); end
    end
  end
end
