# frozen_string_literal: true

require 'eu_einvoice/fr'
require_relative 'support/cii'

RSpec.configure do |config|
  config.include CiiSupport
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.order = :random
end
