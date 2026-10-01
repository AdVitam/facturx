# frozen_string_literal: true

require_relative '../../tooling/gemspec'

GemSpecification.build('eu-einvoice-fr', __dir__, 'French Factur-X specifications and addressing',
                       'eu-einvoice' => EuEinvoice::VERSION,
                       'eu-einvoice-syntax-cii' => EuEinvoice::VERSION,
                       'eu-einvoice-container-pdf' => EuEinvoice::VERSION) do |spec|
  spec.required_ruby_version = '>= 3.2'
end
