# frozen_string_literal: true

source 'https://rubygems.org'

Dir.glob('gems/*/*.gemspec').each do |specification|
  name = File.basename(specification, '.gemspec')
  gem name, path: File.dirname(specification), require: false
end

group :development, :test do
  gem 'activestorage', ENV.fetch('RAILS_VERSION', '~> 8.1.0')
  gem 'railties', ENV.fetch('RAILS_VERSION', '~> 8.1.0')
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubyzip', '~> 3.6'
  gem 'sqlite3', '>= 1.7'
end
