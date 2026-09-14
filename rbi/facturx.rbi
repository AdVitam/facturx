# typed: strict

module Facturx
  VERSION = T.let(T.unsafe(nil), String)

  class Error < StandardError
    sig { params(message: T.nilable(String), details: T.untyped).void }
    def initialize(message = nil, **details); end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :details
  end

  class ValidationError < Error; end
  class InvalidDocumentError < ValidationError; end
  class InvalidXmlError < ValidationError; end
  class UnknownProfileError < InvalidXmlError; end
  class XsdValidationError < InvalidXmlError; end
  class SchematronValidationError < InvalidXmlError; end
  class SchemaLoadError < Error; end
  class InvalidSourceError < Error; end
  class UnsupportedProfileError < Error; end
  class InvalidPdfError < Error; end
  class ProtectedPdfError < InvalidPdfError; end
  class ComposerUnavailableError < Error; end
  class CompositionError < Error; end
  class ExtractionError < Error; end
  class VerificationError < Error; end

  class << self
    sig { params(xml: String).returns(Facturx::Validation::Report) }
    def validate_xml(xml:); end

    sig { params(pdf: String, xml: String).returns(String) }
    def attach(pdf:, xml:); end

    sig { params(pdf: String).returns(String) }
    def extract_xml(pdf:); end

    sig do
      params(source: String, on_unknown_profile: Symbol)
        .returns(Facturx::Reading)
    end
    def read(source, on_unknown_profile: :fallback); end

    sig do
      params(document: Facturx::Document, profile: T.any(Symbol, Facturx::Profile))
        .returns(Facturx::Validation::Report)
    end
    def validate_document(document:, profile:); end

    sig { params(document: Facturx::Document, profile: T.any(Symbol, Facturx::Profile)).returns(String) }
    def build_xml(document:, profile:); end

    sig do
      params(pdf: String, document: Facturx::Document, profile: T.any(Symbol, Facturx::Profile))
        .returns(String)
    end
    def generate(pdf:, document:, profile:); end
  end

  module Validation
    class Issue
      sig do
        params(
          code: Symbol,
          message: String,
          layer: Symbol,
          severity: Symbol,
          term_id: T.nilable(String),
          group_id: T.nilable(String),
          path: T.nilable(String),
          line: T.nilable(Integer),
          column: T.nilable(Integer),
          details: T::Hash[Symbol, T.untyped]
        ).void
      end
      def initialize(code:, message:, layer:, severity: :error, term_id: nil, group_id: nil, path: nil,
                     line: nil, column: nil, details: {}); end

      sig { returns(Symbol) }
      attr_reader :code, :layer, :severity

      sig { returns(String) }
      attr_reader :message

      sig { returns(T.nilable(String)) }
      attr_reader :term_id, :group_id, :path

      sig { returns(T.nilable(Integer)) }
      attr_reader :line, :column

      sig { returns(T::Hash[Symbol, T.untyped]) }
      attr_reader :details

      sig do
        params(
          code: Symbol,
          message: String,
          layer: Symbol,
          severity: Symbol,
          term_id: T.nilable(String),
          group_id: T.nilable(String),
          path: T.nilable(String),
          line: T.nilable(Integer),
          column: T.nilable(Integer),
          details: T::Hash[Symbol, T.untyped]
        ).returns(Facturx::Validation::Issue)
      end
      def with(code: self.code, message: self.message, layer: self.layer, severity: self.severity,
               term_id: self.term_id, group_id: self.group_id, path: self.path, line: self.line,
               column: self.column, details: self.details); end
    end

    class Report
      sig { params(profile: T.nilable(Facturx::Profile), issues: T::Array[Facturx::Validation::Issue]).void }
      def initialize(profile: nil, issues: []); end

      sig { returns(T.nilable(Facturx::Profile)) }
      attr_reader :profile

      sig { returns(T::Array[Facturx::Validation::Issue]) }
      attr_reader :issues

      sig { returns(T::Boolean) }
      def valid?; end

      sig { returns(T::Boolean) }
      def invalid?; end

      sig do
        params(profile: T.nilable(Facturx::Profile), issues: T::Array[Facturx::Validation::Issue])
          .returns(Facturx::Validation::Report)
      end
      def with(profile: self.profile, issues: self.issues); end
    end
  end

  class Profile
    sig { params(id: Symbol, guideline_urn: String, conformance_level: String).void }
    def initialize(id:, guideline_urn:, conformance_level:); end

    sig { returns(Symbol) }
    def id; end

    sig { returns(String) }
    def guideline_urn; end

    sig { returns(String) }
    def conformance_level; end

    sig do
      params(id: Symbol, guideline_urn: String, conformance_level: String)
        .returns(Facturx::Profile)
    end
    def with(id: self.id, guideline_urn: self.guideline_urn, conformance_level: self.conformance_level); end
  end

  module Profiles
    sig { returns(T::Array[Facturx::Profile]) }
    def self.all; end

    sig { params(id: T.any(String, Symbol)).returns(Facturx::Profile) }
    def self.fetch(id); end

    sig { params(guideline_urn: String).returns(T.nilable(Facturx::Profile)) }
    def self.for_guideline_urn(guideline_urn); end
  end

  class Diagnostic
    sig do
      params(
        code: Symbol,
        message: String,
        term_id: T.nilable(String),
        path: T.nilable(String),
        details: T::Hash[Symbol, T.untyped]
      ).void
    end
    def initialize(code:, message:, term_id: nil, path: nil, details: {}); end

    sig { returns(Symbol) }
    def code; end

    sig { returns(T.nilable(String)) }
    def term_id; end

    sig { returns(T.nilable(String)) }
    def path; end

    sig { returns(String) }
    def message; end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def details; end

    sig do
      params(
        code: Symbol,
        message: String,
        term_id: T.nilable(String),
        path: T.nilable(String),
        details: T::Hash[Symbol, T.untyped]
      ).returns(Facturx::Diagnostic)
    end
    def with(code: self.code, message: self.message, term_id: self.term_id, path: self.path,
             details: self.details); end
  end

  class Reading
    sig do
      params(
        document: Facturx::Document,
        profile: Facturx::Profile,
        source: String,
        diagnostics: T::Array[Facturx::Diagnostic],
        source_type: Symbol
      ).void
    end
    def initialize(document:, profile:, source:, diagnostics: [], source_type: :xml); end

    sig { returns(Facturx::Document) }
    def document; end

    sig { returns(Facturx::Profile) }
    def profile; end

    sig { returns(T::Array[Facturx::Diagnostic]) }
    def diagnostics; end

    sig { returns(String) }
    def source; end

    sig { returns(Symbol) }
    def source_type; end

    sig do
      params(
        document: Facturx::Document,
        profile: Facturx::Profile,
        source: String,
        diagnostics: T::Array[Facturx::Diagnostic],
        source_type: Symbol
      ).returns(Facturx::Reading)
    end
    def with(document: self.document, profile: self.profile, source: self.source,
             diagnostics: self.diagnostics, source_type: self.source_type); end
  end

  class Note
    sig { params(content: T.nilable(String), subject_code: T.nilable(String)).void }
    def initialize(content: nil, subject_code: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :content, :subject_code

    sig { params(content: T.nilable(String), subject_code: T.nilable(String)).returns(Facturx::Note) }
    def with(content: self.content, subject_code: self.subject_code); end
  end

  class Identifier
    sig { params(value: T.nilable(String), scheme_id: T.nilable(String)).void }
    def initialize(value: nil, scheme_id: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :value, :scheme_id

    sig { params(value: T.nilable(String), scheme_id: T.nilable(String)).returns(Facturx::Identifier) }
    def with(value: self.value, scheme_id: self.scheme_id); end
  end

  class Period
    sig { params(start_date: T.nilable(::Date), end_date: T.nilable(::Date)).void }
    def initialize(start_date: nil, end_date: nil); end

    sig { returns(T.nilable(::Date)) }
    attr_reader :start_date, :end_date

    sig { params(start_date: T.nilable(::Date), end_date: T.nilable(::Date)).returns(Facturx::Period) }
    def with(start_date: self.start_date, end_date: self.end_date); end
  end

  class Quantity
    sig { params(value: T.nilable(T.any(::BigDecimal, Integer)), unit_code: T.nilable(String)).void }
    def initialize(value: nil, unit_code: nil); end

    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :value

    sig { returns(T.nilable(String)) }
    attr_reader :unit_code

    sig do
      params(value: T.nilable(T.any(::BigDecimal, Integer)), unit_code: T.nilable(String))
        .returns(Facturx::Quantity)
    end
    def with(value: self.value, unit_code: self.unit_code); end
  end

  class Contact
    sig { params(name: T.nilable(String), telephone: T.nilable(String), email: T.nilable(String)).void }
    def initialize(name: nil, telephone: nil, email: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :name, :telephone, :email

    sig do
      params(name: T.nilable(String), telephone: T.nilable(String), email: T.nilable(String))
        .returns(Facturx::Contact)
    end
    def with(name: self.name, telephone: self.telephone, email: self.email); end
  end

  class Address
    sig do
      params(
        postcode: T.nilable(String),
        line_one: T.nilable(String),
        line_two: T.nilable(String),
        line_three: T.nilable(String),
        city: T.nilable(String),
        country_code: T.nilable(String),
        country_subdivision: T.nilable(String)
      ).void
    end
    def initialize(postcode: nil, line_one: nil, line_two: nil, line_three: nil, city: nil,
                   country_code: nil, country_subdivision: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :postcode, :line_one, :line_two, :line_three, :city, :country_code, :country_subdivision

    sig do
      params(
        postcode: T.nilable(String),
        line_one: T.nilable(String),
        line_two: T.nilable(String),
        line_three: T.nilable(String),
        city: T.nilable(String),
        country_code: T.nilable(String),
        country_subdivision: T.nilable(String)
      ).returns(Facturx::Address)
    end
    def with(postcode: self.postcode, line_one: self.line_one, line_two: self.line_two,
             line_three: self.line_three, city: self.city, country_code: self.country_code,
             country_subdivision: self.country_subdivision); end
  end

  class Party
    sig do
      params(
        identifiers: T::Array[Facturx::Identifier],
        name: T.nilable(String),
        description: T.nilable(String),
        legal_registration: T.nilable(Facturx::Identifier),
        trading_name: T.nilable(String),
        address: T.nilable(Facturx::Address),
        vat_identifier: T.nilable(Facturx::Identifier),
        tax_identifier: T.nilable(Facturx::Identifier),
        electronic_address: T.nilable(Facturx::Identifier),
        contact: T.nilable(Facturx::Contact)
      ).void
    end
    def initialize(identifiers: [], name: nil, description: nil, legal_registration: nil,
                   trading_name: nil, address: nil, vat_identifier: nil, tax_identifier: nil,
                   electronic_address: nil, contact: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :name, :description, :trading_name

    sig { returns(T::Array[Facturx::Identifier]) }
    def identifiers; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def legal_registration; end

    sig { returns(T.nilable(Facturx::Address)) }
    def address; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def vat_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def tax_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def electronic_address; end

    sig { returns(T.nilable(Facturx::Contact)) }
    def contact; end

    sig do
      params(
        identifiers: T::Array[Facturx::Identifier],
        name: T.nilable(String),
        description: T.nilable(String),
        legal_registration: T.nilable(Facturx::Identifier),
        trading_name: T.nilable(String),
        address: T.nilable(Facturx::Address),
        vat_identifier: T.nilable(Facturx::Identifier),
        tax_identifier: T.nilable(Facturx::Identifier),
        electronic_address: T.nilable(Facturx::Identifier),
        contact: T.nilable(Facturx::Contact)
      ).returns(Facturx::Party)
    end
    def with(identifiers: self.identifiers, name: self.name, description: self.description,
             legal_registration: self.legal_registration, trading_name: self.trading_name,
             address: self.address, vat_identifier: self.vat_identifier,
             tax_identifier: self.tax_identifier, electronic_address: self.electronic_address,
             contact: self.contact); end
  end

  class CreditTransfer
    sig do
      params(
        account_identifier: T.nilable(Facturx::Identifier),
        account_name: T.nilable(String),
        provider_identifier: T.nilable(Facturx::Identifier)
      ).void
    end
    def initialize(account_identifier: nil, account_name: nil, provider_identifier: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :account_name

    sig { returns(T.nilable(Facturx::Identifier)) }
    def account_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def provider_identifier; end

    sig do
      params(
        account_identifier: T.nilable(Facturx::Identifier),
        account_name: T.nilable(String),
        provider_identifier: T.nilable(Facturx::Identifier)
      ).returns(Facturx::CreditTransfer)
    end
    def with(account_identifier: self.account_identifier, account_name: self.account_name,
             provider_identifier: self.provider_identifier); end
  end

  class PaymentCard
    sig { params(primary_account_number: T.nilable(String), holder_name: T.nilable(String)).void }
    def initialize(primary_account_number: nil, holder_name: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :primary_account_number, :holder_name

    sig do
      params(primary_account_number: T.nilable(String), holder_name: T.nilable(String))
        .returns(Facturx::PaymentCard)
    end
    def with(primary_account_number: self.primary_account_number, holder_name: self.holder_name); end
  end

  class DirectDebit
    sig do
      params(
        mandate_identifier: T.nilable(Facturx::Identifier),
        creditor_identifier: T.nilable(Facturx::Identifier),
        debtor_account_identifier: T.nilable(Facturx::Identifier)
      ).void
    end
    def initialize(mandate_identifier: nil, creditor_identifier: nil, debtor_account_identifier: nil); end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def mandate_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def creditor_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def debtor_account_identifier; end

    sig do
      params(
        mandate_identifier: T.nilable(Facturx::Identifier),
        creditor_identifier: T.nilable(Facturx::Identifier),
        debtor_account_identifier: T.nilable(Facturx::Identifier)
      ).returns(Facturx::DirectDebit)
    end
    def with(mandate_identifier: self.mandate_identifier, creditor_identifier: self.creditor_identifier,
             debtor_account_identifier: self.debtor_account_identifier); end
  end

  class PaymentInstructions
    sig do
      params(
        means_code: T.nilable(String),
        means_text: T.nilable(String),
        remittance_information: T.nilable(String),
        credit_transfers: T::Array[Facturx::CreditTransfer],
        payment_card: T.nilable(Facturx::PaymentCard),
        direct_debit: T.nilable(Facturx::DirectDebit)
      ).void
    end
    def initialize(means_code: nil, means_text: nil, remittance_information: nil,
                   credit_transfers: [], payment_card: nil, direct_debit: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :means_code, :means_text, :remittance_information

    sig { returns(T::Array[Facturx::CreditTransfer]) }
    def credit_transfers; end

    sig { returns(T.nilable(Facturx::PaymentCard)) }
    def payment_card; end

    sig { returns(T.nilable(Facturx::DirectDebit)) }
    def direct_debit; end

    sig do
      params(
        means_code: T.nilable(String),
        means_text: T.nilable(String),
        remittance_information: T.nilable(String),
        credit_transfers: T::Array[Facturx::CreditTransfer],
        payment_card: T.nilable(Facturx::PaymentCard),
        direct_debit: T.nilable(Facturx::DirectDebit)
      ).returns(Facturx::PaymentInstructions)
    end
    def with(means_code: self.means_code, means_text: self.means_text,
             remittance_information: self.remittance_information,
             credit_transfers: self.credit_transfers, payment_card: self.payment_card,
             direct_debit: self.direct_debit); end
  end

  class DocumentReference
    sig do
      params(
        id: T.nilable(String),
        line_id: T.nilable(String),
        name: T.nilable(String),
        issue_date: T.nilable(::Date)
      ).void
    end
    def initialize(id: nil, line_id: nil, name: nil, issue_date: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :id, :line_id, :name

    sig { returns(T.nilable(::Date)) }
    attr_reader :issue_date

    sig do
      params(
        id: T.nilable(String),
        line_id: T.nilable(String),
        name: T.nilable(String),
        issue_date: T.nilable(::Date)
      ).returns(Facturx::DocumentReference)
    end
    def with(id: self.id, line_id: self.line_id, name: self.name, issue_date: self.issue_date); end
  end

  class Delivery
    sig do
      params(
        location_identifier: T.nilable(Facturx::Identifier),
        party: T.nilable(Facturx::Party),
        date: T.nilable(::Date)
      ).void
    end
    def initialize(location_identifier: nil, party: nil, date: nil); end

    sig { returns(T.nilable(::Date)) }
    attr_reader :date

    sig { returns(T.nilable(Facturx::Identifier)) }
    def location_identifier; end

    sig { returns(T.nilable(Facturx::Party)) }
    def party; end

    sig do
      params(
        location_identifier: T.nilable(Facturx::Identifier),
        party: T.nilable(Facturx::Party),
        date: T.nilable(::Date)
      ).returns(Facturx::Delivery)
    end
    def with(location_identifier: self.location_identifier, party: self.party, date: self.date); end
  end

  class SupportingDocument
    sig do
      params(
        reference: T.nilable(String),
        description: T.nilable(String),
        external_location: T.nilable(String),
        content: T.nilable(String),
        mime_code: T.nilable(String),
        filename: T.nilable(String)
      ).void
    end
    def initialize(reference: nil, description: nil, external_location: nil, content: nil,
                   mime_code: nil, filename: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :reference, :description, :external_location, :content, :mime_code, :filename

    sig do
      params(
        reference: T.nilable(String),
        description: T.nilable(String),
        external_location: T.nilable(String),
        content: T.nilable(String),
        mime_code: T.nilable(String),
        filename: T.nilable(String)
      ).returns(Facturx::SupportingDocument)
    end
    def with(reference: self.reference, description: self.description,
             external_location: self.external_location, content: self.content,
             mime_code: self.mime_code, filename: self.filename); end
  end

  class ProductAttribute
    sig { params(name: T.nilable(String), value: T.nilable(String)).void }
    def initialize(name: nil, value: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :name, :value

    sig { params(name: T.nilable(String), value: T.nilable(String)).returns(Facturx::ProductAttribute) }
    def with(name: self.name, value: self.value); end
  end

  class ProductClassification
    sig do
      params(code: T.nilable(String), list_id: T.nilable(String), list_version_id: T.nilable(String)).void
    end
    def initialize(code: nil, list_id: nil, list_version_id: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :code, :list_id, :list_version_id

    sig do
      params(code: T.nilable(String), list_id: T.nilable(String), list_version_id: T.nilable(String))
        .returns(Facturx::ProductClassification)
    end
    def with(code: self.code, list_id: self.list_id, list_version_id: self.list_version_id); end
  end

  class Product
    sig do
      params(
        name: T.nilable(String),
        description: T.nilable(String),
        seller_identifier: T.nilable(Facturx::Identifier),
        buyer_identifier: T.nilable(Facturx::Identifier),
        global_identifier: T.nilable(Facturx::Identifier),
        attributes: T::Array[Facturx::ProductAttribute],
        classifications: T::Array[Facturx::ProductClassification],
        origin_country_code: T.nilable(String)
      ).void
    end
    def initialize(name: nil, description: nil, seller_identifier: nil, buyer_identifier: nil,
                   global_identifier: nil, attributes: [], classifications: [], origin_country_code: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :name, :description, :origin_country_code

    sig { returns(T.nilable(Facturx::Identifier)) }
    def seller_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def buyer_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def global_identifier; end

    sig { returns(T::Array[Facturx::ProductAttribute]) }
    def attributes; end

    sig { returns(T::Array[Facturx::ProductClassification]) }
    def classifications; end

    sig do
      params(
        name: T.nilable(String),
        description: T.nilable(String),
        seller_identifier: T.nilable(Facturx::Identifier),
        buyer_identifier: T.nilable(Facturx::Identifier),
        global_identifier: T.nilable(Facturx::Identifier),
        attributes: T::Array[Facturx::ProductAttribute],
        classifications: T::Array[Facturx::ProductClassification],
        origin_country_code: T.nilable(String)
      ).returns(Facturx::Product)
    end
    def with(name: self.name, description: self.description,
             seller_identifier: self.seller_identifier, buyer_identifier: self.buyer_identifier,
             global_identifier: self.global_identifier, attributes: self.attributes,
             classifications: self.classifications, origin_country_code: self.origin_country_code); end
  end

  class Price
    sig do
      params(
        amount: T.nilable(T.any(::BigDecimal, Integer)),
        basis_quantity: T.nilable(Facturx::Quantity),
        discount: T.nilable(T.any(::BigDecimal, Integer))
      ).void
    end
    def initialize(amount: nil, basis_quantity: nil, discount: nil); end

    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :amount, :discount

    sig { returns(T.nilable(Facturx::Quantity)) }
    def basis_quantity; end

    sig do
      params(
        amount: T.nilable(T.any(::BigDecimal, Integer)),
        basis_quantity: T.nilable(Facturx::Quantity),
        discount: T.nilable(T.any(::BigDecimal, Integer))
      ).returns(Facturx::Price)
    end
    def with(amount: self.amount, basis_quantity: self.basis_quantity, discount: self.discount); end
  end

  class TaxBreakdown
    sig do
      params(
        type_code: T.nilable(String),
        category_code: T.nilable(String),
        rate: T.nilable(T.any(::BigDecimal, Integer)),
        basis_amount: T.nilable(T.any(::BigDecimal, Integer)),
        tax_amount: T.nilable(T.any(::BigDecimal, Integer)),
        exemption_reason: T.nilable(String),
        exemption_reason_code: T.nilable(String),
        due_date_type_code: T.nilable(String)
      ).void
    end
    def initialize(type_code: nil, category_code: nil, rate: nil, basis_amount: nil, tax_amount: nil,
                   exemption_reason: nil, exemption_reason_code: nil, due_date_type_code: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :type_code, :category_code, :exemption_reason, :exemption_reason_code, :due_date_type_code

    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :rate, :basis_amount, :tax_amount

    sig do
      params(
        type_code: T.nilable(String),
        category_code: T.nilable(String),
        rate: T.nilable(T.any(::BigDecimal, Integer)),
        basis_amount: T.nilable(T.any(::BigDecimal, Integer)),
        tax_amount: T.nilable(T.any(::BigDecimal, Integer)),
        exemption_reason: T.nilable(String),
        exemption_reason_code: T.nilable(String),
        due_date_type_code: T.nilable(String)
      ).returns(Facturx::TaxBreakdown)
    end
    def with(type_code: self.type_code, category_code: self.category_code, rate: self.rate,
             basis_amount: self.basis_amount, tax_amount: self.tax_amount,
             exemption_reason: self.exemption_reason,
             exemption_reason_code: self.exemption_reason_code,
             due_date_type_code: self.due_date_type_code); end
  end

  class AllowanceCharge
    sig do
      params(
        indicator: T.nilable(T::Boolean),
        amount: T.nilable(T.any(::BigDecimal, Integer)),
        base_amount: T.nilable(T.any(::BigDecimal, Integer)),
        percentage: T.nilable(T.any(::BigDecimal, Integer)),
        reason: T.nilable(String),
        reason_code: T.nilable(String),
        tax: T.nilable(Facturx::TaxBreakdown)
      ).void
    end
    def initialize(indicator: nil, amount: nil, base_amount: nil, percentage: nil, reason: nil,
                   reason_code: nil, tax: nil); end

    sig { returns(T.nilable(T::Boolean)) }
    attr_reader :indicator

    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :amount, :base_amount, :percentage

    sig { returns(T.nilable(String)) }
    attr_reader :reason, :reason_code

    sig { returns(T.nilable(Facturx::TaxBreakdown)) }
    def tax; end

    sig do
      params(
        indicator: T.nilable(T::Boolean),
        amount: T.nilable(T.any(::BigDecimal, Integer)),
        base_amount: T.nilable(T.any(::BigDecimal, Integer)),
        percentage: T.nilable(T.any(::BigDecimal, Integer)),
        reason: T.nilable(String),
        reason_code: T.nilable(String),
        tax: T.nilable(Facturx::TaxBreakdown)
      ).returns(Facturx::AllowanceCharge)
    end
    def with(indicator: self.indicator, amount: self.amount, base_amount: self.base_amount,
             percentage: self.percentage, reason: self.reason, reason_code: self.reason_code,
             tax: self.tax); end
  end

  class Totals
    sig do
      params(
        line_total: T.nilable(T.any(::BigDecimal, Integer)),
        charge_total: T.nilable(T.any(::BigDecimal, Integer)),
        allowance_total: T.nilable(T.any(::BigDecimal, Integer)),
        tax_basis_total: T.nilable(T.any(::BigDecimal, Integer)),
        tax_total: T.nilable(T.any(::BigDecimal, Integer)),
        tax_total_in_tax_currency: T.nilable(T.any(::BigDecimal, Integer)),
        grand_total: T.nilable(T.any(::BigDecimal, Integer)),
        prepaid: T.nilable(T.any(::BigDecimal, Integer)),
        rounding: T.nilable(T.any(::BigDecimal, Integer)),
        due_payable: T.nilable(T.any(::BigDecimal, Integer))
      ).void
    end
    def initialize(line_total: nil, charge_total: nil, allowance_total: nil, tax_basis_total: nil,
                   tax_total: nil, tax_total_in_tax_currency: nil, grand_total: nil, prepaid: nil,
                   rounding: nil, due_payable: nil); end

    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :line_total, :charge_total, :allowance_total, :tax_basis_total, :tax_total,
                :tax_total_in_tax_currency, :grand_total, :prepaid, :rounding, :due_payable

    sig do
      params(
        line_total: T.nilable(T.any(::BigDecimal, Integer)),
        charge_total: T.nilable(T.any(::BigDecimal, Integer)),
        allowance_total: T.nilable(T.any(::BigDecimal, Integer)),
        tax_basis_total: T.nilable(T.any(::BigDecimal, Integer)),
        tax_total: T.nilable(T.any(::BigDecimal, Integer)),
        tax_total_in_tax_currency: T.nilable(T.any(::BigDecimal, Integer)),
        grand_total: T.nilable(T.any(::BigDecimal, Integer)),
        prepaid: T.nilable(T.any(::BigDecimal, Integer)),
        rounding: T.nilable(T.any(::BigDecimal, Integer)),
        due_payable: T.nilable(T.any(::BigDecimal, Integer))
      ).returns(Facturx::Totals)
    end
    def with(line_total: self.line_total, charge_total: self.charge_total,
             allowance_total: self.allowance_total, tax_basis_total: self.tax_basis_total,
             tax_total: self.tax_total, tax_total_in_tax_currency: self.tax_total_in_tax_currency,
             grand_total: self.grand_total, prepaid: self.prepaid, rounding: self.rounding,
             due_payable: self.due_payable); end
  end

  class Line
    sig do
      params(
        id: T.nilable(String),
        note: T.nilable(String),
        product: T.nilable(Facturx::Product),
        quantity: T.nilable(Facturx::Quantity),
        gross_price: T.nilable(Facturx::Price),
        net_price: T.nilable(Facturx::Price),
        tax: T.nilable(Facturx::TaxBreakdown),
        period: T.nilable(Facturx::Period),
        net_amount: T.nilable(T.any(::BigDecimal, Integer)),
        allowances: T::Array[Facturx::AllowanceCharge],
        charges: T::Array[Facturx::AllowanceCharge],
        buyer_order_reference: T.nilable(Facturx::DocumentReference),
        invoiced_object_identifier: T.nilable(Facturx::Identifier),
        buyer_accounting_reference: T.nilable(String)
      ).void
    end
    def initialize(id: nil, note: nil, product: nil, quantity: nil, gross_price: nil,
                   net_price: nil, tax: nil, period: nil, net_amount: nil, allowances: [], charges: [],
                   buyer_order_reference: nil, invoiced_object_identifier: nil,
                   buyer_accounting_reference: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :id, :note, :buyer_accounting_reference

    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :net_amount

    sig { returns(T.nilable(Facturx::Product)) }
    def product; end

    sig { returns(T.nilable(Facturx::Quantity)) }
    def quantity; end

    sig { returns(T.nilable(Facturx::Price)) }
    def gross_price; end

    sig { returns(T.nilable(Facturx::Price)) }
    def net_price; end

    sig { returns(T.nilable(Facturx::TaxBreakdown)) }
    def tax; end

    sig { returns(T.nilable(Facturx::Period)) }
    def period; end

    sig { returns(T::Array[Facturx::AllowanceCharge]) }
    def allowances; end

    sig { returns(T::Array[Facturx::AllowanceCharge]) }
    def charges; end

    sig { returns(T.nilable(Facturx::DocumentReference)) }
    def buyer_order_reference; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def invoiced_object_identifier; end

    sig do
      params(
        id: T.nilable(String),
        note: T.nilable(String),
        product: T.nilable(Facturx::Product),
        quantity: T.nilable(Facturx::Quantity),
        gross_price: T.nilable(Facturx::Price),
        net_price: T.nilable(Facturx::Price),
        tax: T.nilable(Facturx::TaxBreakdown),
        period: T.nilable(Facturx::Period),
        net_amount: T.nilable(T.any(::BigDecimal, Integer)),
        allowances: T::Array[Facturx::AllowanceCharge],
        charges: T::Array[Facturx::AllowanceCharge],
        buyer_order_reference: T.nilable(Facturx::DocumentReference),
        invoiced_object_identifier: T.nilable(Facturx::Identifier),
        buyer_accounting_reference: T.nilable(String)
      ).returns(Facturx::Line)
    end
    def with(id: self.id, note: self.note, product: self.product, quantity: self.quantity,
             gross_price: self.gross_price, net_price: self.net_price, tax: self.tax,
             period: self.period, net_amount: self.net_amount, allowances: self.allowances,
             charges: self.charges, buyer_order_reference: self.buyer_order_reference,
             invoiced_object_identifier: self.invoiced_object_identifier,
             buyer_accounting_reference: self.buyer_accounting_reference); end
  end

  class Document
    sig do
      params(
        guideline_urn: T.nilable(String),
        business_process: T.nilable(String),
        invoice_number: T.nilable(String),
        type_code: T.nilable(String),
        issue_date: T.nilable(::Date),
        notes: T::Array[Facturx::Note],
        currency: T.nilable(String),
        tax_currency: T.nilable(String),
        vat_point_date: T.nilable(::Date),
        vat_point_date_code: T.nilable(String),
        buyer_reference: T.nilable(String),
        project_reference: T.nilable(Facturx::DocumentReference),
        contract_reference: T.nilable(Facturx::DocumentReference),
        purchase_order_reference: T.nilable(Facturx::DocumentReference),
        sales_order_reference: T.nilable(Facturx::DocumentReference),
        receiving_advice_reference: T.nilable(Facturx::DocumentReference),
        despatch_advice_reference: T.nilable(Facturx::DocumentReference),
        tender_or_lot_reference: T.nilable(Facturx::DocumentReference),
        invoiced_object_identifier: T.nilable(Facturx::Identifier),
        seller: T.nilable(Facturx::Party),
        buyer: T.nilable(Facturx::Party),
        payee: T.nilable(Facturx::Party),
        tax_representative: T.nilable(Facturx::Party),
        delivery: T.nilable(Facturx::Delivery),
        billing_period: T.nilable(Facturx::Period),
        payment: T.nilable(Facturx::PaymentInstructions),
        payment_terms: T.nilable(String),
        payment_due_date: T.nilable(::Date),
        lines: T::Array[Facturx::Line],
        tax_breakdowns: T::Array[Facturx::TaxBreakdown],
        allowances: T::Array[Facturx::AllowanceCharge],
        charges: T::Array[Facturx::AllowanceCharge],
        totals: T.nilable(Facturx::Totals),
        preceding_invoices: T::Array[Facturx::DocumentReference],
        supporting_documents: T::Array[Facturx::SupportingDocument],
        buyer_accounting_reference: T.nilable(String)
      ).void
    end
    def initialize(guideline_urn: nil, business_process: nil, invoice_number: nil, type_code: nil,
                   issue_date: nil, notes: [], currency: nil, tax_currency: nil,
                   vat_point_date: nil, vat_point_date_code: nil, buyer_reference: nil,
                   project_reference: nil, contract_reference: nil, purchase_order_reference: nil,
                   sales_order_reference: nil, receiving_advice_reference: nil,
                   despatch_advice_reference: nil, tender_or_lot_reference: nil,
                   invoiced_object_identifier: nil, seller: nil, buyer: nil, payee: nil,
                   tax_representative: nil, delivery: nil, billing_period: nil, payment: nil,
                   payment_terms: nil, payment_due_date: nil, lines: [], tax_breakdowns: [],
                   allowances: [], charges: [], totals: nil, preceding_invoices: [],
                   supporting_documents: [], buyer_accounting_reference: nil); end

    sig { returns(T.nilable(String)) }
    attr_reader :guideline_urn, :business_process, :invoice_number, :type_code, :currency, :tax_currency,
                :vat_point_date_code, :buyer_reference, :buyer_accounting_reference, :payment_terms

    sig { returns(T.nilable(::Date)) }
    attr_reader :issue_date, :vat_point_date, :payment_due_date

    sig do
      params(
        attributes: T.untyped,
        block: T.nilable(T.proc.params(builder: Facturx::Builders::DocumentBuilder).void)
      ).returns(Facturx::Document)
    end
    def self.build(**attributes, &block); end

    sig { returns(T.nilable(Facturx::DocumentReference)) }
    def project_reference; end

    sig { returns(T.nilable(Facturx::DocumentReference)) }
    def contract_reference; end

    sig { returns(T.nilable(Facturx::DocumentReference)) }
    def purchase_order_reference; end

    sig { returns(T.nilable(Facturx::DocumentReference)) }
    def sales_order_reference; end

    sig { returns(T.nilable(Facturx::DocumentReference)) }
    def receiving_advice_reference; end

    sig { returns(T.nilable(Facturx::DocumentReference)) }
    def despatch_advice_reference; end

    sig { returns(T.nilable(Facturx::DocumentReference)) }
    def tender_or_lot_reference; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def invoiced_object_identifier; end

    sig { returns(T.nilable(Facturx::Party)) }
    def seller; end

    sig { returns(T.nilable(Facturx::Party)) }
    def buyer; end

    sig { returns(T.nilable(Facturx::Party)) }
    def payee; end

    sig { returns(T.nilable(Facturx::Party)) }
    def tax_representative; end

    sig { returns(T.nilable(Facturx::Delivery)) }
    def delivery; end

    sig { returns(T.nilable(Facturx::Period)) }
    def billing_period; end

    sig { returns(T.nilable(Facturx::PaymentInstructions)) }
    def payment; end

    sig { returns(T::Array[Facturx::Note]) }
    def notes; end

    sig { returns(T::Array[Facturx::Line]) }
    def lines; end

    sig { returns(T::Array[Facturx::TaxBreakdown]) }
    def tax_breakdowns; end

    sig { returns(T::Array[Facturx::AllowanceCharge]) }
    def allowances; end

    sig { returns(T::Array[Facturx::AllowanceCharge]) }
    def charges; end

    sig { returns(T.nilable(Facturx::Totals)) }
    def totals; end

    sig { returns(T::Array[Facturx::DocumentReference]) }
    def preceding_invoices; end

    sig { returns(T::Array[Facturx::SupportingDocument]) }
    def supporting_documents; end

    sig do
      params(
        guideline_urn: T.nilable(String),
        business_process: T.nilable(String),
        invoice_number: T.nilable(String),
        type_code: T.nilable(String),
        issue_date: T.nilable(::Date),
        notes: T::Array[Facturx::Note],
        currency: T.nilable(String),
        tax_currency: T.nilable(String),
        vat_point_date: T.nilable(::Date),
        vat_point_date_code: T.nilable(String),
        buyer_reference: T.nilable(String),
        project_reference: T.nilable(Facturx::DocumentReference),
        contract_reference: T.nilable(Facturx::DocumentReference),
        purchase_order_reference: T.nilable(Facturx::DocumentReference),
        sales_order_reference: T.nilable(Facturx::DocumentReference),
        receiving_advice_reference: T.nilable(Facturx::DocumentReference),
        despatch_advice_reference: T.nilable(Facturx::DocumentReference),
        tender_or_lot_reference: T.nilable(Facturx::DocumentReference),
        invoiced_object_identifier: T.nilable(Facturx::Identifier),
        seller: T.nilable(Facturx::Party),
        buyer: T.nilable(Facturx::Party),
        payee: T.nilable(Facturx::Party),
        tax_representative: T.nilable(Facturx::Party),
        delivery: T.nilable(Facturx::Delivery),
        billing_period: T.nilable(Facturx::Period),
        payment: T.nilable(Facturx::PaymentInstructions),
        payment_terms: T.nilable(String),
        payment_due_date: T.nilable(::Date),
        lines: T::Array[Facturx::Line],
        tax_breakdowns: T::Array[Facturx::TaxBreakdown],
        allowances: T::Array[Facturx::AllowanceCharge],
        charges: T::Array[Facturx::AllowanceCharge],
        totals: T.nilable(Facturx::Totals),
        preceding_invoices: T::Array[Facturx::DocumentReference],
        supporting_documents: T::Array[Facturx::SupportingDocument],
        buyer_accounting_reference: T.nilable(String)
      ).returns(Facturx::Document)
    end
    def with(guideline_urn: self.guideline_urn, business_process: self.business_process,
             invoice_number: self.invoice_number, type_code: self.type_code, issue_date: self.issue_date,
             notes: self.notes, currency: self.currency, tax_currency: self.tax_currency,
             vat_point_date: self.vat_point_date, vat_point_date_code: self.vat_point_date_code,
             buyer_reference: self.buyer_reference, project_reference: self.project_reference,
             contract_reference: self.contract_reference,
             purchase_order_reference: self.purchase_order_reference,
             sales_order_reference: self.sales_order_reference,
             receiving_advice_reference: self.receiving_advice_reference,
             despatch_advice_reference: self.despatch_advice_reference,
             tender_or_lot_reference: self.tender_or_lot_reference,
             invoiced_object_identifier: self.invoiced_object_identifier, seller: self.seller,
             buyer: self.buyer, payee: self.payee, tax_representative: self.tax_representative,
             delivery: self.delivery, billing_period: self.billing_period, payment: self.payment,
             payment_terms: self.payment_terms, payment_due_date: self.payment_due_date,
             lines: self.lines, tax_breakdowns: self.tax_breakdowns, allowances: self.allowances,
             charges: self.charges, totals: self.totals, preceding_invoices: self.preceding_invoices,
             supporting_documents: self.supporting_documents,
             buyer_accounting_reference: self.buyer_accounting_reference); end
  end

  module Builders
    class Base
      sig { params(attributes: T.untyped).void }
      def initialize(**attributes); end

      sig { returns(T.untyped) }
      def build; end
    end

    class NoteBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :content, :subject_code
      sig { params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: NoteBuilder).void)).returns(Note) }
      def self.build(**attributes, &block); end
      sig { returns(Note) }
      def build; end
    end

    class IdentifierBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :value, :scheme_id
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void))
          .returns(Identifier)
      end
      def self.build(**attributes, &block); end
      sig { returns(Identifier) }
      def build; end
    end

    class PeriodBuilder < Base
      sig { returns(T.nilable(::Date)) }
      attr_accessor :start_date, :end_date
      sig { params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: PeriodBuilder).void)).returns(Period) }
      def self.build(**attributes, &block); end
      sig { returns(Period) }
      def build; end
    end

    class QuantityBuilder < Base
      sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
      attr_accessor :value

      sig { returns(T.nilable(String)) }
      attr_accessor :unit_code
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: QuantityBuilder).void))
          .returns(Quantity)
      end
      def self.build(**attributes, &block); end
      sig { returns(Quantity) }
      def build; end
    end

    class ContactBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :name, :telephone, :email
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: ContactBuilder).void))
          .returns(Contact)
      end
      def self.build(**attributes, &block); end
      sig { returns(Contact) }
      def build; end
    end

    class AddressBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :postcode, :line_one, :line_two, :line_three, :city, :country_code, :country_subdivision
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: AddressBuilder).void))
          .returns(Address)
      end
      def self.build(**attributes, &block); end
      sig { returns(Address) }
      def build; end
    end

    class PartyBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :name, :description, :trading_name

      sig { params(identifiers: T::Array[Identifier]).returns(T::Array[Identifier]) }
      attr_writer :identifiers

      sig { returns(T::Array[Identifier]) }
      attr_reader :identifiers

      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def identifier(value = T.unsafe(nil), **attributes, &block); end

      sig { params(legal_registration: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :legal_registration

      sig { params(vat_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :vat_identifier

      sig { params(tax_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :tax_identifier

      sig { params(electronic_address: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :electronic_address

      sig { params(address: T.nilable(Address)).returns(T.nilable(Address)) }
      attr_writer :address

      sig { params(contact: T.nilable(Contact)).returns(T.nilable(Contact)) }
      attr_writer :contact

      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def legal_registration(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Address, attributes: T.untyped, block: T.nilable(T.proc.params(builder: AddressBuilder).void)).returns(Address) }
      def address(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def vat_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def tax_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def electronic_address(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Contact, attributes: T.untyped, block: T.nilable(T.proc.params(builder: ContactBuilder).void)).returns(Contact) }
      def contact(value = T.unsafe(nil), **attributes, &block); end
      sig { params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: PartyBuilder).void)).returns(Party) }
      def self.build(**attributes, &block); end
      sig { returns(Party) }
      def build; end
    end

    class CreditTransferBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :account_name

      sig { params(account_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :account_identifier

      sig { params(provider_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :provider_identifier

      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def account_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def provider_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: CreditTransferBuilder).void))
          .returns(CreditTransfer)
      end
      def self.build(**attributes, &block); end
      sig { returns(CreditTransfer) }
      def build; end
    end

    class PaymentCardBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :primary_account_number, :holder_name
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: PaymentCardBuilder).void))
          .returns(PaymentCard)
      end
      def self.build(**attributes, &block); end
      sig { returns(PaymentCard) }
      def build; end
    end

    class DirectDebitBuilder < Base
      sig { params(mandate_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :mandate_identifier

      sig { params(creditor_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :creditor_identifier

      sig { params(debtor_account_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :debtor_account_identifier

      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def mandate_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def creditor_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def debtor_account_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: DirectDebitBuilder).void))
          .returns(DirectDebit)
      end
      def self.build(**attributes, &block); end
      sig { returns(DirectDebit) }
      def build; end
    end

    class PaymentInstructionsBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :means_code, :means_text, :remittance_information

      sig { params(credit_transfers: T::Array[CreditTransfer]).returns(T::Array[CreditTransfer]) }
      attr_writer :credit_transfers

      sig { returns(T::Array[CreditTransfer]) }
      attr_reader :credit_transfers

      sig { params(value: CreditTransfer, attributes: T.untyped, block: T.nilable(T.proc.params(builder: CreditTransferBuilder).void)).returns(CreditTransfer) }
      def credit_transfer(value = T.unsafe(nil), **attributes, &block); end

      sig { params(payment_card: T.nilable(PaymentCard)).returns(T.nilable(PaymentCard)) }
      attr_writer :payment_card

      sig { params(direct_debit: T.nilable(DirectDebit)).returns(T.nilable(DirectDebit)) }
      attr_writer :direct_debit

      sig { params(value: PaymentCard, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PaymentCardBuilder).void)).returns(PaymentCard) }
      def payment_card(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: DirectDebit, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DirectDebitBuilder).void)).returns(DirectDebit) }
      def direct_debit(value = T.unsafe(nil), **attributes, &block); end
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: PaymentInstructionsBuilder).void))
          .returns(PaymentInstructions)
      end
      def self.build(**attributes, &block); end
      sig { returns(PaymentInstructions) }
      def build; end
    end

    class DocumentReferenceBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :id, :line_id, :name

      sig { returns(T.nilable(::Date)) }
      attr_accessor :issue_date
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void))
          .returns(DocumentReference)
      end
      def self.build(**attributes, &block); end
      sig { returns(DocumentReference) }
      def build; end
    end

    class DeliveryBuilder < Base
      sig { returns(T.nilable(::Date)) }
      attr_accessor :date

      sig { params(location_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :location_identifier

      sig { params(party: T.nilable(Party)).returns(T.nilable(Party)) }
      attr_writer :party

      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def location_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Party, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PartyBuilder).void)).returns(Party) }
      def party(value = T.unsafe(nil), **attributes, &block); end
      sig { params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: DeliveryBuilder).void)).returns(Delivery) }
      def self.build(**attributes, &block); end
      sig { returns(Delivery) }
      def build; end
    end

    class SupportingDocumentBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :reference, :description, :external_location, :content, :mime_code, :filename
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: SupportingDocumentBuilder).void))
          .returns(SupportingDocument)
      end
      def self.build(**attributes, &block); end
      sig { returns(SupportingDocument) }
      def build; end
    end

    class ProductAttributeBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :name, :value
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: ProductAttributeBuilder).void))
          .returns(ProductAttribute)
      end
      def self.build(**attributes, &block); end
      sig { returns(ProductAttribute) }
      def build; end
    end

    class ProductClassificationBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :code, :list_id, :list_version_id
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: ProductClassificationBuilder).void))
          .returns(ProductClassification)
      end
      def self.build(**attributes, &block); end
      sig { returns(ProductClassification) }
      def build; end
    end

    class ProductBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :name, :description, :origin_country_code

      sig { params(seller_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :seller_identifier

      sig { params(buyer_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :buyer_identifier

      sig { params(global_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :global_identifier

      sig { params(attributes: T::Array[ProductAttribute]).returns(T::Array[ProductAttribute]) }
      attr_writer :attributes

      sig { returns(T::Array[ProductAttribute]) }
      attr_reader :attributes

      sig { params(classifications: T::Array[ProductClassification]).returns(T::Array[ProductClassification]) }
      attr_writer :classifications

      sig { returns(T::Array[ProductClassification]) }
      attr_reader :classifications

      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def seller_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def buyer_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def global_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: ProductAttribute, attributes: T.untyped, block: T.nilable(T.proc.params(builder: ProductAttributeBuilder).void)).returns(ProductAttribute) }
      def attribute(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: ProductClassification, attributes: T.untyped, block: T.nilable(T.proc.params(builder: ProductClassificationBuilder).void)).returns(ProductClassification) }
      def classification(value = T.unsafe(nil), **attributes, &block); end
      sig { params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: ProductBuilder).void)).returns(Product) }
      def self.build(**attributes, &block); end
      sig { returns(Product) }
      def build; end
    end

    class PriceBuilder < Base
      sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
      attr_accessor :amount, :discount

      sig { params(basis_quantity: T.nilable(Quantity)).returns(T.nilable(Quantity)) }
      attr_writer :basis_quantity

      sig { params(value: Quantity, attributes: T.untyped, block: T.nilable(T.proc.params(builder: QuantityBuilder).void)).returns(Quantity) }
      def basis_quantity(value = T.unsafe(nil), **attributes, &block); end
      sig { params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: PriceBuilder).void)).returns(Price) }
      def self.build(**attributes, &block); end
      sig { returns(Price) }
      def build; end
    end

    class TaxBreakdownBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :type_code, :category_code, :exemption_reason, :exemption_reason_code, :due_date_type_code

      sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
      attr_accessor :rate, :basis_amount, :tax_amount
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: TaxBreakdownBuilder).void))
          .returns(TaxBreakdown)
      end
      def self.build(**attributes, &block); end
      sig { returns(TaxBreakdown) }
      def build; end
    end

    class AllowanceChargeBuilder < Base
      sig { returns(T.nilable(T::Boolean)) }
      attr_accessor :indicator

      sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
      attr_accessor :amount, :base_amount, :percentage

      sig { returns(T.nilable(String)) }
      attr_accessor :reason, :reason_code

      sig { params(tax: T.nilable(TaxBreakdown)).returns(T.nilable(TaxBreakdown)) }
      attr_writer :tax

      sig { params(value: TaxBreakdown, attributes: T.untyped, block: T.nilable(T.proc.params(builder: TaxBreakdownBuilder).void)).returns(TaxBreakdown) }
      def tax(value = T.unsafe(nil), **attributes, &block); end
      sig do
        params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: AllowanceChargeBuilder).void))
          .returns(AllowanceCharge)
      end
      def self.build(**attributes, &block); end
      sig { returns(AllowanceCharge) }
      def build; end
    end

    class TotalsBuilder < Base
      sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
      attr_accessor :line_total, :charge_total, :allowance_total, :tax_basis_total, :tax_total,
                    :tax_total_in_tax_currency, :grand_total, :prepaid, :rounding, :due_payable
      sig { params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: TotalsBuilder).void)).returns(Totals) }
      def self.build(**attributes, &block); end
      sig { returns(Totals) }
      def build; end
    end

    class LineBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :id, :note, :buyer_accounting_reference

      sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
      attr_accessor :net_amount

      sig { params(product: T.nilable(Product)).returns(T.nilable(Product)) }
      attr_writer :product

      sig { params(quantity: T.nilable(Quantity)).returns(T.nilable(Quantity)) }
      attr_writer :quantity

      sig { params(gross_price: T.nilable(Price)).returns(T.nilable(Price)) }
      attr_writer :gross_price

      sig { params(net_price: T.nilable(Price)).returns(T.nilable(Price)) }
      attr_writer :net_price

      sig { params(tax: T.nilable(TaxBreakdown)).returns(T.nilable(TaxBreakdown)) }
      attr_writer :tax

      sig { params(period: T.nilable(Period)).returns(T.nilable(Period)) }
      attr_writer :period

      sig { params(allowances: T::Array[AllowanceCharge]).returns(T::Array[AllowanceCharge]) }
      attr_writer :allowances

      sig { params(charges: T::Array[AllowanceCharge]).returns(T::Array[AllowanceCharge]) }
      attr_writer :charges

      sig { returns(T::Array[AllowanceCharge]) }
      attr_reader :allowances, :charges

      sig { params(buyer_order_reference: T.nilable(DocumentReference)).returns(T.nilable(DocumentReference)) }
      attr_writer :buyer_order_reference

      sig { params(invoiced_object_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :invoiced_object_identifier

      sig { params(value: Product, attributes: T.untyped, block: T.nilable(T.proc.params(builder: ProductBuilder).void)).returns(Product) }
      def product(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Quantity, attributes: T.untyped, block: T.nilable(T.proc.params(builder: QuantityBuilder).void)).returns(Quantity) }
      def quantity(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Price, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PriceBuilder).void)).returns(Price) }
      def gross_price(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Price, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PriceBuilder).void)).returns(Price) }
      def net_price(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: TaxBreakdown, attributes: T.untyped, block: T.nilable(T.proc.params(builder: TaxBreakdownBuilder).void)).returns(TaxBreakdown) }
      def tax(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Period, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PeriodBuilder).void)).returns(Period) }
      def period(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: AllowanceCharge, attributes: T.untyped, block: T.nilable(T.proc.params(builder: AllowanceChargeBuilder).void)).returns(AllowanceCharge) }
      def allowance(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: AllowanceCharge, attributes: T.untyped, block: T.nilable(T.proc.params(builder: AllowanceChargeBuilder).void)).returns(AllowanceCharge) }
      def charge(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: DocumentReference, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void)).returns(DocumentReference) }
      def buyer_order_reference(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def invoiced_object_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: LineBuilder).void)).returns(Line) }
      def self.build(**attributes, &block); end
      sig { returns(Line) }
      def build; end
    end

    class DocumentBuilder < Base
      sig { returns(T.nilable(String)) }
      attr_accessor :guideline_urn, :business_process, :invoice_number, :type_code, :currency, :tax_currency,
                    :vat_point_date_code, :buyer_reference, :buyer_accounting_reference, :payment_terms

      sig { returns(T.nilable(::Date)) }
      attr_accessor :issue_date, :vat_point_date, :payment_due_date

      sig { params(project_reference: T.nilable(DocumentReference)).returns(T.nilable(DocumentReference)) }
      attr_writer :project_reference

      sig { params(contract_reference: T.nilable(DocumentReference)).returns(T.nilable(DocumentReference)) }
      attr_writer :contract_reference

      sig do
        params(purchase_order_reference: T.nilable(DocumentReference)).returns(T.nilable(DocumentReference))
      end
      attr_writer :purchase_order_reference

      sig { params(sales_order_reference: T.nilable(DocumentReference)).returns(T.nilable(DocumentReference)) }
      attr_writer :sales_order_reference

      sig do
        params(receiving_advice_reference: T.nilable(DocumentReference)).returns(T.nilable(DocumentReference))
      end
      attr_writer :receiving_advice_reference

      sig do
        params(despatch_advice_reference: T.nilable(DocumentReference)).returns(T.nilable(DocumentReference))
      end
      attr_writer :despatch_advice_reference

      sig do
        params(tender_or_lot_reference: T.nilable(DocumentReference)).returns(T.nilable(DocumentReference))
      end
      attr_writer :tender_or_lot_reference

      sig { params(invoiced_object_identifier: T.nilable(Identifier)).returns(T.nilable(Identifier)) }
      attr_writer :invoiced_object_identifier

      sig { params(seller: T.nilable(Party)).returns(T.nilable(Party)) }
      attr_writer :seller

      sig { params(buyer: T.nilable(Party)).returns(T.nilable(Party)) }
      attr_writer :buyer

      sig { params(payee: T.nilable(Party)).returns(T.nilable(Party)) }
      attr_writer :payee

      sig { params(tax_representative: T.nilable(Party)).returns(T.nilable(Party)) }
      attr_writer :tax_representative

      sig { params(delivery: T.nilable(Delivery)).returns(T.nilable(Delivery)) }
      attr_writer :delivery

      sig { params(billing_period: T.nilable(Period)).returns(T.nilable(Period)) }
      attr_writer :billing_period

      sig { params(payment: T.nilable(PaymentInstructions)).returns(T.nilable(PaymentInstructions)) }
      attr_writer :payment

      sig { params(totals: T.nilable(Totals)).returns(T.nilable(Totals)) }
      attr_writer :totals

      sig { params(notes: T::Array[Note]).returns(T::Array[Note]) }
      attr_writer :notes

      sig { returns(T::Array[Note]) }
      attr_reader :notes

      sig { params(lines: T::Array[Line]).returns(T::Array[Line]) }
      attr_writer :lines

      sig { returns(T::Array[Line]) }
      attr_reader :lines

      sig { params(tax_breakdowns: T::Array[TaxBreakdown]).returns(T::Array[TaxBreakdown]) }
      attr_writer :tax_breakdowns

      sig { returns(T::Array[TaxBreakdown]) }
      attr_reader :tax_breakdowns

      sig { params(allowances: T::Array[AllowanceCharge]).returns(T::Array[AllowanceCharge]) }
      attr_writer :allowances

      sig { params(charges: T::Array[AllowanceCharge]).returns(T::Array[AllowanceCharge]) }
      attr_writer :charges

      sig { returns(T::Array[AllowanceCharge]) }
      attr_reader :allowances, :charges

      sig do
        params(preceding_invoices: T::Array[DocumentReference]).returns(T::Array[DocumentReference])
      end
      attr_writer :preceding_invoices

      sig { returns(T::Array[DocumentReference]) }
      attr_reader :preceding_invoices

      sig do
        params(supporting_documents: T::Array[SupportingDocument]).returns(T::Array[SupportingDocument])
      end
      attr_writer :supporting_documents

      sig { returns(T::Array[SupportingDocument]) }
      attr_reader :supporting_documents

      sig { params(value: DocumentReference, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void)).returns(DocumentReference) }
      def project_reference(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: DocumentReference, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void)).returns(DocumentReference) }
      def contract_reference(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: DocumentReference, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void)).returns(DocumentReference) }
      def purchase_order_reference(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: DocumentReference, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void)).returns(DocumentReference) }
      def sales_order_reference(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: DocumentReference, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void)).returns(DocumentReference) }
      def receiving_advice_reference(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: DocumentReference, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void)).returns(DocumentReference) }
      def despatch_advice_reference(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: DocumentReference, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void)).returns(DocumentReference) }
      def tender_or_lot_reference(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Identifier, attributes: T.untyped, block: T.nilable(T.proc.params(builder: IdentifierBuilder).void)).returns(Identifier) }
      def invoiced_object_identifier(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Party, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PartyBuilder).void)).returns(Party) }
      def seller(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Party, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PartyBuilder).void)).returns(Party) }
      def buyer(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Party, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PartyBuilder).void)).returns(Party) }
      def payee(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Party, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PartyBuilder).void)).returns(Party) }
      def tax_representative(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Delivery, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DeliveryBuilder).void)).returns(Delivery) }
      def delivery(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Period, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PeriodBuilder).void)).returns(Period) }
      def billing_period(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: PaymentInstructions, attributes: T.untyped, block: T.nilable(T.proc.params(builder: PaymentInstructionsBuilder).void)).returns(PaymentInstructions) }
      def payment(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Totals, attributes: T.untyped, block: T.nilable(T.proc.params(builder: TotalsBuilder).void)).returns(Totals) }
      def totals(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Note, attributes: T.untyped, block: T.nilable(T.proc.params(builder: NoteBuilder).void)).returns(Note) }
      def note(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: Line, attributes: T.untyped, block: T.nilable(T.proc.params(builder: LineBuilder).void)).returns(Line) }
      def line(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: TaxBreakdown, attributes: T.untyped, block: T.nilable(T.proc.params(builder: TaxBreakdownBuilder).void)).returns(TaxBreakdown) }
      def tax_breakdown(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: AllowanceCharge, attributes: T.untyped, block: T.nilable(T.proc.params(builder: AllowanceChargeBuilder).void)).returns(AllowanceCharge) }
      def allowance(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: AllowanceCharge, attributes: T.untyped, block: T.nilable(T.proc.params(builder: AllowanceChargeBuilder).void)).returns(AllowanceCharge) }
      def charge(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: DocumentReference, attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentReferenceBuilder).void)).returns(DocumentReference) }
      def preceding_invoice(value = T.unsafe(nil), **attributes, &block); end
      sig { params(value: SupportingDocument, attributes: T.untyped, block: T.nilable(T.proc.params(builder: SupportingDocumentBuilder).void)).returns(SupportingDocument) }
      def supporting_document(value = T.unsafe(nil), **attributes, &block); end
      sig { params(attributes: T.untyped, block: T.nilable(T.proc.params(builder: DocumentBuilder).void)).returns(Document) }
      def self.build(**attributes, &block); end
      sig { returns(Document) }
      def build; end
    end
  end

  private_constant :Builders
end
