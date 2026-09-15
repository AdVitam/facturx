# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EuEinvoice::France::Adapter, :aggregate_failures do
  let(:pack) { EuEinvoice::France::Pack.new }
  let(:adapter) { pack.adapter(validation: :structural) }
  let(:xml) { File.binread('spec/fixtures/xml/minimum.xml') }
  let(:specification) { pack.specification(profile: :minimum) }
  let(:document) do
    parsed = adapter.read(xml).document
    parsed.with(seller: parsed.seller.with(address: EuEinvoice::Address.new(country_code: 'FR')))
  end

  it 'returns a structural report with precise coverage and provenance' do
    report = adapter.validate_xml(xml:)
    expect(report).to have_attributes(valid?: true, complete?: false, specification:)
    expect(report.steps).to include(xsd: :executed, schematron: :not_requested)
    expect(report.resources).to include(specification.resources)
    expect(report.resources.keys).to include(start_with('license/eu-einvoice-fr/'))
  end

  it 'reports malformed input without claiming later steps ran' do
    report = adapter.validate_xml(xml: '<broken')
    expect(report).to have_attributes(invalid?: true, complete?: false)
    expect(report.steps).to include(syntax: :executed, xsd: :blocked)
  end

  it 'reuses one parsed context for detection, reading and validation' do
    context = adapter.prepare(xml:)
    expect(adapter.detect(context:)).to eq([specification])
    expect(adapter.read(context:).source).to eq(xml)
    expect(adapter.validate_xml(context:)).to be_valid
  end

  it 'keeps unknown profiles unresolved while preserving semantic data and exact source' do
    unknown = xml.sub(specification.guideline_urn, 'urn:example:unknown')
    reading = adapter.read(unknown)
    expect(reading).to have_attributes(profile: nil, specification: nil, source: unknown)
    expect(reading.document.invoice_number).to eq('F-2023-001')
    expect(reading.diagnostics).to include(have_attributes(code: :unknown_profile))
  end

  it 'rejects an explicit specification conflicting with declared identifiers' do
    expect { adapter.read(xml, specification: pack.specification) }.to raise_error(EuEinvoice::UnknownProfileError)
  end

  it 'reports ambiguous versions without choosing the most recent' do
    revision = specification.with(version: 'synthetic-revision', fingerprint: nil)
    ambiguous = described_class.new(specifications: [specification, revision], validation: :structural)
    expect { ambiguous.read(xml) }.to raise_error(EuEinvoice::AmbiguousSpecificationError)
    expect(ambiguous.read(xml, specification: revision).specification).to eq(revision)
  end

  it 'builds a single validated compilation with document coverage' do
    compilation = adapter.compile(document:, specification:)
    expect(compilation.report).to have_attributes(valid?: true, complete?: false)
    expect(compilation.report.executed_steps).to include(:document, :xsd)
    expect(adapter.read(compilation.xml).document).to eq(document)
  end

  it 'rejects a different semantic model without changing the document version' do
    different = document.with(semantic_version: '2026')
    report = adapter.validate_document(document: different, specification:)
    expect(report.issues).to include(have_attributes(code: :semantic_version_mismatch))
    expect(different.semantic_version).to eq('2026')
  end
end
