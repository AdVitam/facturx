# frozen_string_literal: true

require_relative '../../tooling/gemspec'

GemSpecification.build('eu-einvoice-syntax-cii', __dir__, 'CII invoice reading, writing and schema validation',
                       'eu-einvoice' => EuEinvoice::VERSION, 'nokogiri' => '>= 1.13') do |spec|
  spec.required_ruby_version = '>= 3.2'
end
