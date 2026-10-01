# frozen_string_literal: true

require_relative '../../tooling/gemspec'

GemSpecification.build('eu-einvoice-rails', __dir__, 'Explicit Rails integration for European invoicing',
                       'eu-einvoice' => EuEinvoice::VERSION,
                       'railties' => ['>= 7.2', '< 9'], 'activemodel' => ['>= 7.2', '< 9'],
                       'activesupport' => ['>= 7.2', '< 9'], 'json' => ['>= 2.7', '< 3']) do |spec|
  spec.required_ruby_version = '>= 3.2'
end
