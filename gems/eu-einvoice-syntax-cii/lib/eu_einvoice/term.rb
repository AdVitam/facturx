# frozen_string_literal: true

module EuEinvoice
  Term = Data.define(:definition, :xpath, :type) do
    def id = definition.id
    def model = definition.model
    def attribute = definition.attribute
    def group_id = definition.group_id
    def scale = definition.scale
    def cardinality = definition.cardinality
  end
end
