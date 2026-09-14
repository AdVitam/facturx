# frozen_string_literal: true

require 'facturx'
require_relative 'schematron/error'
require_relative 'schematron/locator'
require_relative 'schematron/registry'
require_relative 'schematron/svrl_parser'
require_relative 'schematron/validator'

module Facturx
  SchematronAdapter.install(Schematron::Validator.new.tap(&:preflight!))

  module Schematron
    private_constant :InvalidOutputError, :Locator, :Registry, :RulePackError, :SvrlParser, :Validator, :VersionProbe
  end
end
