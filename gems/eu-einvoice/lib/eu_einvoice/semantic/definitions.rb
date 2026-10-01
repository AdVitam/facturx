# frozen_string_literal: true

module EuEinvoice
  TermDefinition = Data.define(:id, :model, :attribute, :group_id, :type, :scale, :cardinality)
  GroupDefinition = Data.define(:id, :model, :attribute, :parent_id, :cardinality)
end
