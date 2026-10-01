# frozen_string_literal: true

require 'spec_helper'
require 'eu_einvoice/format'
require 'eu_einvoice/term'

RSpec.describe EuEinvoice::Format do
  subject(:format) { described_class.call(value, term:) }

  let(:term) { build_term(type:) }

  describe '.call' do
    it 'round-trips every supported type and scale through Coerce' do
      round_trip_cases.each do |type, scale, values|
        values.each { |input| expect(round_trip(input, type:, scale:)).to eq(input) }
      end
    end

    context 'with a string term' do
      let(:type) { :string }
      let(:value) { +'Invoice 42' }

      it 'returns an independent frozen String' do
        output = format
        value.replace('changed')

        expect([output, output.frozen?]).to eq(['Invoice 42', true])
      end

      it 'rejects non-String values' do
        expect { described_class.call(:invoice, term:) }
          .to raise_error(EuEinvoice::FormattingError, 'Value cannot be formatted')
      end

      it 'rejects empty and whitespace-only values' do
        expect { described_class.call(" \t\n", term:) }
          .to raise_error(EuEinvoice::FormattingError, 'Value cannot be formatted')
      end
    end

    context 'with a date term' do
      let(:type) { :date_102 }
      let(:value) { Date.new(2026, 9, 12) }

      it 'formats an exact Date as format 102' do
        expect(format).to eq('20260912')
      end

      it 'rejects DateTime values' do
        expect { described_class.call(DateTime.new(2026, 9, 12), term:) }
          .to raise_error(EuEinvoice::FormattingError)
      end
    end

    context 'with an unscaled decimal term' do
      let(:type) { :decimal }
      let(:value) { BigDecimal('12345678901234567890.125') }

      it 'uses fixed notation without losing precision' do
        expect(format).to eq('12345678901234567890.125')
      end

      it 'accepts Integer values' do
        expect(described_class.call(42, term:)).to eq('42')
      end

      it 'rejects Float values' do
        expect { described_class.call(12.3, term:) }
          .to raise_error(EuEinvoice::FormattingError, 'Value cannot be formatted')
      end
    end

    context 'with a scale-two decimal term' do
      let(:type) { :decimal }
      let(:term) { build_term(type:, scale: 2) }
      let(:value) { BigDecimal('12.3') }

      it 'always emits exactly two fractional digits' do
        outputs = [value, BigDecimal('12.3400'), 12].map { |item| described_class.call(item, term:) }

        expect(outputs).to eq(%w[12.30 12.34 12.00])
      end

      it 'rejects values whose non-zero precision would be lost' do
        expect { described_class.call(BigDecimal('12.345'), term:) }
          .to raise_error(EuEinvoice::FormattingError, 'Value cannot be formatted')
      end
    end

    context 'with a boolean term' do
      let(:type) { :boolean }
      let(:value) { true }

      it 'emits XML Schema boolean literals' do
        expect([format, described_class.call(false, term:)]).to eq(%w[true false])
      end

      it 'rejects integer boolean representations' do
        expect { described_class.call(1, term:) }.to raise_error(EuEinvoice::FormattingError)
      end
    end

    context 'with a binary term' do
      let(:type) { :binary }
      let(:value) { "\x00\xFF".b }

      it 'uses strict Base64 without line breaks' do
        expect(format).to eq('AP8=')
      end

      it 'rejects Strings that are not binary bytes' do
        expect { described_class.call('text', term:) }.to raise_error(EuEinvoice::FormattingError)
      end
    end

    it 'reports the term context when formatting fails' do
      error = formatting_error('20260912', build_term(type: :date_102))

      expect(error.details).to eq(
        value: '20260912', type: :date_102, scale: nil,
        term_id: 'BT-2', group_id: 'BG-0', path: '/ram:Date'
      )
    end

    it 'exposes unsupported types as programming errors' do
      term = build_term(type: :unknown)

      expect { described_class.call('value', term:) }
        .to raise_error(ArgumentError, 'Unsupported format type: :unknown')
    end
  end

  def build_term(type:, scale: nil)
    definition = EuEinvoice::TermDefinition.new('BT-2', :document, :issue_date, 'BG-0', type, scale, '1..1')
    EuEinvoice::Term.new(definition, '/ram:Date', type)
  end

  def formatting_error(value, term)
    described_class.call(value, term:)
  rescue EuEinvoice::FormattingError => e
    e
  end

  def round_trip_cases
    [
      [:string, nil, ['Invoice 42', "Facture \u00e9mise"]],
      [:date_102, nil, [Date.new(2026, 9, 12), Date.new(2000, 2, 29)]],
      [:decimal, nil, [BigDecimal('0'), BigDecimal('-1234567890.123456789')]],
      [:decimal, 2, [BigDecimal('0'), BigDecimal('-12.30'), BigDecimal('999999.99')]],
      [:boolean, nil, [true, false]],
      [:binary, nil, ["\x00\xFF".b, "Factur-X\x00".b]]
    ]
  end

  def round_trip(input, type:, scale:)
    term = build_term(type:, scale:)
    EuEinvoice::Coerce.call(described_class.call(input, term:), type:, scale:)
  end
end
