# frozen_string_literal: true

require 'eu_einvoice/schematron'

module EuEinvoice
  module Validation
    module France
      class << self
        def validator(specification: nil, limits: ResourceLimits.new, root: Schematron::Registry::ROOT)
          registry = Schematron::Registry.new(specification:, root:)
          Schematron::Validator.new(registry:, limits:).tap(&:preflight!)
        end

        def validators(specifications:, limits:, root: Schematron::Registry::ROOT)
          runner = Schematron::Runner.new(limits:)
          locator = Schematron::Locator.new(runner:)
          locator.preflight!
          specifications.to_h do |specification|
            registry = Schematron::Registry.new(specification:, root:)
            [specification.fingerprint, Schematron::Validator.new(registry:, runner:, locator:, limits:)]
          end.freeze
        end
      end
    end
  end
end
