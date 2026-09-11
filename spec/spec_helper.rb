# frozen_string_literal: true

require 'facturx'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.order = :random
end
