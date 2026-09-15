# frozen_string_literal: true

module EuEinvoice
  module Rails
    module ApplicationConfiguration
      attr_writer :eu_einvoice

      def eu_einvoice
        @eu_einvoice ||= Configuration.new
      end
    end
  end
end
