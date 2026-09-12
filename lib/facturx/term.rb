# frozen_string_literal: true

module Facturx
  Term = Data.define(:id, :model, :attribute, :group_id, :xpath, :type, :scale, :cardinalities)
end
