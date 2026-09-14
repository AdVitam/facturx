# frozen_string_literal: true

require 'spec_helper'
require_relative 'pdf/support/pdf_builder'
require_relative 'facturx/writer/support/document_factory'

RSpec.describe Facturx do
  include PdfSupport

  let(:xml) { File.binread(File.expand_path('fixtures/xml/en16931.xml', __dir__)) }
  let(:composer) { Facturx::Composers::Ghostscript.new }
  let(:profile) { Facturx::Profiles.fetch(:en16931) }
  let(:maximal_document) { WriterDocumentFactory.maximal_document(profile) }
  let(:minimum_document) do
    reading = described_class.read(File.binread(File.expand_path('fixtures/xml/minimum.xml', __dir__)))
    address = Facturx::Address.new(country_code: 'FR')
    reading.document.with(guideline_urn: nil, seller: reading.document.seller.with(address:))
  end

  it 'validates XML through the public facade' do
    report = described_class.validate_xml(xml:)

    expect(report).to have_attributes(valid?: true, profile:)
  end

  it 'reports malformed XML through the public facade' do
    report = described_class.validate_xml(xml: '<broken')

    expect(report).to have_attributes(invalid?: true, profile: nil,
                                      issues: include(have_attributes(layer: :syntax)))
  end

  it 'rejects a non-string XML source through the public facade' do
    expect { described_class.validate_xml(xml: nil) }
      .to raise_error(Facturx::InvalidSourceError, 'XML must be provided as a byte String')
  end

  it 'rejects a non-string XML source before attaching' do
    expect { described_class.attach(pdf: 'source-pdf', xml: nil) }
      .to raise_error(Facturx::InvalidSourceError, 'XML must be provided as a byte String')
  end

  it 'reads XML through the public facade' do
    reading = described_class.read(xml)
    expect(reading).to have_attributes(source: xml, document: have_attributes(invoice_number: 'F-2023-004'))
  end

  it 'validates and writes documents through the public facade' do
    report = described_class.validate_document(document: minimum_document, profile: :minimum)
    xml_output = described_class.build_xml(document: minimum_document, profile: :minimum)
    expect([report.valid?, xml_output.include?(Facturx::Profiles.fetch(:minimum).guideline_urn)]).to eq([true, true])
  end

  it 'reports unrepresentable optional values through the public facade' do
    profile = Facturx::Profiles.fetch(:en16931)
    document = WriterDocumentFactory.complete_document(profile).with(
      project_reference: Facturx::DocumentReference.new(name: 'Project')
    )

    expect { described_class.build_xml(document:, profile:) }.to raise_invalid_document_for('BT-11')
  end

  it 'delegates PDF generation through the public facade' do
    document = Facturx::Document.new
    generator = instance_double(Facturx::Generate, call: 'generated-pdf')
    stub_const('Facturx::DEFAULT_GENERATOR', generator)

    described_class.generate(pdf: 'source-pdf', document:, profile: :minimum)
    expect(generator).to have_received(:call).with(pdf: 'source-pdf', document:, profile: :minimum)
  end

  it 'composes and extracts the exact XML through the public facade' do
    skip 'Ghostscript Factur-X resources are unavailable' unless composer.available?

    facturx_pdf = described_class.attach(pdf: build_pdf, xml:)

    expect(described_class.extract_xml(pdf: facturx_pdf)).to eq(xml.b)
  end

  it 'generates, extracts, and reads a typed document through the public facade' do
    skip 'Ghostscript Factur-X resources are unavailable' unless composer.available?

    expect(generate_and_read).to have_attributes(profile:, document: maximal_document, diagnostics: [])
  end

  it 'requires Ghostscript resources in CI' do
    skip 'CI-only dependency assertion' unless ENV['CI']

    expect(composer).to be_available
  end

  def raise_invalid_document_for(term_id)
    raise_error(Facturx::InvalidDocumentError) do |error|
      expect(error.details.fetch(:report).issues).to include(have_attributes(term_id:))
    end
  end

  def generate_and_read
    pdf = Facturx.generate(pdf: build_pdf, document: maximal_document, profile:)
    Facturx.read(pdf)
  end
end
