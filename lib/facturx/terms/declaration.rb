# frozen_string_literal: true

require_relative '../term'
require_relative '../group'

module Facturx
  module TermDeclarations
    module Declaration
      module_function

      def term(*attributes, **cardinalities)
        Term.new(*attributes, cardinalities.freeze).freeze
      end

      def group(*attributes, **cardinalities)
        Group.new(*attributes, cardinalities.freeze).freeze
      end
    end
  end
end
