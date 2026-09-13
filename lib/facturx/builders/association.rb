# frozen_string_literal: true

module Facturx
  module Builders
    Association = Data.define(:model, :collection, :helper)
    private_constant :Association
  end
end
