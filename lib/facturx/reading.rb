# frozen_string_literal: true

require_relative 'model/immutable'

module Facturx
  READING_SOURCE_TYPES = %i[xml pdf].freeze
  private_constant :READING_SOURCE_TYPES

  Reading = Data.define(:document, :profile, :diagnostics, :source, :source_type) do
    include Model::ValidatedWith

    def initialize(document:, profile:, source:, diagnostics: [], source_type: :xml)
      raise TypeError, 'source must be a byte String' unless source.is_a?(String)
      raise TypeError, 'diagnostics must be an Array' unless diagnostics.is_a?(Array)
      unless READING_SOURCE_TYPES.include?(source_type)
        raise ArgumentError, "Unknown source type: #{source_type.inspect}"
      end

      xml = source.dup.force_encoding(Encoding::BINARY).freeze
      super(document:, profile:, diagnostics: Model.copy_and_freeze(diagnostics), source: xml, source_type:)
    end
  end
end
