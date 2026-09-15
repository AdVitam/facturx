# typed: strict

module EuEinvoice
  module Validation
    module France
      class << self
        sig do
          params(specification: T.nilable(EuEinvoice::Specification), limits: EuEinvoice::ResourceLimits, root: String)
            .returns(EuEinvoice::Schematron::Validator)
        end
        def validator(specification: nil, limits: EuEinvoice::ResourceLimits.new, root: ''); end
      end
    end
  end

  module Schematron
    class Error < EuEinvoice::Error; end
    class UnavailableError < Error; end
    class ExecutionError < Error; end

    class Validator
      sig { returns(EuEinvoice::Schematron::Validator) }
      def preflight!; end

      sig { params(profile: EuEinvoice::Profile).returns(T::Hash[String, String]) }
      def resources(profile:); end

      sig do
        params(document: Nokogiri::XML::Document, profile: EuEinvoice::Profile)
          .returns(T::Array[EuEinvoice::Validation::Issue])
      end
      def call(document:, profile:); end
    end
  end
end
