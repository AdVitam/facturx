# frozen_string_literal: true

require 'spec_helper'
require 'facturx/coerce'

RSpec.describe Facturx::Coerce do
  describe '.call' do
    it 'preserves nil values' do
      expect(described_class.call(nil, type: :decimal)).to be_nil
    end

    it 'copies and freezes strings' do
      input = +'invoice'
      output = described_class.call(input, type: :string)
      input.replace('changed')

      expect([output, output.frozen?]).to eq(['invoice', true])
    end

    it 'coerces Factur-X format 102 dates' do
      expect(described_class.call('20260912', type: :date_102)).to eq(Date.new(2026, 9, 12))
    end

    it 'coerces decimal types without losing precision' do
      value = described_class.call('1234.5678', type: :decimal)

      expect([value.class, value.to_s('F')]).to eq([BigDecimal, '1234.5678'])
    end

    it 'coerces every XML Schema boolean representation' do
      values = %w[true 1 false 0].map { |value| described_class.call(value, type: :boolean) }

      expect(values).to eq([true, true, false, false])
    end

    it 'decodes whitespace-separated base64 as binary bytes' do
      output = described_class.call("AP8=\n", type: :binary)

      expect([output, output.encoding, output.frozen?]).to eq(["\x00\xFF".b, Encoding::BINARY, true])
    end

    context 'with invalid data' do
      subject(:error) do
        described_class.call('31/12/2026', type: :date_102,
                                           term_id: :'BT-2', path: '/invoice/date')
      rescue Facturx::CoercionError => e
        e
      end

      it 'reports structured context' do
        expected = { value: '31/12/2026', type: :date_102, scale: nil,
                     term_id: :'BT-2', path: '/invoice/date' }

        expect([error.details, error.cause.class]).to eq([expected, ArgumentError])
      end
    end

    it 'rejects floats rather than silently converting them' do
      expect { described_class.call(12.3, type: :decimal) }
        .to raise_error(Facturx::CoercionError, 'Value cannot be coerced')
    end

    it 'exposes unsupported types as programming errors' do
      expect { described_class.call('value', type: :unknown) }
        .to raise_error(ArgumentError, 'Unsupported coercion type: :unknown')
    end
  end
end
