# frozen_string_literal: true

require_relative '../../tooling/gemspec'

GemSpecification.build('eu-einvoice-validation-fr', __dir__, 'Optional official Factur-X Schematron validation',
                       'eu-einvoice-fr' => EuEinvoice::VERSION) do |spec|
  spec.required_ruby_version = '>= 3.2'
end
