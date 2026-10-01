# frozen_string_literal: true

require 'eu_einvoice/pdf/embedding'

RSpec.describe EuEinvoice::Pdf::Embedding do
  it 'rejects filenames that escape the private staging directory' do
    expect { described_class.new(**attributes, filename: '../invoice.xml') }.to raise_error(ArgumentError)
  end

  it 'freezes owned configuration without freezing caller strings' do
    filename = +'invoice.xml'
    embedding = described_class.new(**attributes, filename:)
    filename.replace('changed.xml')

    expect(embedding.filename).to eq('invoice.xml').and be_frozen
  end

  def attributes
    { filename: 'invoice.xml', relationship: :Data, document_type: 'INVOICE', version: '1', xmp_namespace: 'urn:test' }
  end
end
