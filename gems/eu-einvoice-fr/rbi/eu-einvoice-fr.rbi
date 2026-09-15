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

      sig { params(version: String).void }
      def initialize(version: '1.09.2'); end

      sig { override.returns(T::Array[EuEinvoice::Specification]) }
      attr_reader :specifications

      sig { params(profile: Symbol).returns(EuEinvoice::Specification) }
      def specification(profile: :en16931); end

      sig { params(profile: Symbol).returns(EuEinvoice::Policy) }
      def policy(profile: :en16931); end
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
