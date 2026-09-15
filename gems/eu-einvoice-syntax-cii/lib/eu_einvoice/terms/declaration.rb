# frozen_string_literal: true

require 'eu_einvoice/term'
require 'eu_einvoice/group'
require 'eu_einvoice/semantic/en16931'

module EuEinvoice
  module TermDeclarations
    module Declaration
      module_function

      def term(id, xpath, type)
        Term.new(Semantic::En16931.fetch(id), xpath, type)
      end

      def group(id, xpath)
        Group.new(Semantic::En16931.group(id), xpath)
      end
    end
  end
end
