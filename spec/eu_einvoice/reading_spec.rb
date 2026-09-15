# frozen_string_literal: true

require 'spec_helper'
require 'eu_einvoice/diagnostic'
require 'eu_einvoice/document'
require 'eu_einvoice/profile'
require 'eu_einvoice/reading'

RSpec.describe EuEinvoice::Reading do
  let(:profile) do
    EuEinvoice::Profile.new(id: :en16931, guideline_urn: 'urn:example', conformance_level: 'EN 16931')
  end
  let(:document) { EuEinvoice::Document.new(invoice_number: 'INV-42') }

  it 'keeps an exact frozen binary copy of the XML source' do
    xml = +'<?xml version="1.0"?><invoice>café</invoice>'
    reading = described_class.new(document:, profile:, source: xml, source_type: :pdf)
    xml.replace('changed')

    expect([reading.source, reading.source.encoding, reading.source.frozen?, reading.source_type])
      .to eq(['<?xml version="1.0"?><invoice>café</invoice>'.b, Encoding::BINARY, true, :pdf])
  end

  it 'copies and freezes diagnostics and their details' do
    reading, diagnostic = reading_with_mutated_inputs

    expect([reading.diagnostics, reading.diagnostics.frozen?, reading.diagnostics.first.details,
            reading.diagnostics.first.details.frozen?])
      .to eq([[diagnostic], true, { value: 'invalid' }, true])
  end

  it 'rejects sources that are not byte strings' do
    expect { described_class.new(document:, profile:, source: nil) }
      .to raise_error(TypeError, 'source must be a byte String')
  end

  it 'rejects unknown source types' do
    expect { described_class.new(document:, profile:, source: '<invoice/>', source_type: :archive) }
      .to raise_error(ArgumentError, 'Unknown source type: :archive')
  end

  it 'preserves source invariants through Data#with' do
    source = +'updated'
    reading = described_class.new(document:, profile:, source: '<invoice/>').with(source:)
    source.replace('changed')

    expect([reading.source, reading.source.encoding,
            reading.source.frozen?]).to eq(['updated'.b, Encoding::BINARY, true])
  end

  it 'preserves diagnostic invariants through Data#with' do
    details = { value: +'original' }
    diagnostic = EuEinvoice::Diagnostic.new(code: :invalid_value, message: 'Invalid').with(details:)
    details[:value].replace('changed')

    expect(diagnostic.details).to eq(value: 'original')
  end

  it 'truncates diagnostic details at a valid character boundary' do
    diagnostic = EuEinvoice::Diagnostic.new(code: :invalid_value, message: 'Invalid', details: { value: 'é' * 101 })
    value = diagnostic.details.fetch(:value)

    expect([value.valid_encoding?, value.bytesize <= 200]).to eq([true, true])
  end

  it 'bounds diagnostic details at a valid character boundary' do
    detail = "#{'a' * 199}é"
    diagnostic = EuEinvoice::Diagnostic.new(code: :invalid_value, message: 'Invalid', details: { value: detail })

    expect([diagnostic.details[:value].bytesize, diagnostic.details[:value].valid_encoding?]).to eq([199, true])
  end

  def diagnostic_input
    details = { value: +'invalid' }
    diagnostic = EuEinvoice::Diagnostic.new(code: :invalid_value, term_id: :'BT-2', path: '/invoice/date',
                                            message: 'Invalid date', details:)
    [details, diagnostic]
  end

  def mutate_inputs(details, diagnostics)
    diagnostics.clear
    details[:value].replace('changed')
  end

  def reading_with_mutated_inputs
    details, diagnostic = diagnostic_input
    diagnostics = [diagnostic]
    reading = described_class.new(document:, profile:, source: '<invoice/>', diagnostics:)
    mutate_inputs(details, diagnostics)
    [reading, diagnostic]
  end
end
