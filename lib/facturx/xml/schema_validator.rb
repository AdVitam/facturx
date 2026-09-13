# frozen_string_literal: true

require 'nokogiri'
require_relative '../error'
require_relative 'schema_registry'

module Facturx
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

        def load_schema(path)
          schema_cache[path] || schema_cache_mutex.synchronize do
            schema_cache[path] ||= File.open(path, 'rb') { |file| Nokogiri::XML::Schema(file) }
          end
        end
      end

      def initialize(registry: SchemaRegistry.new)
        @registry = registry
      end

      def call(document:, profile:)
        validation_errors = load_schema(profile).validate(document)
        raise_validation_error(profile, validation_errors) unless validation_errors.empty?
      end

      private

      def load_schema(profile)
        self.class.send(:load_schema, @registry.fetch(profile))
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
