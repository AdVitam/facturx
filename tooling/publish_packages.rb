# frozen_string_literal: true

require_relative '../gems/eu-einvoice/lib/eu_einvoice/version'

names = %w[eu-einvoice eu-einvoice-syntax-cii eu-einvoice-container-pdf eu-einvoice-fr eu-einvoice-validation-fr
           eu-einvoice-rails]
names.each do |name|
  path = File.expand_path("../pkg/#{name}-#{EuEinvoice::VERSION}.gem", __dir__)
  system(Gem.ruby, '-S', 'gem', 'push', path, exception: true)
end
