# frozen_string_literal: true

require_relative '../../tooling/gemspec'

GemSpecification.build('eu-einvoice', __dir__, 'Immutable European invoice models and explicit document orchestration',
                       'bigdecimal' => '>= 3.1', 'date' => '>= 3.2') do |spec|
  spec.required_ruby_version = '>= 3.2'
end
