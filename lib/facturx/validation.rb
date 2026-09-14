# frozen_string_literal: true

require_relative 'error'
require_relative 'model/immutable'

module Facturx
  module Validation
    LAYERS = %i[syntax profile document xsd].freeze
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

    Report = Data.define(:profile, :issues) do
      include Model::ValidatedWith

      def initialize(profile: nil, issues: [])
        raise TypeError, 'issues must be an Array' unless issues.is_a?(Array)
        raise TypeError, 'issues must contain validation issues' unless issues.all?(Issue)

        super(profile: Model.copy_and_freeze(profile), issues: Model.copy_and_freeze(issues))
      end

      def valid? = issues.none? { |issue| issue.severity == :error }

      def invalid? = !valid?
    end
  end
end
