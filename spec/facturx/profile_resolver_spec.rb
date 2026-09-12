# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Facturx::ProfileResolver do
  subject(:resolver) { described_class.new }

  let(:profile) { Facturx::Profiles.fetch(:en16931) }

  it 'resolves a built-in profile identifier' do
    expect(resolver.call(:en16931)).to equal(profile)
  end

  it 'accepts a canonical profile object' do
    expect(resolver.call(profile)).to equal(profile)
  end

  it 'rejects a modified profile' do
    expect { resolver.call(profile.with(guideline_urn: 'urn:example:custom')) }
      .to raise_error(Facturx::UnsupportedProfileError)
  end

  it 'rejects a non-canonical profile copy' do
    expect { resolver.call(Facturx::Profile.new(**profile.to_h)) }
      .to raise_error(Facturx::UnsupportedProfileError)
  end

  it 'rejects an unknown profile' do
    expect { resolver.call(:unknown) }.to raise_error(Facturx::UnsupportedProfileError)
  end

  it 'rejects other profile representations' do
    expect { resolver.call('en16931') }.to raise_error(Facturx::UnsupportedProfileError)
  end
end
