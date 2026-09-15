# frozen_string_literal: true

require 'spec_helper'
require_relative 'writer/support/document_factory'

RSpec.describe EuEinvoice::RecipientRequirements do
  let(:pack) { EuEinvoice::France::Pack.new }
  let(:client) { EuEinvoice::Client.new(packs: [pack], validation: :structural) }
  let(:specification) { pack.specification }
  let(:document) { WriterDocumentFactory.conforming_fixture_document(:en16931) }

  it 'selects a single declared accepted specification without a country policy or customer classification' do
    requirements = described_class.new(specification_ids: [specification.id])
    resolution = client.resolve(document:, requirements:)
    expect(resolution).to be_resolved
    expect(client.build_xml(document:, resolution:).report).to be_valid
  end

  it 'does not silently override an incompatible explicit specification' do
    requirements = described_class.new(syntaxes: [:ubl])
    resolution = client.resolve(document:, specification:, requirements:)
    expect(resolution.status).to eq(:unsupported)
    expect { client.build_xml(document:, resolution:) }.to raise_error(EuEinvoice::ResolutionError)
  end

  it 'retains ambiguity if accepted syntax covers multiple profiles' do
    resolution = client.resolve(document: document.with(guideline_urn: nil),
                                requirements: described_class.new(syntaxes: [:cii]))
    expect(resolution.status).to eq(:ambiguous)
  end

  it 'does not downgrade a configured policy when recipient requirements conflict' do
    configured = EuEinvoice::Client.new(packs: [pack], policy: pack.policy, validation: :structural)
    minimum = pack.specification(profile: :minimum)
    requirements = described_class.new(specification_ids: [minimum.id])
    unspecified = document.with(guideline_urn: nil)

    expect(configured.resolve(document: unspecified, requirements:).status).to eq(:unsupported)
    overridden = configured.resolve(document: unspecified, specification: minimum, requirements:)
    expect(overridden).to be_resolved
    expect(overridden.specification).to eq(minimum)
  end

  it 'reports missing recipient references and incompatible electronic addresses' do
    requirements = described_class.new(required_references: [:buyer_reference], electronic_address_schemes: ['0225'])
    resolution = client.resolve(document: document.with(buyer_reference: nil), specification:, requirements:)
    expect(resolution.status).to eq(:missing_information)
    expect(resolution.diagnostics.map(&:path)).to contain_exactly('buyer_reference', 'electronic_address')
  end

  it 'accepts declared references and address schemes while retaining immutable provenance' do
    provenance = EuEinvoice::RequirementProvenance.new(source: 'customer onboarding',
                                                       observed_at: Time.utc(
                                                         2026, 9, 15
                                                       ))
    requirements = described_class.new(required_references: [:buyer_reference], electronic_address_schemes: ['0225'],
                                       provenance:)
    buyer = document.buyer.with(electronic_address: EuEinvoice::Identifier.new(value: '123456789', scheme_id: '0225'))
    resolution = client.resolve(document: document.with(buyer:, buyer_reference: 'department-12'),
                                specification:, requirements:)
    expect(resolution).to be_resolved
    expect(resolution.requirements.provenance).to eq(provenance)
    expect(resolution.requirements.electronic_address_schemes).to be_frozen
    expect(resolution.diagnostics).to be_empty
  end

  it 'rejects unknown reference fields and incorrectly typed declarations' do
    expect { described_class.new(required_references: [:send_mail]) }.to raise_error(ArgumentError)
    expect { described_class.new(specification_ids: 'not-a-list') }.to raise_error(ArgumentError)
    expect { described_class.new(provenance: {}) }.to raise_error(TypeError)
  end
end
