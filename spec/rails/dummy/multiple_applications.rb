# frozen_string_literal: true

require 'rails'
require 'eu_einvoice/fr'
require 'eu_einvoice/rails'
require 'logger'
require 'tmpdir'

module InvoiceApplicationIsolation
  class First < ::Rails::Application; end
  class Second < ::Rails::Application; end

  module_function

  def configure(application, root)
    application.config.root = root
    application.config.eager_load = false
    application.config.secret_key_base = 'isolated-invoice-applications'
    application.config.logger = Logger.new(File::NULL)
    application.config.active_support.deprecation = :stderr
  end

  def boot(klass, root)
    # Rails freezes these process-wide arrays at boot; each empty app gets a fresh loader lifecycle.
    ActiveSupport::Dependencies.autoload_paths = []
    ActiveSupport::Dependencies.autoload_once_paths = []
    application = klass.new
    ::Rails.application = application
    configure(application, root)
    pack = EuEinvoice::France::Pack.new
    client = application.config.eu_einvoice.register(:default, packs: [pack], validation: :structural)
    application.initialize!
    raise 'Boot replaced a configured client' unless application.config.eu_einvoice[:default].equal?(client)
    raise 'Initializer client missing' unless application.config.eu_einvoice[:initializer].is_a?(EuEinvoice::Client)

    application
  end

  def run
    Dir.mktmpdir('eu-einvoice-applications-') do |root|
      directory = File.join(root, 'config/initializers')
      FileUtils.mkdir_p(directory)
      FileUtils.cp(File.join(__dir__, 'client_initializer.rb'), File.join(directory, 'eu_einvoice.rb'))
      first = boot(First, root)
      second = boot(Second, root)
      raise 'Applications share their registry' if first.config.eu_einvoice.equal?(second.config.eu_einvoice)

      first_client = first.config.eu_einvoice[:default]
      second_client = second.config.eu_einvoice[:default]
      second.reloader.reload!
      raise 'Reload changed another application client' unless first.config.eu_einvoice[:default].equal?(first_client)
      raise 'Reload replaced the application client' unless second.config.eu_einvoice[:default].equal?(second_client)
    end
  end
end

InvoiceApplicationIsolation.run
