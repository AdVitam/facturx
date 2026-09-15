# frozen_string_literal: true

require_relative 'reference_verifier'

namespace :reference do
  desc 'Verify mappings and examples against the official Factur-X package'
  task :verify do
    root = ENV.fetch('FACTURX_REFERENCE_ROOT') do
      raise 'FACTURX_REFERENCE_ROOT must point to the extracted Factur-X 1.09.2 / ZUGFeRD 2.5.2 package'
    end
    EuEinvoice::ReferenceVerifier.new(root:).call
  end
end
