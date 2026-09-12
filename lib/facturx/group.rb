# frozen_string_literal: true

module Facturx
  Group = Data.define(:id, :model, :attribute, :parent_id, :xpath, :cardinalities)
end
