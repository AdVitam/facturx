# frozen_string_literal: true

require 'bigdecimal'
require 'date'
require 'eu_einvoice/error'

module EuEinvoice
  class CoercionError < Error; end

  module Coerce
    CONVERTERS = {
      string: :string,
      date_102: :formatted_date,
      decimal: :decimal,
      boolean: :boolean,
      binary: :binary
    }.freeze

    module_function

    def call(value, type:, scale: nil, **context)
      return if value.nil?

      converter = CONVERTERS[type]
      raise ArgumentError, "Unsupported coercion type: #{type.inspect}" unless converter

      begin
        public_send(converter, value, context)
      rescue ArgumentError, TypeError => e
        raise CoercionError.new('Value cannot be coerced', value:, type:, scale:, **context), cause: e
      end
    end

    def string(value, _context = nil)
      raise TypeError, 'expected a String' unless value.is_a?(String)

      value.dup.freeze
    end

    def decimal(value, _context = nil)
      raise TypeError, 'Float values are not supported' if value.is_a?(Float)
      return value if value.is_a?(BigDecimal)

      decimal = BigDecimal(value.to_s, exception: true)
      raise ArgumentError, 'decimal must be finite' unless decimal.finite?

      decimal
    end

    def formatted_date(value, _context = nil)
      return value.dup.freeze if value.is_a?(Date)

      text = string(value)
      raise ArgumentError, 'date must use format 102' unless text.match?(/\A\d{8}\z/)

      Date.strptime(text, '%Y%m%d').freeze
    end

    def boolean(value, _context = nil)
      return value if [true, false].include?(value)

      case string(value)
      when 'true', '1' then true
      when 'false', '0' then false
      else raise ArgumentError, 'boolean must be true, false, 1, or 0'
      end
    end

    def binary(value, _context = nil)
      encoded = string(value).delete(" \t\r\n")
      encoded.unpack1('m0').force_encoding(Encoding::BINARY).freeze
    end
  end
end
