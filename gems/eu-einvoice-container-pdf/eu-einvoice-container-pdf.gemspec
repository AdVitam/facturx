# frozen_string_literal: true

require_relative '../../tooling/gemspec'

GemSpecification.build('eu-einvoice-container-pdf', __dir__, 'Bounded hybrid PDF invoice composition and extraction',
                       'eu-einvoice' => EuEinvoice::VERSION, 'pdf-reader' => ['>= 2.16', '< 3'],
                       'nokogiri' => '>= 1.13') do |spec|
  spec.required_ruby_version = '>= 3.2'
end
