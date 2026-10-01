# frozen_string_literal: true

require 'eu_einvoice'
require_relative 'addressing_rules'

module EuEinvoice
  module France
    class InvalidAddressError < Error; end

    FrenchAddress = Data.define(:siren, :siret, :suffix, :routing_code) do
      include Model::ValidatedWith

      def initialize(siren: nil, siret: nil, suffix: nil, routing_code: nil)
        super(**AddressingRules.call(siren:, siret:, suffix:, routing_code:))
      end

      def electronic_address
        Identifier.new(value: [siren, siret, routing_code, suffix].compact.join('_'), scheme_id: '0225')
      end
    end

    module Addressing
      class << self
        def build(siren: nil, siret: nil, suffix: nil, routing_code: nil)
          FrenchAddress.new(siren:, siret:, suffix:, routing_code:)
        end
      end
    end
  end
end
