# frozen_string_literal: true

require 'eu_einvoice/model/immutable'

module EuEinvoice
  READING_SOURCE_TYPES = %i[xml pdf].freeze
  private_constant :READING_SOURCE_TYPES

  Reading = Data.define(:document, :profile, :diagnostics, :source, :source_type, :specification) do
    include Model::ValidatedWith

    def initialize(document:, profile:, source:, **options)
      Model.validate_attributes!(%i[diagnostics source_type specification], options)
      diagnostics = options.fetch(:diagnostics, [])
      source_type = options.fetch(:source_type, :xml)
      validate_source!(source, diagnostics, source_type)
      xml = source.dup.force_encoding(Encoding::BINARY).freeze
      super(document:, profile:, diagnostics: Model.copy_and_freeze(diagnostics), source: xml, source_type:,
            specification: options[:specification])
    end

    private

    def validate_source!(source, diagnostics, source_type)
      raise TypeError, 'source must be a byte String' unless source.is_a?(String)
      raise TypeError, 'diagnostics must be an Array' unless diagnostics.is_a?(Array)
      return if READING_SOURCE_TYPES.include?(source_type)

      raise ArgumentError, "Unknown source type: #{source_type.inspect}"
    end
  end
end
