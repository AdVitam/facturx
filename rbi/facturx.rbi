# typed: strict

module Facturx
  class Error < StandardError
    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :details
  end

  class InvalidXmlError < Error; end
  class UnknownProfileError < InvalidXmlError; end
  class XsdValidationError < InvalidXmlError; end
  class UnsupportedProfileError < Error; end
  class FormattingError < Error; end
  class ConformanceError < Error; end
  class InvalidPdfError < Error; end
  class ProtectedPdfError < InvalidPdfError; end
  class ComposerUnavailableError < Error; end
  class CompositionError < Error; end
  class ExtractionError < Error; end
  class VerificationError < Error; end

  class << self
    sig { params(xml: String).returns(TrueClass) }
    def verify_xml(xml:); end

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
        .returns(Facturx::Conformance::Report)
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

  module Conformance
    class Issue
      sig { returns(Symbol) }
      attr_reader :code

      sig { returns(String) }
      attr_reader :message

      sig { returns(T.nilable(String)) }
      attr_reader :term_id, :group_id, :path

      sig { returns(T::Hash[Symbol, T.untyped]) }
      attr_reader :details
    end

    class Report
      sig { returns(Facturx::Profile) }
      attr_reader :profile

      sig { returns(T::Array[Facturx::Conformance::Issue]) }
      attr_reader :issues

      sig { returns(T::Boolean) }
      def valid?; end

      sig { returns(T::Boolean) }
      def invalid?; end
    end
  end

  class ProfileResolver
    sig { params(profile: T.any(Symbol, Facturx::Profile)).returns(Facturx::Profile) }
    def call(profile); end
  end

  class Writer
    sig { params(document: Facturx::Document, profile: Facturx::Profile).returns(String) }
    def call(document:, profile:); end

    sig do
      params(document: Facturx::Document, profile: Facturx::Profile)
        .returns(Facturx::Conformance::Report)
    end
    def validate(document:, profile:); end
  end

  class Generate
    sig do
      params(pdf: String, document: Facturx::Document, profile: T.any(Symbol, Facturx::Profile))
        .returns(String)
    end
    def call(pdf:, document:, profile:); end
  end

  class Profile
    sig { returns(Symbol) }
    def id; end

    sig { returns(String) }
    def guideline_urn; end

    sig { returns(String) }
    def xsd_path; end

    sig { returns(String) }
    def conformance_level; end
  end

  class Diagnostic
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
  end

  class Reading
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
  end

  class Note
    sig { returns(T.nilable(String)) }
    attr_reader :content, :subject_code
  end

  class Identifier
    sig { returns(T.nilable(String)) }
    attr_reader :value, :scheme_id
  end

  class Period
    sig { returns(T.nilable(::Date)) }
    attr_reader :start_date, :end_date
  end

  class Quantity
    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :value

    sig { returns(T.nilable(String)) }
    attr_reader :unit_code
  end

  class Contact
    sig { returns(T.nilable(String)) }
    attr_reader :name, :telephone, :email
  end

  class Address
    sig { returns(T.nilable(String)) }
    attr_reader :postcode, :line_one, :line_two, :line_three, :city, :country_code, :country_subdivision
  end

  class Party
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
  end

  class CreditTransfer
    sig { returns(T.nilable(String)) }
    attr_reader :account_name

    sig { returns(T.nilable(Facturx::Identifier)) }
    def account_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def provider_identifier; end
  end

  class PaymentCard
    sig { returns(T.nilable(String)) }
    attr_reader :primary_account_number, :holder_name
  end

  class DirectDebit
    sig { returns(T.nilable(Facturx::Identifier)) }
    def mandate_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def creditor_identifier; end

    sig { returns(T.nilable(Facturx::Identifier)) }
    def debtor_account_identifier; end
  end

  class PaymentInstructions
    sig { returns(T.nilable(String)) }
    attr_reader :means_code, :means_text, :remittance_information

    sig { returns(T::Array[Facturx::CreditTransfer]) }
    def credit_transfers; end

    sig { returns(T.nilable(Facturx::PaymentCard)) }
    def payment_card; end

    sig { returns(T.nilable(Facturx::DirectDebit)) }
    def direct_debit; end
  end

  class DocumentReference
    sig { returns(T.nilable(String)) }
    attr_reader :id, :line_id, :name

    sig { returns(T.nilable(::Date)) }
    attr_reader :issue_date
  end

  class Delivery
    sig { returns(T.nilable(::Date)) }
    attr_reader :date

    sig { returns(T.nilable(Facturx::Identifier)) }
    def location_identifier; end

    sig { returns(T.nilable(Facturx::Party)) }
    def party; end
  end

  class SupportingDocument
    sig { returns(T.nilable(String)) }
    attr_reader :reference, :description, :external_location, :content, :mime_code, :filename
  end

  class ProductAttribute
    sig { returns(T.nilable(String)) }
    attr_reader :name, :value
  end

  class ProductClassification
    sig { returns(T.nilable(String)) }
    attr_reader :code, :list_id, :list_version_id
  end

  class Product
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
  end

  class Price
    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :amount, :discount

    sig { returns(T.nilable(Facturx::Quantity)) }
    def basis_quantity; end
  end

  class TaxBreakdown
    sig { returns(T.nilable(String)) }
    attr_reader :type_code, :category_code, :exemption_reason, :exemption_reason_code, :due_date_type_code

    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :rate, :basis_amount, :tax_amount
  end

  class AllowanceCharge
    sig { returns(T.nilable(T::Boolean)) }
    attr_reader :indicator

    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :amount, :base_amount, :percentage

    sig { returns(T.nilable(String)) }
    attr_reader :reason, :reason_code

    sig { returns(T.nilable(Facturx::TaxBreakdown)) }
    def tax; end
  end

  class Totals
    sig { returns(T.nilable(T.any(::BigDecimal, Integer))) }
    attr_reader :line_total, :charge_total, :allowance_total, :tax_basis_total, :tax_total,
                :tax_total_in_tax_currency, :grand_total, :prepaid, :rounding, :due_payable
  end

  class Line
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
  end

  class Document
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
end
