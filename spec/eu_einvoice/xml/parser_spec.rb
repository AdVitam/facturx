# frozen_string_literal: true

require 'eu_einvoice/xml/parser'

RSpec.describe EuEinvoice::Xml::Parser, :aggregate_failures do
  subject(:parser) { described_class.new }

  it 'strictly parses a well-formed byte String' do
    document = parser.call(xml: '<invoice>Facture n° 42</invoice>'.b)

    expect(document.root.text).to eq('Facture n° 42')
  end

  it 'rejects malformed XML with a typed error' do
    expect { parser.call(xml: '<invoice>') }
      .to raise_error(EuEinvoice::InvalidXmlError, 'XML is malformed')
  end

  it 'reports parser diagnostics as structured details' do
    parser.call(xml: '<invoice>')
  rescue EuEinvoice::InvalidXmlError => e
    expect(e.details.fetch(:errors).first).to include(:message, :line, :column)
  end

  it 'reads IO inputs without closing them' do
    input = StringIO.new('<invoice/>')

    expect(parser.call(xml: input).root.name).to eq('invoice')
    expect(input).not_to be_closed
  end

  it 'does not expand external entities' do
    xml = '<!DOCTYPE root [<!ENTITY secret SYSTEM "file:///etc/passwd">]><root>&secret;</root>'

    expect { parser.call(xml:) }.to raise_error(EuEinvoice::InvalidXmlError)
  end

  it 'rejects XML deeper than its configured budget' do
    limited = described_class.new(limits: EuEinvoice::ResourceLimits.new(xml_depth: 2))

    expect { limited.call(xml: '<a><b><c/></b></a>') }.to raise_error(EuEinvoice::ResourceLimitError)
  end

  it 'rejects XML with too many nodes' do
    limited = described_class.new(limits: EuEinvoice::ResourceLimits.new(xml_nodes: 2))

    expect { limited.call(xml: '<a><b/><c/></a>') }.to raise_error(EuEinvoice::ResourceLimitError)
  end
end
