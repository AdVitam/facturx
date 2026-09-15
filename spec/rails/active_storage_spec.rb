# frozen_string_literal: true

require 'eu_einvoice/rails'

RSpec.describe EuEinvoice::Rails::ActiveStorage do
  let(:artifact) do
    EuEinvoice::Artifact.new(bytes: '%PDF-test'.b, content_type: 'application/pdf', filename: 'invoice.pdf')
  end

  it 'prepares an attachment with an independent stream on each call' do
    first = described_class.attachable(artifact)
    second = described_class.attachable(artifact)

    expect(first.except(:io)).to eq(filename: 'invoice.pdf', content_type: 'application/pdf', identify: false)
    expect(first[:io].read).to eq(artifact.bytes)
    expect(second[:io].pos).to eq(0)
    expect(second[:io].read).to eq(artifact.bytes)
  end
end
