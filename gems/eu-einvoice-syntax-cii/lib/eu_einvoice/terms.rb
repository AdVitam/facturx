# frozen_string_literal: true

require 'eu_einvoice/term'
require 'eu_einvoice/group'
require 'eu_einvoice/terms/declaration'
require 'eu_einvoice/terms/selections'
require 'eu_einvoice/terms/reference'
require 'eu_einvoice/terms/declarations/document'
require 'eu_einvoice/terms/declarations/parties'
require 'eu_einvoice/terms/declarations/references'
require 'eu_einvoice/terms/declarations/delivery'
require 'eu_einvoice/terms/declarations/payment'
require 'eu_einvoice/terms/declarations/taxes'
require 'eu_einvoice/terms/declarations/adjustments'
require 'eu_einvoice/terms/declarations/totals'
require 'eu_einvoice/terms/declarations/lines'
require 'eu_einvoice/terms/declarations/products'
require 'eu_einvoice/terms/declarations/groups'

module EuEinvoice
  module Terms
    TYPES = %i[string decimal date_102 boolean binary].freeze
    SCALES = [nil, 2].freeze
    CARDINALITIES = ['0..1', '1..1', '0..n', '1..n'].freeze

    ALL = [
      *TermDeclarations::DOCUMENT,
      *TermDeclarations::PARTIES,
      *TermDeclarations::REFERENCES,
      *TermDeclarations::DELIVERY,
      *TermDeclarations::PAYMENT,
      *TermDeclarations::TAXES,
      *TermDeclarations::ADJUSTMENTS,
      *TermDeclarations::TOTALS,
      *TermDeclarations::LINES,
      *TermDeclarations::PRODUCTS
    ].freeze
    GROUPS = TermDeclarations::GROUPS
    BY_ID = ALL.to_h { |term| [term.id, term] }.freeze
    GROUPS_BY_ID = GROUPS.to_h { |group| [group.id, group] }.freeze
    SELECTIONS = Selections.new(ALL)
    private_constant :SELECTIONS

    module_function

    def all
      ALL
    end

    def groups
      GROUPS
    end

    def fetch(id)
      BY_ID.fetch(id.to_s)
    end

    def group(id)
      GROUPS_BY_ID.fetch(id.to_s)
    end

    def for_profile(profile)
      selection(profile).terms
    end

    def selection(profile)
      SELECTIONS.fetch(profile)
    end

    def validate!
      validate_uniqueness!
      validate_registry_size!
      validate_values!
    end

    def validate_uniqueness!
      raise 'Factur-X term identifiers must be unique' unless BY_ID.size == ALL.size
      raise 'Factur-X group identifiers must be unique' unless GROUPS_BY_ID.size == GROUPS.size
    end

    def validate_registry_size!
      raise 'Factur-X EN16931 registry must contain 184 terms' unless ALL.size == 184
      raise 'Factur-X EN16931 registry must contain 41 groups' unless GROUPS.size == 41
    end

    def validate_values!
      raise 'Factur-X term type is unknown' unless ALL.all? { |term| TYPES.include?(term.type) }
      raise 'Factur-X term scale is unknown' unless ALL.all? { |term| SCALES.include?(term.scale) }
      raise 'Factur-X cardinality is unknown' unless cardinalities_valid?
    end

    def cardinalities_valid?
      (ALL + GROUPS).all? do |entry|
        CARDINALITIES.include?(entry.cardinality)
      end
    end
    private_class_method :validate_uniqueness!, :validate_registry_size!, :validate_values!,
                         :cardinalities_valid?

    validate!
  end
end
