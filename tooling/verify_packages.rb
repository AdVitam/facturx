# frozen_string_literal: true

require 'bundler'
require 'tmpdir'
require 'open3'
require_relative '../gems/eu-einvoice/lib/eu_einvoice/version'

module PackageSmoke
  NAMES = %w[eu-einvoice eu-einvoice-syntax-cii eu-einvoice-container-pdf eu-einvoice-fr
             eu-einvoice-validation-fr eu-einvoice-rails].freeze

  module_function

  def run
    Bundler.with_unbundled_env do
      Dir.mktmpdir('eu-einvoice-install-') do |directory|
        install(directory)
        verify(environment(directory), directory)
      end
    end
  end

  def install(directory)
    NAMES.each do |name|
      path = File.expand_path("../pkg/#{name}-#{EuEinvoice::VERSION}.gem", __dir__)
      system(Gem.ruby, '-S', 'gem', 'install', path, '--no-document', '--ignore-dependencies',
             '--install-dir', directory, exception: true)
    end
  end

  def environment(directory)
    gemfile = File.join(directory, 'Gemfile')
    dependencies = NAMES.map { |name| "gem '#{name}', '#{EuEinvoice::VERSION}'" }
    File.write(gemfile, ["source 'https://rubygems.org'", *dependencies].join("\n"))
    env = { 'GEM_PATH' => [directory, *Gem.path].join(File::PATH_SEPARATOR), 'GEM_HOME' => directory,
            'BUNDLE_GEMFILE' => gemfile }
    system(env, Gem.ruby, '-S', 'bundle', 'lock', '--local', chdir: directory, exception: true)
    env
  end

  def verify(env, directory)
    fixture = File.expand_path('../spec/validation_fr/fixtures/xml/en16931.xml', __dir__)
    command = [Gem.ruby, '-rbundler/setup', '-e', SCRIPT, directory, fixture]
    _stdout, stderr, status = Open3.capture3(env, *command, chdir: directory)
    abort stderr unless status.success?
  end

  SCRIPT = <<~'RUBY'
    require 'eu_einvoice'
    abort 'Core loaded an adapter' if defined?(Nokogiri) || defined?(PDF) || defined?(Rails) || defined?(EuEinvoice::France)
    require 'eu_einvoice/fr'
    client = EuEinvoice::Client.new(packs: [EuEinvoice::France::Pack.new], validation: :structural)
    abort unless client.specifications.size == 5
    reading = client.read(File.binread(ARGV.fetch(1)))
    abort unless reading.diagnostics.empty?
    artifact = client.build_xml(document: reading.document, specification: reading.specification)
    abort unless client.validate_xml(xml: artifact).valid?
    require 'eu_einvoice/validation/fr'
    abort unless client.validation == :structural
    require 'eu_einvoice/rails'
    abort unless EuEinvoice::Rails::Configuration
    names = Gem.loaded_specs.keys.grep(/\Aeu-einvoice/)
    abort 'Missing installed package' unless names.size == 6
    names.each do |name|
      path = Gem.loaded_specs.fetch(name).full_gem_path
      abort 'Loaded source checkout instead of installed gem' unless path.start_with?(ARGV.fetch(0))
    end
  RUBY
end

PackageSmoke.run if $PROGRAM_NAME == __FILE__
