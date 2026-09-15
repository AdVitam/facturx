# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EuEinvoice::France::Licensing do
  it 'pins the license and notice bytes of each deployed resource package' do
    expect do
      described_class::CHECKSUMS.each_key do |package|
        described_class.verify!(package:, root: File.expand_path("gems/#{package}"))
      end
    end.not_to raise_error
  end

  it 'identifies all license and notice resources in every specification manifest' do
    manifest = EuEinvoice::France::Pack.new.specification.manifest
    expect(manifest.fetch(:licensing).values.flat_map(&:keys))
      .to include('LICENSE.txt', 'NOTICE.md', 'lib/eu_einvoice/schema/NOTICE.md')
  end
end
