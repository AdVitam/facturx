# typed: strict

module EuEinvoice
  module Pack
    interface!

    sig { abstract.returns(T::Array[EuEinvoice::Specification]) }
    def specifications; end
  end

  module Instrumenter
    interface!

    sig do
      abstract.type_parameters(:Result)
        .params(event: Symbol, payload: T::Hash[Symbol, T.any(String, Symbol, Integer, Float, T::Boolean)],
                block: T.proc.returns(T.type_parameter(:Result))).returns(T.type_parameter(:Result))
    end
    def call(event, payload, &block); end
  end

  class Client
    sig do
      params(packs: T::Array[EuEinvoice::Pack], policy: T.nilable(EuEinvoice::Policy), validation: Symbol,
             limits: EuEinvoice::ResourceLimits, instrumenter: T.nilable(EuEinvoice::Instrumenter)).void
    end
    def initialize(packs:, policy: EuEinvoice::Policy.new, validation: :full,
                   limits: EuEinvoice::ResourceLimits.new, instrumenter: nil); end

    sig { returns(T::Array[EuEinvoice::Specification]) }
    attr_reader :specifications

    sig { returns(EuEinvoice::ResourceLimits) }
    attr_reader :limits

    sig { returns(Symbol) }
    attr_reader :validation

    sig do
      params(document: EuEinvoice::Document, specification: T.nilable(EuEinvoice::Specification),
             requirements: EuEinvoice::RecipientRequirements)
        .returns(EuEinvoice::Resolution)
    end
    def resolve(document:, specification: nil, requirements: EuEinvoice::RecipientRequirements.new); end

    sig do
      params(source: T.any(String, IO, StringIO, Tempfile, EuEinvoice::Artifact),
             specification: T.nilable(EuEinvoice::Specification), on_unknown_profile: Symbol).returns(EuEinvoice::Reading)
    end
    def read(source, specification: nil, on_unknown_profile: :fallback); end

    sig do
      params(xml: T.any(String, IO, StringIO, Tempfile, EuEinvoice::Artifact),
             specification: T.nilable(EuEinvoice::Specification)).returns(EuEinvoice::Validation::Report)
    end
    def validate_xml(xml:, specification: nil); end

    sig do
      params(document: T.any(EuEinvoice::Document, EuEinvoice::Reading), specification: T.nilable(EuEinvoice::Specification),
             resolution: T.nilable(EuEinvoice::Resolution), allow_loss: T::Boolean).returns(EuEinvoice::Validation::Report)
    end
    def validate_document(document:, specification: nil, resolution: nil, allow_loss: false); end

    sig do
      params(document: T.any(EuEinvoice::Document, EuEinvoice::Reading), specification: T.nilable(EuEinvoice::Specification),
             resolution: T.nilable(EuEinvoice::Resolution), allow_loss: T::Boolean).returns(EuEinvoice::Artifact)
    end
    def build_xml(document:, specification: nil, resolution: nil, allow_loss: false); end

    sig do
      params(document: T.any(EuEinvoice::Document, EuEinvoice::Reading), pdf: T.any(String, IO, StringIO, Tempfile, EuEinvoice::Artifact),
             specification: T.nilable(EuEinvoice::Specification), resolution: T.nilable(EuEinvoice::Resolution), allow_loss: T::Boolean)
        .returns(EuEinvoice::Artifact)
    end
    def generate(document:, pdf:, specification: nil, resolution: nil, allow_loss: false); end

    sig do
      params(pdf: T.any(String, IO, StringIO, Tempfile, EuEinvoice::Artifact),
             xml: T.any(String, IO, StringIO, Tempfile, EuEinvoice::Artifact),
             specification: T.nilable(EuEinvoice::Specification)).returns(EuEinvoice::Artifact)
    end
    def attach(pdf:, xml:, specification: nil); end

    sig do
      params(pdf: T.any(String, IO, StringIO, Tempfile, EuEinvoice::Artifact),
             specification: T.nilable(EuEinvoice::Specification)).returns(EuEinvoice::Artifact)
    end
    def extract_xml(pdf:, specification: nil); end
  end

  class Artifact
    sig do
      params(bytes: String, content_type: String, filename: String, report: T.nilable(EuEinvoice::Validation::Report)).void
    end
    def initialize(bytes:, content_type:, filename:, report: nil); end

    sig { returns(String) }
    attr_reader :bytes, :content_type, :filename

    sig { returns(T.nilable(EuEinvoice::Validation::Report)) }
    attr_reader :report

    sig { returns(Integer) }
    def byte_size; end

    sig { returns(StringIO) }
    def to_io; end
  end

  class Policy
    sig { params(preferences: T::Hash[T::Array[String], String]).void }
    def initialize(preferences: {}); end

    sig { returns(T::Hash[T::Array[String], String]) }
    attr_reader :preferences

    sig { params(document: EuEinvoice::Document).returns(T.nilable(String)) }
    def preferred_id(document); end
  end

  class Resolution
    sig do
      params(status: Symbol, explanation: String, fingerprint: String, owner: Object,
             specification: T.nilable(EuEinvoice::Specification),
             candidates: T::Array[String], required_inputs: T::Array[Symbol],
             requirements: EuEinvoice::RecipientRequirements, diagnostics: T::Array[EuEinvoice::Diagnostic]).void
    end
    def initialize(status:, explanation:, fingerprint:, owner:, specification: nil, candidates: [], required_inputs: [],
                   requirements: EuEinvoice::RecipientRequirements.new, diagnostics: []); end

    sig { returns(Symbol) }
    attr_reader :status

    sig { returns(T.nilable(EuEinvoice::Specification)) }
    attr_reader :specification

    sig { returns(T::Array[String]) }
    attr_reader :candidates

    sig { returns(T::Array[Symbol]) }
    attr_reader :required_inputs

    sig { returns(EuEinvoice::RecipientRequirements) }
    attr_reader :requirements

    sig { returns(T::Array[EuEinvoice::Diagnostic]) }
    attr_reader :diagnostics

    sig { returns(String) }
    attr_reader :explanation, :fingerprint

    sig { returns(Object) }
    attr_reader :owner

    sig { returns(T::Boolean) }
    def resolved?; end

    sig { params(document: EuEinvoice::Document, expected_owner: Object).void }
    def verify!(document, expected_owner); end
  end

  class ResourceLimits
    sig do
      params(xml_bytes: Integer, xml_depth: Integer, xml_nodes: Integer, pdf_bytes: Integer,
             output_pdf_bytes: Integer, pdf_pages: Integer, pdf_objects: Integer, attachments: Integer,
             tree_depth: Integer, process_timeout: Numeric, process_memory_bytes: Integer).void
    end
    def initialize(xml_bytes: 10485760, xml_depth: 128, xml_nodes: 250000, pdf_bytes: 52428800,
                   output_pdf_bytes: 104857600, pdf_pages: 500, pdf_objects: 100000, attachments: 32,
                   tree_depth: 64, process_timeout: 60, process_memory_bytes: 1073741824); end

    sig { returns(Integer) }
    attr_reader :xml_bytes, :xml_depth, :xml_nodes, :pdf_bytes, :output_pdf_bytes, :pdf_pages,
                :pdf_objects, :attachments, :tree_depth, :process_memory_bytes

    sig { returns(Numeric) }
    attr_reader :process_timeout

    sig { returns(T::Hash[Symbol, Numeric]) }
    def to_h; end

    sig { params(resource: Symbol, actual: Numeric).void }
    def check!(resource, actual); end
  end
end
