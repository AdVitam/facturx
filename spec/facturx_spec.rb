# frozen_string_literal: true

require 'spec_helper'
require_relative 'pdf/support/pdf_builder'

RSpec.describe Facturx do
  include PdfSupport

  let(:xml) { File.binread(File.expand_path('fixtures/xml/en16931.xml', __dir__)) }
  let(:composer) { Facturx::Composers::Ghostscript.new }

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
