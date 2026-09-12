# frozen_string_literal: true

require 'spec_helper'
require_relative 'pdf/support/pdf_builder'

RSpec.describe Facturx do
  include PdfSupport

  let(:xml) { File.binread(File.expand_path('fixtures/xml/en16931.xml', __dir__)) }
  let(:composer) { Facturx::Composers::Ghostscript.new }
  let(:minimum_document) do
    reading = described_class.read(File.binread(File.expand_path('fixtures/xml/minimum.xml', __dir__)))
    address = Facturx::Address.new(country_code: 'FR')
    reading.document.with(guideline_urn: nil, seller: reading.document.seller.with(address:))
  end

  it 'verifies XML through the public facade' do
    expect(described_class.verify_xml(xml:)).to be(true)
  end

  it 'raises a typed error for malformed XML' do
    expect { described_class.verify_xml(xml: '<broken') }.to raise_error(Facturx::InvalidXmlError)
  end

  it 'reads XML through the public facade' do
    reading = described_class.read(xml)
    expect(reading).to have_attributes(source: xml, document: have_attributes(invoice_number: 'F-2023-004'))
  end

  it 'validates and writes documents through the public facade' do
    report = described_class.validate_document(document: minimum_document, profile: :minimum)
    xml_output = described_class.build_xml(minimum_document, profile: :minimum)
    expect([report.valid?, xml_output.include?(Facturx::Profiles.fetch(:minimum).guideline_urn)]).to eq([true, true])
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

  it 'requires Ghostscript resources in CI' do
    skip 'CI-only dependency assertion' unless ENV['CI']

    expect(composer).to be_available
  end
end
