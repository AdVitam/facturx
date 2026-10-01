# frozen_string_literal: true

require 'nokogiri'
require 'eu_einvoice/error'

module EuEinvoice
  module Xml
    class SchemaValidator
      @schema_cache = {}
      @schema_cache_mutex = Mutex.new

      class << self
        def inherited(subclass)
          super
          subclass.instance_variable_set(:@schema_cache, {})
          subclass.instance_variable_set(:@schema_cache_mutex, Mutex.new)
        end

        private

        attr_reader :schema_cache, :schema_cache_mutex

        def load_schema(path, cache_key)
          schema_cache_mutex.synchronize do
            schema_cache.shift if schema_cache.size >= 32 && !schema_cache.key?(cache_key)
            schema_cache[cache_key] ||= File.open(path, 'rb') { |file| Nokogiri::XML::Schema(file) }
          end
        end
      end

      def initialize(registry:)
        @registry = registry
      end

      def call(document:, profile:)
        validation_errors = load_schema(profile).validate(document)
        raise_validation_error(profile, validation_errors) unless validation_errors.empty?
      end

      private

      def load_schema(profile)
        path = @registry.fetch(profile)
        key = @registry.respond_to?(:fingerprint) ? @registry.fingerprint(profile) : path
        self.class.send(:load_schema, path, key)
      rescue SystemCallError, Nokogiri::XML::SyntaxError => e
        raise_schema_load_error(profile, e)
      end

      def raise_validation_error(profile, validation_errors)
        raise XsdValidationError.new(
          "XML is incompatible with the Factur-X #{profile.id} profile",
          profile: profile.id,
          errors: validation_errors.map { |error| issue_for(error) }.freeze
        )
      end

      def issue_for(error)
        { message: error.message, line: error.line, column: error.column, level: error.level }.freeze
      end

      def raise_schema_load_error(profile, error)
        raise SchemaLoadError.new(
          "Unable to load the Factur-X #{profile.id} schema",
          profile: profile.id,
          errors: [{ message: error.message }.freeze].freeze
        )
      end
    end
  end
end
