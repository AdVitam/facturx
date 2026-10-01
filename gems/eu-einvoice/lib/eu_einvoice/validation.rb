# frozen_string_literal: true

require 'eu_einvoice/error'
require 'eu_einvoice/model/immutable'

module EuEinvoice
  module Validation
    LAYERS = %i[syntax profile document xsd schematron].freeze
    SEVERITIES = %i[error warning].freeze
    ISSUE_DEFAULTS = {
      severity: :error,
      term_id: nil,
      group_id: nil,
      path: nil,
      line: nil,
      column: nil,
      details: {}
    }.freeze
    private_constant :LAYERS, :SEVERITIES, :ISSUE_DEFAULTS
    REPORT_DEFAULTS = { profile: nil, issues: [], specification: nil, requested_coverage: :structural,
                        executed_steps: [], resources: {} }.freeze
    private_constant :REPORT_DEFAULTS

    Issue = Data.define(:code, :message, :layer, :severity, :term_id, :group_id, :path, :line, :column, :details) do
      include Model::ValidatedWith

      def initialize(**attributes)
        Model.validate_attributes!(self.class.members, attributes)
        attributes.fetch_values(:code, :message, :layer)
        values = ISSUE_DEFAULTS.merge(attributes)
        validate_values!(values)

        super(**values.transform_values { |value| Model.copy_and_freeze(value) })
      end

      private

      def validate_values!(values)
        unless LAYERS.include?(values[:layer])
          raise ArgumentError, "Unknown validation layer: #{values[:layer].inspect}"
        end
        unless SEVERITIES.include?(values[:severity])
          raise ArgumentError, "Unknown validation severity: #{values[:severity].inspect}"
        end
        raise TypeError, 'details must be a Hash' unless values[:details].is_a?(Hash)
      end
    end

    Report = Data.define(:profile, :issues, :specification, :requested_coverage, :executed_steps, :resources) do
      include Model::ValidatedWith

      def initialize(**attributes)
        Model.validate_attributes!(self.class.members, attributes)
        values = REPORT_DEFAULTS.merge(attributes)
        validate_values!(values)
        super(**Model.copy_and_freeze(values))
      end

      def valid? = issues.none? { |issue| issue.severity == :error }

      def invalid? = !valid?

      def complete? = %i[xsd schematron].all? { |step| executed_steps.include?(step) }

      def steps
        LAYERS.to_h do |layer|
          state = if executed_steps.include?(layer)
                    :executed
                  elsif not_requested?(layer)
                    :not_requested
                  else
                    :blocked
                  end
          [layer, state]
        end.freeze
      end

      private

      def not_requested?(layer)
        return true if layer == :schematron && requested_coverage == :structural
        return executed_steps.include?(:syntax) if layer == :document

        %i[syntax profile].include?(layer) && executed_steps.include?(:document)
      end

      def validate_values!(values)
        issues = values.fetch(:issues)
        raise TypeError, 'issues must be an Array of validation issues' unless issues.is_a?(Array) && issues.all?(Issue)
        return if %i[structural full].include?(values.fetch(:requested_coverage))

        raise ArgumentError, 'Unknown validation coverage'
      end
    end
  end
end
