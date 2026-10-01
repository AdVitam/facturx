# typed: strict

module EuEinvoice
  module Profiles
    class << self
      sig { returns(T::Array[EuEinvoice::Profile]) }
      def all; end

      sig { params(id: T.any(String, Symbol)).returns(EuEinvoice::Profile) }
      def fetch(id); end

      sig { params(guideline_urn: String).returns(T.nilable(EuEinvoice::Profile)) }
      def for_guideline_urn(guideline_urn); end
    end
  end

  module France
    class Pack
      include EuEinvoice::Pack

      sig { params(version: String, ghostscript_locator: T.nilable(Object)).void }
      def initialize(version: '1.09.2', ghostscript_locator: nil); end

      sig { override.returns(T::Array[EuEinvoice::Specification]) }
      attr_reader :specifications

      sig { override.params(validation: Symbol, limits: EuEinvoice::ResourceLimits).returns(EuEinvoice::Adapter) }
      def adapter(validation:, limits: EuEinvoice::ResourceLimits.new); end

      sig { params(profile: Symbol).returns(EuEinvoice::Specification) }
      def specification(profile: :en16931); end

      sig { params(profile: Symbol).returns(EuEinvoice::Policy) }
      def policy(profile: :en16931); end

      sig { params(pdf: T.any(String, IO, StringIO, Tempfile, EuEinvoice::Artifact), limits: EuEinvoice::ResourceLimits).returns(String) }
      def extract_xml(pdf:, limits: EuEinvoice::ResourceLimits.new); end

      sig do
        params(pdf: T.any(String, IO, StringIO, Tempfile, EuEinvoice::Artifact),
               xml: T.any(String, IO, StringIO, Tempfile, EuEinvoice::Artifact),
               specification: EuEinvoice::Specification, limits: EuEinvoice::ResourceLimits).returns(String)
      end
      def compose(pdf:, xml:, specification:, limits: EuEinvoice::ResourceLimits.new); end
    end

    class Adapter
      include EuEinvoice::Adapter

      sig { override.params(xml: String).returns(EuEinvoice::Validation::Context) }
      def prepare(xml:); end

      sig do
        override.params(xml: T.nilable(String), context: T.nilable(EuEinvoice::Validation::Context))
          .returns(T::Array[EuEinvoice::Specification])
      end
      def detect(xml: nil, context: nil); end

      sig do
        override.params(xml: T.nilable(String), context: T.nilable(EuEinvoice::Validation::Context))
          .returns(T::Boolean)
      end
      def can_read?(xml: nil, context: nil); end

      sig do
        override.params(source: T.nilable(String), specification: T.nilable(EuEinvoice::Specification),
                        on_unknown_profile: Symbol, context: T.nilable(EuEinvoice::Validation::Context))
          .returns(EuEinvoice::Reading)
      end
      def read(source = nil, specification: nil, on_unknown_profile: :fallback, context: nil); end

      sig { override.params(document: EuEinvoice::Document, specification: EuEinvoice::Specification).returns(Object) }
      def compile(document:, specification:); end

      sig do
        override.params(document: EuEinvoice::Document, specification: EuEinvoice::Specification)
          .returns(EuEinvoice::Validation::Report)
      end
      def validate_document(document:, specification:); end

      sig do
        override.params(xml: T.nilable(String), specification: T.nilable(EuEinvoice::Specification),
                        context: T.nilable(EuEinvoice::Validation::Context)).returns(EuEinvoice::Validation::Report)
      end
      def validate_xml(xml: nil, specification: nil, context: nil); end
    end

    class InvalidAddressError < EuEinvoice::Error; end

    class FrenchAddress
      sig do
        params(siren: T.nilable(String), siret: T.nilable(String), suffix: T.nilable(String),
               routing_code: T.nilable(String)).void
      end
      def initialize(siren: nil, siret: nil, suffix: nil, routing_code: nil); end

      sig { returns(String) }
      attr_reader :siren

      sig { returns(T.nilable(String)) }
      attr_reader :siret, :suffix, :routing_code

      sig { returns(EuEinvoice::Identifier) }
      def electronic_address; end

      sig do
        params(siren: T.nilable(String), siret: T.nilable(String), suffix: T.nilable(String),
               routing_code: T.nilable(String)).returns(EuEinvoice::France::FrenchAddress)
      end
      def with(siren: self.siren, siret: self.siret, suffix: self.suffix, routing_code: self.routing_code); end
    end

    module Addressing
      class << self
        sig do
          params(siren: T.nilable(String), siret: T.nilable(String), suffix: T.nilable(String),
                 routing_code: T.nilable(String)).returns(EuEinvoice::France::FrenchAddress)
        end
        def build(siren: nil, siret: nil, suffix: nil, routing_code: nil); end
      end
    end
  end
end
