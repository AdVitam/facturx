# frozen_string_literal: true

require_relative 'document'
require_relative 'builders/schema'
require_relative 'builders/base'

module Facturx
  module Builders
    BUILDERS = Schema::ASSOCIATIONS.to_h do |model, associations|
      name = :"#{model.name.delete_prefix('Facturx::')}Builder"
      [model, const_set(name, Class.new(Base).configure(model, associations))]
    end.freeze
    private_constant :BUILDERS

    module_function

    def for(model)
      BUILDERS.fetch(model)
    end
  end

  Document.define_singleton_method(:build) do |**attributes, &block|
    Builders::DocumentBuilder.build(**attributes, &block)
  end
end
