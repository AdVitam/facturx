# frozen_string_literal: true

require 'eu_einvoice/document'
require 'eu_einvoice/builders/schema'
require 'eu_einvoice/builders/base'

module EuEinvoice
  module Builders
    BUILDERS = Schema::ASSOCIATIONS.to_h do |model, associations|
      name = :"#{model.name.delete_prefix('EuEinvoice::')}Builder"
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
