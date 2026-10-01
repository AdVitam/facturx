# frozen_string_literal: true

require 'eu_einvoice/model/immutable'

module EuEinvoice
  Profile = Data.define(:id, :guideline_urn, :conformance_level, :constraints) do
    def initialize(id:, guideline_urn:, conformance_level:, constraints: {})
      super(id:, guideline_urn: Model.copy_and_freeze(guideline_urn),
            conformance_level: Model.copy_and_freeze(conformance_level),
            constraints: Model.copy_and_freeze(constraints))
    end

    def cardinality(definition)
      constraints[definition.id]
    end
  end
end
