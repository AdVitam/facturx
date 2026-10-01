# typed: strict

module EuEinvoice
  class RequirementProvenance
    sig { params(source: T.nilable(String), observed_at: T.nilable(Time), version: T.nilable(String)).void }
    def initialize(source: nil, observed_at: nil, version: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :source, :version

    sig { returns(T.nilable(Time)) }
    attr_reader :observed_at

    sig do
      params(source: T.nilable(String), observed_at: T.nilable(Time), version: T.nilable(String))
        .returns(EuEinvoice::RequirementProvenance)
    end
    def with(source: self.source, observed_at: self.observed_at, version: self.version); end
  end

  class RecipientRequirements
    sig do
      params(specification_ids: T::Array[String], syntaxes: T::Array[Symbol],
             electronic_address_schemes: T::Array[String], required_references: T::Array[Symbol],
             provenance: T.nilable(EuEinvoice::RequirementProvenance)).void
    end
    def initialize(specification_ids: [], syntaxes: [], electronic_address_schemes: [], required_references: [],
                   provenance: nil); end

    sig { returns(T::Array[String]) }
    attr_reader :specification_ids, :electronic_address_schemes

    sig { returns(T::Array[Symbol]) }
    attr_reader :syntaxes, :required_references

    sig { returns(T.nilable(EuEinvoice::RequirementProvenance)) }
    attr_reader :provenance

    sig { params(document: EuEinvoice::Document).returns(T::Array[EuEinvoice::Diagnostic]) }
    def diagnostics(document); end

    sig { params(specification: EuEinvoice::Specification).returns(T::Boolean) }
    def accepts?(specification); end

    sig { returns(T::Boolean) }
    def constrains_format?; end

    sig do
      params(specification_ids: T::Array[String], syntaxes: T::Array[Symbol],
             electronic_address_schemes: T::Array[String], required_references: T::Array[Symbol],
             provenance: T.nilable(EuEinvoice::RequirementProvenance)).returns(EuEinvoice::RecipientRequirements)
    end
    def with(specification_ids: self.specification_ids, syntaxes: self.syntaxes,
             electronic_address_schemes: self.electronic_address_schemes, required_references: self.required_references,
             provenance: self.provenance); end
  end
end
