# frozen_string_literal: true

require 'eu_einvoice/error'

module EuEinvoice
  class ResourceLimits
    DEFAULTS = {
      xml_bytes: 10 * 1024 * 1024, xml_depth: 128, xml_nodes: 250_000,
      pdf_bytes: 50 * 1024 * 1024, output_pdf_bytes: 100 * 1024 * 1024,
      pdf_pages: 500, pdf_objects: 100_000, attachments: 32, tree_depth: 64,
      process_timeout: 60, process_memory_bytes: 1024 * 1024 * 1024
    }.freeze

    attr_reader(*DEFAULTS.keys)

    def initialize(**values)
      unknown = values.keys - DEFAULTS.keys
      raise ArgumentError, "Unknown resource limits: #{unknown.join(', ')}" unless unknown.empty?

      DEFAULTS.merge(values).each do |name, value|
        validate!(name, value)
        instance_variable_set("@#{name}", value)
      end
      freeze
    end

    def to_h
      DEFAULTS.to_h { |name, _value| [name, public_send(name)] }.freeze
    end

    def check!(resource, actual)
      maximum = public_send(resource)
      return if actual <= maximum

      raise ResourceLimitError.new('Resource limit exceeded', resource:, limit: maximum, actual:)
    end

    private

    def validate!(name, value)
      valid_type = value.is_a?(Integer) || (name == :process_timeout && value.is_a?(Float))
      return if valid_type && value.positive? && value.finite?

      raise ArgumentError, "#{name} must be positive"
    end
  end
end
