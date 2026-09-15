# frozen_string_literal: true

require 'rspec/core/rake_task'
require_relative 'gems/eu-einvoice/lib/eu_einvoice/version'

RSpec::Core::RakeTask.new(:spec)
desc 'Build every package from the shared release version'
task :build_all do
  FileUtils.mkdir_p('pkg')
  Dir.glob('gems/*/*.gemspec').each do |specification|
    name = File.basename(specification, '.gemspec')
    output = File.expand_path("pkg/#{name}-#{EuEinvoice::VERSION}.gem")
    Dir.chdir(File.dirname(specification)) do
      sh Gem.ruby, '-S', 'gem', 'build', File.basename(specification), '--output', output
    end
  end
end

task default: :spec
