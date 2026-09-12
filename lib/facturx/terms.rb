# frozen_string_literal: true

require 'nokogiri'
require_relative 'term'
require_relative 'group'
require_relative 'terms/declaration'
require_relative 'terms/reference'
require_relative 'terms/declarations/document'
require_relative 'terms/declarations/parties'
require_relative 'terms/declarations/references'
require_relative 'terms/declarations/delivery'
require_relative 'terms/declarations/payment'
require_relative 'terms/declarations/taxes'
require_relative 'terms/declarations/adjustments'
require_relative 'terms/declarations/totals'
require_relative 'terms/declarations/lines'
require_relative 'terms/declarations/products'
require_relative 'terms/declarations/groups'

module Facturx
  module Terms
    PROFILE_TERM_COUNTS = { minimum: 22, basic_wl: 113, basic: 140, en16931: 184, extended: 184 }.freeze
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

    def for_profile(profile)
      profile_id = profile.respond_to?(:id) ? profile.id : profile.to_sym
      ALL.select { |term| term.cardinalities.key?(profile_id) }.freeze
    end

    def groups_for_profile(profile)
      profile_id = profile.respond_to?(:id) ? profile.id : profile.to_sym
      GROUPS.select { |group| group.cardinalities.key?(profile_id) }.freeze
    end

    def validate!
      validate_uniqueness!
      validate_registry_size!
      validate_values!
      validate_profile_counts!
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

    def validate_profile_counts!
      PROFILE_TERM_COUNTS.each do |profile_id, count|
        raise "Factur-X #{profile_id} registry must contain #{count} terms" unless for_profile(profile_id).size == count
      end
    end

    def cardinalities_valid?
      (ALL + GROUPS).all? do |entry|
        entry.cardinalities.values.all? { |cardinality| CARDINALITIES.include?(cardinality) }
      end
    end
    private_class_method :validate_uniqueness!, :validate_registry_size!, :validate_values!, :validate_profile_counts!,
                         :cardinalities_valid?

    validate!
  end
end
