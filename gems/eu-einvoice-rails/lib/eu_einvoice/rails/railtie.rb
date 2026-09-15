# frozen_string_literal: true

require 'rails'
require 'eu_einvoice/rails/application_configuration'

module EuEinvoice
  module Rails
    class Railtie < ::Rails::Railtie
      # Custom railtie options are process-wide; this accessor stores clients on each application configuration.
      ::Rails::Application::Configuration.include(ApplicationConfiguration)

      initializer 'eu_einvoice.locales', before: 'i18n.initialize' do |app|
        app.config.i18n.load_path.concat(Dir[File.expand_path('locales/*.yml', __dir__)])
      end

      initializer 'eu_einvoice.clients', after: :load_config_initializers do |app|
        app.config.eu_einvoice.seal!
      end
    end
  end
end
