# frozen_string_literal: true

module EuEinvoice
  module France
    module AddressingRules
      # PPF OpenAPI 1.11.0 distinguishes suffix punctuation from routing-code punctuation.
      PATTERNS = { siren: /\A[0-9]{9}\z/, siret: /\A[0-9]{14}\z/,
                   suffix: /\A[-_.@a-zA-Z0-9]{1,100}\z/, routing_code: %r{\A[-_/@a-zA-Z0-9]{1,100}\z} }.freeze
      private_constant :PATTERNS

      module_function

      def call(siren:, siret:, suffix:, routing_code:)
        values = { siren:, siret:, suffix:, routing_code: }
        values.each { |field, value| validate_format(field, value) unless value.nil? }
        values[:siren] ||= siret&.slice(0, 9)
        validate_identifiers(values[:siren], siret)
        validate_addressing(siret, suffix, routing_code)
        Model.copy_and_freeze(values)
      end

      def validate_format(field, value)
        return if value.is_a?(String) && value.bytesize <= 100 && value.valid_encoding? &&
                  value.ascii_only? && PATTERNS.fetch(field).match?(value)

        invalid!(:invalid_format, field)
      end

      def validate_identifiers(siren, siret)
        invalid!(:missing_identifier, :siren) unless siren
        invalid!(:invalid_checksum, :siren) unless luhn?(siren) && siren != '000000000'
        return unless siret

        invalid!(:inconsistent_identifiers, :siret) unless siret.start_with?(siren)
        return if valid_siret_checksum?(siren, siret)

        invalid!(:invalid_checksum, :siret)
      end

      def validate_addressing(siret, suffix, routing_code)
        invalid!(:conflicting_addressing, :suffix) if suffix && (siret || routing_code)
        invalid!(:missing_establishment, :routing_code) if routing_code && !siret
      end

      def luhn?(value)
        value.bytes.reverse.each_with_index.sum do |byte, index|
          digit = byte - 48
          digit *= 2 if index.odd?
          digit > 9 ? digit - 9 : digit
        end.remainder(10).zero?
      end

      def digit_sum(value)
        value.bytes.sum { |byte| byte - 48 }
      end

      def valid_siret_checksum?(siren, siret)
        luhn?(siret) || (siren == '356000000' && digit_sum(siret).remainder(5).zero?)
      end

      def invalid!(code, field)
        raise InvalidAddressError.new('Invalid French billing address', code:, field:)
      end
    end

    private_constant :AddressingRules
  end
end
