# frozen_string_literal: true

require 'spec_helper'
require_relative 'pdf/support/pdf_builder'
require_relative 'eu_einvoice/writer/support/document_factory'

RSpec.describe EuEinvoice::Client do
  include PdfSupport

  let(:pack) { EuEinvoice::France::Pack.new }
  let(:client) { described_class.new(packs: [pack], validation: :structural) }
  let(:specification) { pack.specifications.find { |item| item.profile.id == :en16931 } }
  let(:xml) { File.binread('spec/fixtures/xml/en16931.xml') }
  let(:document) { WriterDocumentFactory.conforming_fixture_document(:en16931) }

  it 'loads the central facade without legacy static entry points' do
    expect(EuEinvoice).not_to respond_to(:generate)
    expect(Object.const_defined?(:Facturx)).to be(false)
  end

  it 'reads typed invoices and retains exact source bytes' do
    reading = client.read(StringIO.new(xml))
    expect(reading.source).to eq(xml.b)
    expect(reading.document.invoice_number).to eq('F-2023-004')
    expect(reading.specification).to eq(specification)
  end

  it 'returns an artifact with structural coverage without claiming full validation' do
    artifact = client.build_xml(document:, specification:)
    expect(artifact).to be_a(EuEinvoice::Artifact)
    expect(artifact.report).to be_valid
    expect(artifact.report).not_to be_complete
    expect(client.validate_xml(xml: artifact)).to be_valid
  end

  it 'resolves a configured country pair without a buyer classification' do
    policy = EuEinvoice::Policy.new(preferences: { %w[FR FR] => specification.id })
    configured = described_class.new(packs: [pack], policy:, validation: :structural)
    resolution = configured.resolve(document:)
    expect(resolution).to be_resolved
    expect(configured.build_xml(document:, resolution:).report).to be_valid
  end

  it 'does not infer consumer status or a default country from missing information' do
    resolution = client.resolve(document: document.with(buyer: document.buyer.with(legal_registration: nil)))
    expect(resolution.status).to eq(:missing_information)
  end

  it 'rejects a stale resolution after a document changes' do
    resolution = client.resolve(document:, specification:)
    expect { client.build_xml(document: document.with(invoice_number: 'changed'), resolution:) }
      .to raise_error(EuEinvoice::ResolutionError)
  end

  it 'rejects a resolution created by another client' do
    resolution = client.resolve(document:, specification:)
    other = described_class.new(packs: [pack], validation: :structural)
    expect { other.build_xml(document:, resolution:) }.to raise_error(EuEinvoice::ResolutionError)
  end

  it 'accepts a resolution for an equivalent reconstructed document' do
    resolution = client.resolve(document:, specification:)
    rebuilt_buyer = EuEinvoice::Party.new(**document.buyer.to_h)
    rebuilt = EuEinvoice::Document.new(**document.to_h, buyer: rebuilt_buyer)
    expect(rebuilt).not_to equal(document)
    expect(client.build_xml(document: rebuilt, resolution:).report).to be_valid
  end

  it 'rejects a resolution after a previously absent nested value is filled' do
    original = document.with(buyer: document.buyer.with(trading_name: nil))
    resolution = client.resolve(document: original, specification:)
    changed = original.with(buyer: original.buyer.with(trading_name: 'New trade name'))
    expect { client.build_xml(document: changed, resolution:) }.to raise_error(EuEinvoice::ResolutionError)
  end

  it 'distinguishes nested field identities even when their values are exchanged' do
    original = document.with(buyer: document.buyer.with(name: 'Buyer', trading_name: 'Trading'))
    resolution = client.resolve(document: original, specification:)
    changed = original.with(buyer: original.buyer.with(name: 'Trading', trading_name: 'Buyer'))
    expect { client.build_xml(document: changed, resolution:) }.to raise_error(EuEinvoice::ResolutionError)
  end

  it 'takes required inputs from the selected specification rather than a country assumption' do
    expect(client.resolve(document:, specification:).required_inputs).to eq([:pdf])
    xml_only = specification.with(manifest: specification.manifest.merge(container: nil, required_inputs: []))
    resolver = EuEinvoice::Resolver.new(specifications: [xml_only], policy: EuEinvoice::Policy.new, owner: Object.new)
    expect(resolver.call(document:, specification: xml_only).required_inputs).to be_empty
  end

  it 'bounds generated XML as well as imported XML' do
    limited = described_class.new(packs: [pack], validation: :structural,
                                  limits: EuEinvoice::ResourceLimits.new(xml_bytes: 100))
    expect { limited.build_xml(document:, specification:) }.to raise_error(EuEinvoice::ResourceLimitError)
  end

  it 'rejects ambiguous extraction providers instead of silently taking the first' do
    alternative = pack.dup
    alternative.define_singleton_method(:specifications) { [] }
    multiple = described_class.new(packs: [pack, alternative], validation: :structural)
    expect { multiple.extract_xml(pdf: '%PDF-1.7') }.to raise_error(EuEinvoice::AmbiguousSpecificationError)
  end

  it 'does not select an arbitrary version on ambiguous XML' do
    spec = specification.with(version: 'test-version', fingerprint: nil)
    alternate = Struct.new(:specifications) do
      def adapter(validation:, limits:)
        EuEinvoice::France::Adapter.new(specifications:, validation:, limits:)
      end
    end.new([spec])
    multi = described_class.new(packs: [pack, alternate], validation: :structural)
    expect { multi.read(xml) }.to raise_error(EuEinvoice::AmbiguousSpecificationError)
  end

  it 'reports an unsupported XML syntax without mislabelling it as ambiguous' do
    adapter = Object.new
    adapter.define_singleton_method(:prepare) { |xml:| xml }
    adapter.define_singleton_method(:detect) { |**| [] }
    adapter.define_singleton_method(:can_read?) { |**| false }
    unsupported_pack = Struct.new(:specifications, :client_adapter) do
      def adapter(**) = client_adapter
    end.new([specification], adapter)
    unsupported = described_class.new(packs: [unsupported_pack], validation: :structural)

    expect { unsupported.read('<ubl/>') }.to raise_error(EuEinvoice::UnknownProfileError) do |error|
      expect(error.details).to include(candidates: 0)
    end
  end

  it 'reports malformed XML as an invalid validation report' do
    expect(client.validate_xml(xml: '<broken')).to be_invalid
  end

  it 'leaves caller IO open and returns independent result streams' do
    input = StringIO.new(xml)
    client.read(input)
    expect(input).not_to be_closed
    artifact = client.build_xml(document:, specification:)
    stream = artifact.to_io
    stream.read(1)
    expect(artifact.to_io.read).to eq(artifact.bytes)
  end

  it 'generates a PDF and extracts the exact serialized XML' do
    backend = EuEinvoice::Composers::Ghostscript.new(embedding: EuEinvoice::France::EMBEDDING)
    skip 'Ghostscript resources unavailable' unless backend.available?

    artifact = client.generate(document:, specification:, pdf: build_pdf)
    extracted = client.extract_xml(pdf: artifact)
    expect(extracted.bytes).to eq(client.build_xml(document:, specification:).bytes)
    expect(client.read(artifact).source_type).to eq(:pdf)
  end
end
