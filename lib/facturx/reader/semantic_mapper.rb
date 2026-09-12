# frozen_string_literal: true

module Facturx
  class Reader
    class SemanticMapper
      EMPTY_TERMS = [].freeze
      TaxBreakdownResult = Data.define(:items, :vat_point_date)

      def initialize(document:, profile:, registry:, coercer:, diagnostics:)
        @document = document
        @profile = profile
        @terms = TermReader.new(document:, profile:, registry:, coercer:, diagnostics:)
        @registry = registry
        active_terms = registry.for_profile(profile)
        @terms_by_model_and_group = active_terms.group_by { |term| [term.model, term.group_id] }.freeze
        @terms_by_model_and_attribute = active_terms.group_by { |term| [term.model, term.attribute] }.freeze
      end

      def call
        tax_breakdowns = read_tax_breakdowns
        attributes = document_attributes(tax_breakdowns).merge(
          party_attributes, transaction_attributes, collection_attributes(tax_breakdowns.items)
        )
        attributes[:totals] = totals(attributes[:currency], attributes[:tax_currency])
        Document.new(**attributes)
      end

      def add_unmapped(root)
        @terms.add_unmapped(root)
      end

      private

      def party_attributes
        {
          seller: party('BG-4', contact_group: 'BG-6', address_group: 'BG-5'),
          buyer: party('BG-7', contact_group: 'BG-9', address_group: 'BG-8'),
          payee: party('BG-10'),
          tax_representative: party('BG-11', address_group: 'BG-12')
        }
      end

      def transaction_attributes
        {
          delivery: delivery, billing_period: period('BG-14'), payment: payment
        }
      end

      def collection_attributes(tax_breakdowns)
        {
          notes: notes, lines: lines, tax_breakdowns:,
          allowances: allowance_charges('BG-20', charge: false),
          charges: allowance_charges('BG-21', charge: true),
          preceding_invoices: preceding_invoices, supporting_documents: supporting_documents
        }
      end
    end
  end
end

require_relative 'semantic_mapper/document_mapping'
require_relative 'semantic_mapper/party_mapping'
require_relative 'semantic_mapper/delivery_mapping'
require_relative 'semantic_mapper/payment_mapping'
require_relative 'semantic_mapper/line_mapping'
require_relative 'semantic_mapper/line_references'
require_relative 'semantic_mapper/trade_mapping'
require_relative 'semantic_mapper/helpers'
