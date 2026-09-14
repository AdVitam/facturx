# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require_relative 'lib/facturx/version'

RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:schematron_spec) do |task|
  task.pattern = 'facturx-schematron/spec/**/*_spec.rb'
  task.exclude_pattern = 'facturx-schematron/spec/facturx/schematron_integration_spec.rb'
end

namespace :schematron do
  desc 'Build the facturx-schematron companion gem'
  task :build do
    output = File.expand_path("pkg/facturx-schematron-#{Facturx::VERSION}.gem", __dir__)
    FileUtils.mkdir_p(File.dirname(output))
    Dir.chdir(File.expand_path('facturx-schematron', __dir__)) do
      sh Gem.ruby, '-S', 'gem', 'build', 'facturx-schematron.gemspec', '--output', output
    end
  end
end

desc 'Build the core and companion gems'
task build_all: [:build, 'schematron:build']

task default: %i[spec schematron_spec]
