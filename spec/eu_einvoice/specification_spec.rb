# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EuEinvoice::Specification, :aggregate_failures do
  let(:pack) { EuEinvoice::France::Pack.new }
  let(:specification) { pack.specification }

  it 'distinguishes semantic, syntax, release and package versions' do
    expect(specification).to have_attributes(version: '1.09.2', semantic_version: '2017', syntax: :cii)
    expect(specification.manifest).to include(syntax_version: 'D22B', artifact_version: '1.09.2')
  end

  it 'deeply freezes metadata and stable resource fingerprints' do
    expect(specification.resources).to be_frozen
    expect(specification.fingerprint).to eq(EuEinvoice::France::Pack.new.specification.fingerprint)
    expect { specification.manifest[:code_lists].clear }.to raise_error(FrozenError)
  end

  it 'changes fingerprint when resources or the declared version change' do
    revised = specification.with(version: 'synthetic-version', fingerprint: nil)
    expect(revised.fingerprint).not_to eq(specification.fingerprint)
  end

  it 'keeps fingerprints stable when manifest key insertion order changes' do
    reordered = specification.with(manifest: specification.manifest.to_a.reverse.to_h)
    expect(reordered.fingerprint).to eq(specification.fingerprint)
  end

  it 'keeps semantic definitions independent from CII lexical rules and profile restrictions' do
    semantic = EuEinvoice::Semantic::En16931.fetch('BT-2')
    binding = EuEinvoice::Terms.fetch('BT-2')
    expect(semantic.type).to eq(:date)
    expect(semantic).not_to respond_to(:xpath, :cardinalities)
    expect(binding).to have_attributes(definition: semantic, type: :date_102)
  end

  it 'keeps the complete dependency resource sets in the manifest' do
    expect(specification.resources.size).to eq(4)
    expect(specification.manifest.fetch(:optional_resources).size).to eq(2)
    expect(specification.manifest.fetch(:code_lists).keys).to all(end_with('_codedb.xml'))
  end
end
