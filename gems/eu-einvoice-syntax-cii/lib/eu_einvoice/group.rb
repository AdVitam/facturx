# frozen_string_literal: true

module EuEinvoice
  Group = Data.define(:definition, :xpath) do
    def id = definition.id
    def model = definition.model
    def attribute = definition.attribute
    def parent_id = definition.parent_id
    def cardinality = definition.cardinality
  end
end
