# frozen_string_literal: true

require 'spec_helper'
require 'facturx/format'
require 'facturx/term'

RSpec.describe Facturx::Format do
  subject(:format) { described_class.call(value, term:) }

  let(:term) { build_term(type:) }

  describe '.call' do
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
          .to raise_error(Facturx::FormattingError, 'Value cannot be formatted')
      end

      it 'rejects empty and whitespace-only values' do
        expect { described_class.call(" \t\n", term:) }
          .to raise_error(Facturx::FormattingError, 'Value cannot be formatted')
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
          .to raise_error(Facturx::FormattingError)
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
          .to raise_error(Facturx::FormattingError, 'Value cannot be formatted')
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
          .to raise_error(Facturx::FormattingError, 'Value cannot be formatted')
      end
    end

    context 'with a boolean term' do
      let(:type) { :boolean }
      let(:value) { true }

      it 'emits XML Schema boolean literals' do
        expect([format, described_class.call(false, term:)]).to eq(%w[true false])
      end

      it 'rejects integer boolean representations' do
        expect { described_class.call(1, term:) }.to raise_error(Facturx::FormattingError)
      end
    end

    context 'with a binary term' do
      let(:type) { :binary }
      let(:value) { "\x00\xFF".b }

      it 'uses strict Base64 without line breaks' do
        expect(format).to eq('AP8=')
      end

      it 'rejects Strings that are not binary bytes' do
        expect { described_class.call('text', term:) }.to raise_error(Facturx::FormattingError)
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
    Facturx::Term.new('BT-2', :document, :issue_date, 'BG-0', '/ram:Date', type, scale,
                      { en16931: '1..1' }.freeze)
  end

  def formatting_error(value, term)
    described_class.call(value, term:)
  rescue Facturx::FormattingError => e
    e
  end
end
