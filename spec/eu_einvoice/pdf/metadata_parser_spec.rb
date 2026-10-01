# frozen_string_literal: true

require 'eu_einvoice/pdf/metadata_parser'

RSpec.describe EuEinvoice::Pdf::MetadataParser do
  it 'rejects document types in XMP without expanding entities' do
    metadata = '<!DOCTYPE root [<!ENTITY content "secret">]><root>&content;</root>'

    expect { described_class.new.call(metadata) }.to raise_error(EuEinvoice::VerificationError)
  end

  it 'enforces metadata depth before building its DOM' do
    parser = described_class.new(limits: EuEinvoice::ResourceLimits.new(xml_depth: 1))

    expect { parser.call('<root><child/></root>') }.to raise_error(EuEinvoice::ResourceLimitError)
  end
end
