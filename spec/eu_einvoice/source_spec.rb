# frozen_string_literal: true

require 'stringio'
require 'eu_einvoice/source'

RSpec.describe EuEinvoice::Source, :aggregate_failures do
  it 'reads the current IO position and leaves ownership with its caller' do
    source = StringIO.new('prefixinvoice')
    source.pos = 6

    expect(described_class.read(source, limit: 7)).to eq('invoice')
    expect(source).not_to be_closed
    expect(source.pos).to eq(13)
  end

  it 'accepts exactly the byte limit and rejects an extra byte' do
    expect(described_class.read(StringIO.new('abc'), limit: 3)).to eq('abc')
    expect { described_class.read(StringIO.new('abcd'), limit: 3) }.to raise_error(EuEinvoice::ResourceLimitError)
  end

  it 'returns an immutable copy without freezing the caller string' do
    source = +'invoice'
    result = described_class.read(source, limit: 7)
    source.replace('changed')

    expect(result).to eq('invoice')
    expect(result).to be_frozen
  end
end
