# frozen_string_literal: true

module EuEinvoice
  RequirementProvenance = Model.define(:source, :observed_at, :version)

  RecipientRequirements = Data.define(:specification_ids, :syntaxes, :electronic_address_schemes,
                                      :required_references, :provenance) do
    def initialize(specification_ids: [], syntaxes: [], electronic_address_schemes: [], required_references: [],
                   provenance: nil)
      validate_lists!(specification_ids, syntaxes, electronic_address_schemes, required_references)
      unless provenance.nil? || provenance.is_a?(RequirementProvenance)
        raise TypeError, 'provenance must be a RequirementProvenance'
      end

      super(**Model.copy_and_freeze({ specification_ids:, syntaxes:, electronic_address_schemes:,
                                      required_references:, provenance: }))
    end

    def accepts?(specification)
      (specification_ids.empty? || specification_ids.include?(specification.id)) &&
        (syntaxes.empty? || syntaxes.include?(specification.syntax))
    end

    def constrains_format? = !specification_ids.empty? || !syntaxes.empty?

    def diagnostics(document)
      missing = required_references.filter_map do |reference|
        value = document.public_send(reference)
        value = value.id if value.is_a?(DocumentReference)
        missing_field(reference) if value.nil? || value.to_s.empty?
      end
      missing << missing_field(:electronic_address) unless address_matches?(document.buyer&.electronic_address)
      missing.freeze
    end

    private

    def validate_lists!(ids, syntaxes, schemes, references)
      valid = typed_list?(ids, String) && typed_list?(syntaxes, Symbol) && typed_list?(schemes, String) &&
              typed_list?(references, Symbol) &&
              (references - %i[buyer_reference purchase_order_reference contract_reference]).empty?
      raise ArgumentError, 'Invalid recipient requirement list' unless valid
    end

    def typed_list?(values, type)
      values.is_a?(Array) && values.all? { |value| value.is_a?(type) && !value.to_s.empty? }
    end

    def address_matches?(address)
      electronic_address_schemes.empty? ||
        (address && !address.value.to_s.empty? && electronic_address_schemes.include?(address.scheme_id))
    end

    def missing_field(field)
      Diagnostic.new(code: :recipient_requirement_missing, path: field.to_s,
                     message: 'A declared recipient requirement is not satisfied')
    end
  end
end
