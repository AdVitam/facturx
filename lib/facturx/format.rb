# frozen_string_literal: true

require 'bigdecimal'
require 'date'
require_relative 'error'

module Facturx
  module Format
    FORMATTERS = {
      string: :string,
      date_102: :formatted_date,
      decimal: :decimal,
      boolean: :boolean,
      binary: :binary
    }.freeze

    module_function

    def call(value, term:)
      formatter = FORMATTERS[term.type]
      raise ArgumentError, "Unsupported format type: #{term.type.inspect}" unless formatter

      begin
        public_send(formatter, value, term.scale)
      rescue ArgumentError, TypeError => e
        raise FormattingError.new(
          'Value cannot be formatted',
          value:, type: term.type, scale: term.scale, term_id: term.id, group_id: term.group_id, path: term.xpath
        ), cause: e
      end
    end

    def string(value, _scale = nil)
      raise TypeError, 'expected a String' unless value.is_a?(String)
      raise ArgumentError, 'String must contain a non-whitespace character' if value.match?(/\A[[:space:]]*\z/)

      value.dup.freeze
    end

    def formatted_date(value, _scale = nil)
      raise TypeError, 'expected a Date' unless value.instance_of?(Date)

      value.strftime('%Y%m%d').freeze
    end

    def decimal(value, scale = nil)
      raise TypeError, 'expected a BigDecimal or Integer' unless value.is_a?(BigDecimal) || value.is_a?(Integer)
      raise ArgumentError, 'decimal must be finite' if value.is_a?(BigDecimal) && !value.finite?

      case scale
      when nil then fixed_decimal(value)
      when 2 then fixed_scale(value, 2)
      else raise ArgumentError, "Unsupported decimal scale: #{scale.inspect}"
      end.freeze
    end

    def boolean(value, _scale = nil)
      return 'true' if value.equal?(true)
      return 'false' if value.equal?(false)

      raise TypeError, 'expected true or false'
    end

    def binary(value, _scale = nil)
      raise TypeError, 'expected a binary String' unless value.is_a?(String) && value.encoding == Encoding::BINARY

      [value].pack('m0').freeze
    end

    def fixed_decimal(value)
      value.is_a?(Integer) ? value.to_s : value.to_s('F')
    end
    private_class_method :fixed_decimal

    def fixed_scale(value, scale)
      decimal_value = value.is_a?(Integer) ? BigDecimal(value) : value
      rounded = decimal_value.round(scale)
      raise ArgumentError, "decimal has more than #{scale} non-zero fractional digits" unless rounded == decimal_value

      integer, fraction = rounded.to_s('F').split('.', 2)
      "#{integer}.#{fraction.to_s.ljust(scale, '0')}"
    end
    private_class_method :fixed_scale
  end
end
