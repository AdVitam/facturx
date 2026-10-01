# frozen_string_literal: true

require 'eu_einvoice/france/addressing'

RSpec.describe EuEinvoice::France::Addressing do
  it 'builds an electronic address at the legal entity level' do
    address = described_class.build(siren: '200034528')

    expect(address.electronic_address).to eq(EuEinvoice::Identifier.new(value: '200034528', scheme_id: '0225'))
  end

  it 'derives the legal entity from a full establishment identifier' do
    address = described_class.build(siret: '20003452800014')

    expect(address.siren).to eq('200034528')
    expect(address.electronic_address.value).to eq('200034528_20003452800014')
  end

  it 'preserves a routing code independently of any Chorus service code' do
    address = described_class.build(siret: '20003452800014', routing_code: 'aB_01-AB/AB@1')

    expect(address.electronic_address.value).to eq('200034528_20003452800014_aB_01-AB/AB@1')
  end

  it 'supports a suffix without inventing an establishment' do
    address = described_class.build(siren: '200034528', suffix: 'aB_01-AB.AB@1')

    expect(address.siret).to be_nil
    expect(address.electronic_address.value).to eq('200034528_aB_01-AB.AB@1')
  end

  it 'accepts both Luhn-valid and exceptional La Poste establishments' do
    expect(described_class.build(siret: '35600000000048').siren).to eq('356000000')
    expect(described_class.build(siret: '35600000009075').siren).to eq('356000000')
  end

  it 'preserves leading zeroes and copies mutable inputs' do
    siren = +'005611074'
    address = described_class.build(siren:)
    siren.replace('000000000')

    expect(address.siren).to eq('005611074')
    expect(address.siren).to be_frozen
    expect(address).to be_frozen
  end

  it 'accepts the maximum length address' do
    address = described_class.build(siret: '20003452800014', routing_code: 'A' * 100)

    expect(address.electronic_address.value.bytesize).to eq(125)
  end

  {
    missing_identifier: {},
    inconsistent_identifiers: { siren: '356000000', siret: '20003452800014' },
    missing_establishment: { siren: '200034528', routing_code: 'A' },
    conflicting_addressing: { siret: '20003452800014', suffix: 'A' },
    invalid_checksum: { siren: '200034582' }
  }.each do |code, attributes|
    it "reports #{code} with structured details" do
      expect { described_class.build(**attributes) }.to raise_error(EuEinvoice::France::InvalidAddressError) do |error|
        expect(error.details[:code]).to eq(code)
        expect(error.details[:field]).to be_a(Symbol)
      end
    end
  end

  [
    { siren: '000000000' }, { siren: 200_034_528 }, { siren: "200034528\n" },
    { siret: '20003452800041' }, { siret: '35600000009076' },
    { siren: '200034528', suffix: '' }, { siren: '200034528', suffix: 'A/B' },
    { siren: '200034528', suffix: 'é' }, { siren: '200034528', suffix: 'A' * 101 },
    { siret: '20003452800014', routing_code: 'A.B' },
    { siret: '20003452800014', routing_code: 'A' * 101 },
    { siren: '200034528', suffix: 'A', routing_code: 'B' }
  ].each do |attributes|
    it "rejects invalid address components #{attributes.inspect}" do
      expect { described_class.build(**attributes) }.to raise_error(EuEinvoice::France::InvalidAddressError)
    end
  end

  it 'revalidates immutable updates instead of bypassing the constructor' do
    address = described_class.build(siren: '200034528')

    expect { address.with(siret: '35600000000048') }.to raise_error(EuEinvoice::France::InvalidAddressError)
  end
end
