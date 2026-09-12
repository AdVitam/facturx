# frozen_string_literal: true

require_relative 'lib/facturx/version'

Gem::Specification.new do |spec|
  spec.name = 'facturx'
  spec.version = Facturx::VERSION
  spec.authors = ['AdVitam']
  spec.email = ['tech@advitam.fr']
  spec.summary = 'Read, validate, compose, and extract Factur-X invoices'
  spec.description = 'Ruby toolkit for reading and validating Factur-X XML ' \
                     'and composing or extracting PDF/A-3 invoices.'
  spec.homepage = 'https://github.com/AdVitam/facturx'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri' => 'https://github.com/AdVitam/facturx/issues',
    'changelog_uri' => 'https://github.com/AdVitam/facturx/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/AdVitam/facturx#readme',
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/AdVitam/facturx'
  }

  spec.files = Dir.chdir(__dir__) do
    Dir['lib/**/*'].select { |path| File.file?(path) } +
      %w[CHANGELOG.md LICENSE.txt NOTICE.md README.md]
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '>= 1.13'
  spec.add_dependency 'pdf-reader', '>= 2.16', '< 3'
end
