# frozen_string_literal: true

require 'eu_einvoice/semantic/definitions'

module EuEinvoice
  module Semantic
    module En16931
      VERSION = '2017'
      require 'eu_einvoice/semantic/en16931/terms'
      require 'eu_einvoice/semantic/en16931/groups'

      BY_ID = TERMS.to_h { |term| [term.id, term] }.freeze
      GROUPS_BY_ID = GROUPS.to_h { |group| [group.id, group] }.freeze

      class << self
        def fetch(id) = BY_ID.fetch(id)
        def group(id) = GROUPS_BY_ID.fetch(id)
      end
    end
  end
end
