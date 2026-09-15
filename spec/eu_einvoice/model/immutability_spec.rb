# frozen_string_literal: true

require 'spec_helper'
require 'eu_einvoice/document'

RSpec.describe EuEinvoice::Model::Immutability do
  it 'provides nil scalar defaults and independent frozen collection defaults' do
    first = EuEinvoice::Document.new
    second = EuEinvoice::Document.new

    expect([first.invoice_number, first.lines, first.lines.frozen?, first.lines.equal?(second.lines)])
      .to eq([nil, [], true, false])
  end

  it 'copies mutable input values' do
    inputs = [+'INV-42', +'source detail']
    document = EuEinvoice::Document.new(invoice_number: inputs[0], notes: [EuEinvoice::Note.new(content: inputs[1])])
    inputs.each { |value| value.replace('changed') }

    expect([document.invoice_number, document.notes.first.content]).to eq(['INV-42', 'source detail'])
  end

  it 'deeply freezes mutable values' do
    document = EuEinvoice::Document.new(invoice_number: +'INV-42', notes: [EuEinvoice::Note.new(content: +'detail')])

    expect([document.invoice_number.frozen?, document.notes.frozen?, document.notes.first.content.frozen?])
      .to eq([true, true, true])
  end

  it 'rejects floats throughout the model' do
    expect { EuEinvoice::Totals.new(grand_total: 1.5) }
      .to raise_error(TypeError, 'Float values are not supported; use BigDecimal for decimal values')
  end

  it 'rejects non-array collection values' do
    expect { EuEinvoice::Document.new(lines: 'not an array') }.to raise_error(TypeError, 'lines must be an Array')
  end

  it 'rejects unknown attributes' do
    expect { EuEinvoice::Document.new(unknown: true) }.to raise_error(ArgumentError, 'Unknown attributes: :unknown')
  end

  it 'keeps value models limited to represented EN16931 terms' do
    expect([EuEinvoice::DocumentReference.members, EuEinvoice::Delivery.members, EuEinvoice::Contact.members]).to eq(
      [%i[id line_id name issue_date], %i[location_identifier party date], %i[name telephone email]]
    )
  end

  it 'keeps collection invariants when deriving a value with Data#with' do
    original = EuEinvoice::Document.new(invoice_number: 'INV-1')
    derived = original.with(invoice_number: 'INV-2')

    expect([derived.invoice_number, derived.lines, derived.lines.frozen?]).to eq(['INV-2', [], true])
  end

  it 'copies and freezes replacements passed to Data#with' do
    replacement = +'INV-2'
    derived = EuEinvoice::Document.new.with(invoice_number: replacement)
    replacement.replace('changed')

    expect([derived.invoice_number, derived.invoice_number.frozen?]).to eq(['INV-2', true])
  end

  it 'rejects floats passed to Data#with' do
    expect { EuEinvoice::Totals.new.with(grand_total: 1.5) }
      .to raise_error(TypeError, 'Float values are not supported; use BigDecimal for decimal values')
  end

  describe 'value model defaults' do
    collection_members = {
      EuEinvoice::Party => %i[identifiers],
      EuEinvoice::PaymentInstructions => %i[credit_transfers],
      EuEinvoice::Product => %i[attributes classifications],
      EuEinvoice::Line => %i[allowances charges]
    }.freeze

    collection_members.each do |model, members|
      it "initializes #{model} collections as frozen arrays" do
        values = members.map { |member| model.new.public_send(member) }

        expect(values).to all(eq([]).and(be_frozen))
      end
    end
  end
end
