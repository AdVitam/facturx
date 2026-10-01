# frozen_string_literal: true

require_relative '../gems/eu-einvoice/lib/eu_einvoice/version'

module GemSpecification
  module_function

  def build(name, root, summary, dependencies = {})
    Gem::Specification.new do |spec|
      describe(spec, name, summary)
      package(spec, root)
      dependencies.each { |dependency, requirement| spec.add_dependency(dependency, *Array(requirement)) }
      yield spec
    end
  end

  def describe(spec, name, summary)
    spec.name = name
    spec.version = EuEinvoice::VERSION
    spec.authors = ['AdVitam']
    spec.email = ['tech@advitam.fr']
    spec.summary = summary
    spec.description = "#{summary}. Part of the modular EuEinvoice toolkit, " \
                       'with in-memory invoice objects and explicit versioned specifications.'
  end

  def package(spec, root)
    spec.homepage = 'https://github.com/AdVitam/facturx'
    spec.license = 'MIT'
    spec.metadata = metadata
    spec.files = Dir.glob(['{lib,rbi}/**/*', '*.md', 'LICENSE.txt'], base: root)
                    .select { |path| File.file?(File.join(root, path)) }
    spec.require_paths = ['lib']
  end

  def metadata
    {
      'allowed_push_host' => 'https://rubygems.org',
      'source_code_uri' => 'https://github.com/AdVitam/facturx',
      'documentation_uri' => 'https://github.com/AdVitam/facturx#readme',
      'changelog_uri' => 'https://github.com/AdVitam/facturx/blob/master/CHANGELOG.md',
      'rubygems_mfa_required' => 'true'
    }
  end
end
