# frozen_string_literal: true

require 'facturx/xml/parser'

RSpec.describe Facturx::Xml::Parser do
  subject(:parser) { described_class.new }

  it 'strictly parses a well-formed byte String' do
    document = parser.call(xml: '<invoice>Facture n° 42</invoice>'.b)

    expect(document.root.text).to eq('Facture n° 42')
  end

  it 'rejects malformed XML with a typed error' do
    expect { parser.call(xml: '<invoice>') }
      .to raise_error(Facturx::InvalidXmlError, 'XML is malformed')
  end

  it 'reports parser diagnostics as structured details' do
    parser.call(xml: '<invoice>')
  rescue Facturx::InvalidXmlError => e
    expect(e.details.fetch(:errors).first).to include(:message, :line, :column)
  end

  it 'rejects values other than byte Strings' do
    expect { parser.call(xml: StringIO.new('<invoice/>')) }
      .to raise_error(Facturx::InvalidSourceError, 'XML must be provided as a byte String')
  end

  it 'does not expand external entities' do
    xml = '<!DOCTYPE root [<!ENTITY secret SYSTEM "file:///etc/passwd">]><root>&secret;</root>'

    expect(parser.call(xml: xml).root.text).to be_empty
  end
end
