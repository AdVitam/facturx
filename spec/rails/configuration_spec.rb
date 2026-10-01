# frozen_string_literal: true

require 'eu_einvoice/fr'
require 'eu_einvoice/rails'

RSpec.describe EuEinvoice::Rails::Configuration do
  let(:configuration) { described_class.new }
  let(:pack) { EuEinvoice::France::Pack.new }

  it 'builds immutable named clients once and retrieves the same instance' do
    client = configuration.register(:default, packs: [pack], policy: pack.policy, validation: :structural)
    configuration.seal!

    expect(configuration[:default]).to equal(client)
    expect(configuration['default']).to equal(client)
    expect(client).to be_frozen
    expect(configuration).to be_frozen
  end

  it 'rejects duplicate names instead of silently changing an existing client' do
    configuration.register(:default, packs: [pack], validation: :structural)

    expect { configuration.register('default', packs: [pack], validation: :structural) }
      .to raise_error(EuEinvoice::Error)
  end

  it 'prevents registrations after boot' do
    configuration.seal!

    expect { configuration.register(:late, packs: [pack], validation: :structural) }.to raise_error(FrozenError)
  end

  it 'surfaces missing client names' do
    expect { configuration[:unknown] }.to raise_error(KeyError)
  end
end
