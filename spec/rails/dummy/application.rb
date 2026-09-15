# frozen_string_literal: true

require 'tmpdir'
require 'logger'
require 'rails'
require 'active_record/railtie'
require 'active_storage/engine'
require 'eu_einvoice/rails'

module EuEinvoiceTestApplication
  class Application < ::Rails::Application
    config.root = __dir__
    config.eager_load = false
    config.enable_reloading = true
    config.secret_key_base = 'eu-einvoice-isolated-test-application-secret'
    config.logger = Logger.new(File::NULL)
    config.active_support.deprecation = :stderr
    config.active_storage.service = :local
    config.active_storage.service_configurations = {
      local: { service: 'Disk', root: Dir.mktmpdir('eu-einvoice-storage-') }
    }
  end
end
