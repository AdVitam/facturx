# typed: strict

module EuEinvoice
  class Specification
    ManifestValue = T.type_alias do
      T.nilable(T.any(String, Symbol, T::Array[String], T::Array[Symbol], T::Hash[String, String],
                     T::Hash[String, T::Hash[String, String]]))
    end
    Manifest = T.type_alias { T::Hash[Symbol, ManifestValue] }

    sig do
      params(id: String, version: String, profile: EuEinvoice::Profile,
             manifest: Manifest,
             fingerprint: T.nilable(String)).void
    end
    def initialize(id:, version:, profile:, manifest:, fingerprint: nil); end

    sig { returns(String) }
    attr_reader :id, :version, :fingerprint

    sig { returns(EuEinvoice::Profile) }
    attr_reader :profile

    sig { returns(Manifest) }
    attr_reader :manifest

    sig { returns(String) }
    def guideline_urn; end

    sig { returns(String) }
    def semantic_version; end

    sig { returns(Symbol) }
    def syntax; end

    sig { returns(String) }
    def jurisdiction; end

    sig { returns(T::Hash[String, String]) }
    def resources; end

    sig do
      params(id: String, version: String, profile: EuEinvoice::Profile,
             manifest: Manifest,
             fingerprint: T.nilable(String)).returns(EuEinvoice::Specification)
    end
    def with(id: self.id, version: self.version, profile: self.profile, manifest: self.manifest,
             fingerprint: nil); end
  end

  class TermDefinition
    sig do
      params(id: String, model: Symbol, attribute: T.nilable(Symbol), group_id: T.nilable(String),
             type: Symbol, scale: T.nilable(Integer), cardinality: String).void
    end
    def initialize(id:, model:, attribute:, group_id:, type:, scale:, cardinality:); end

    sig { returns(String) }
    attr_reader :id, :cardinality

    sig { returns(Symbol) }
    attr_reader :model, :type

    sig { returns(T.nilable(Symbol)) }
    attr_reader :attribute

    sig { returns(T.nilable(String)) }
    attr_reader :group_id

    sig { returns(T.nilable(Integer)) }
    attr_reader :scale
  end

  class GroupDefinition
    sig do
      params(id: String, model: Symbol, attribute: T.nilable(Symbol), parent_id: T.nilable(String), cardinality: String).void
    end
    def initialize(id:, model:, attribute:, parent_id:, cardinality:); end

    sig { returns(String) }
    attr_reader :id, :cardinality

    sig { returns(Symbol) }
    attr_reader :model

    sig { returns(T.nilable(Symbol)) }
    attr_reader :attribute

    sig { returns(T.nilable(String)) }
    attr_reader :parent_id
  end
end
