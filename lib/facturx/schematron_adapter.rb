# frozen_string_literal: true

module Facturx
  module SchematronAdapter
    class NullValidator
      def call(**)
        []
      end
    end

    @mutex = Mutex.new
    @validator = NullValidator.new.freeze

    class << self
      def install(validator)
        raise TypeError, 'Schematron validator must respond to call' unless validator.respond_to?(:call)

        @mutex.synchronize { @validator = validator }
      end

      def call(document:, profile:)
        @validator.call(document:, profile:)
      end
    end

    private_constant :NullValidator
  end

  private_constant :SchematronAdapter
end
