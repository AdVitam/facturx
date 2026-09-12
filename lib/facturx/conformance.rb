# frozen_string_literal: true

require_relative 'error'
require_relative 'model/immutable'

module Facturx
  module Conformance
    UNSET = Object.new.freeze
    private_constant :UNSET

    Issue = Data.define(:code, :message, :term_id, :group_id, :path, :details) do
      include Model::ValidatedWith

      def initialize(**attributes)
        Model.validate_attributes!(self.class.members, attributes)
        attributes.fetch_values(:code, :message)
        values = { term_id: nil, group_id: nil, path: nil, details: {} }.merge(attributes)
        raise TypeError, 'details must be a Hash' unless values[:details].is_a?(Hash)

        super(**values.transform_values { |value| Model.copy_and_freeze(value) })
      end
    end

    Report = Data.define(:profile, :issues) do
      include Model::ValidatedWith

      def initialize(profile:, issues: [])
        raise TypeError, 'issues must be an Array' unless issues.is_a?(Array)

        super(profile: Model.copy_and_freeze(profile), issues: Model.copy_and_freeze(issues))
      end

      def valid? = issues.empty?

      def invalid? = !valid?
    end

    module Tracking
      private

      def definition_observed?(definition, count, path)
        cardinality = definition.cardinalities[profile.id]
        return forbidden?(definition, count, path) unless cardinality

        missing(definition, path, cardinality) if count.zero? && required?(cardinality)
        invalid_cardinality(definition, count, path, cardinality) if count > 1 && !repeated?(cardinality)
        count.positive?
      end

      def forbidden?(definition, count, path)
        return false if count.zero?

        kind = definition_kind(definition)
        add(
          :"forbidden_#{kind}",
          "#{kind.capitalize} is forbidden by the selected profile",
          **definition_context(definition, path),
          details: { profile: profile.id, count: }
        )
        false
      end

      def missing(definition, path, cardinality)
        kind = definition_kind(definition)
        add(
          :"missing_required_#{kind}",
          "Required #{kind} is missing",
          **definition_context(definition, path),
          details: { profile: profile.id, cardinality: }
        )
      end

      def invalid_cardinality(definition, count, path, cardinality)
        add(
          :invalid_cardinality,
          'Value count exceeds the profile cardinality',
          **definition_context(definition, path),
          details: { profile: profile.id, cardinality:, count: }
        )
      end

      def add(code, message, **context)
        @issues << Issue.new(code:, message:, **context)
      end

      def definition_context(definition, path)
        if definition.respond_to?(:group_id)
          { term_id: definition.id, group_id: definition.group_id, path: path || definition.xpath }
        else
          { group_id: definition.id, path: path || definition.xpath }
        end
      end

      def definition_kind(definition)
        definition.respond_to?(:group_id) ? 'term' : 'group'
      end

      def required?(cardinality) = cardinality.start_with?('1')

      def repeated?(cardinality) = cardinality.end_with?('n')

      def validate_count!(count)
        return if count.is_a?(Integer) && !count.negative?

        raise ArgumentError, 'count must be a non-negative Integer'
      end
    end
    private_constant :Tracking

    class Tracker
      include Tracking

      attr_reader :profile

      def initialize(profile:)
        @profile = profile
        @issues = []
      end

      def check_guideline(guideline_urn, path: nil)
        return if guideline_urn.nil? || guideline_urn == profile.guideline_urn

        add(
          :profile_mismatch,
          'Document guideline does not match the selected profile',
          term_id: 'BT-24',
          path:,
          details: { expected: profile.guideline_urn, actual: guideline_urn }
        )
      end

      def check_document(document, path: nil)
        check_guideline(document.guideline_urn, path:)
      end

      def group_observed?(group, count:, path: nil, group_present: true)
        validate_count!(count)
        return false unless group_present

        definition_observed?(group, count, path)
      end
      alias observe_group group_observed?

      def within_group(group, count:, path: nil, group_present: true)
        present = observe_group(group, count:, path:, group_present:)
        yield if present && block_given?
        present
      end

      def term_observed?(term, value: UNSET, values: UNSET, path: nil, group_present: true)
        return false unless group_present

        definition_observed?(term, value_count(observed_value(value, values)), path)
      end
      alias observe_term term_observed?

      def invalid_term(term, error:, path: nil)
        raise TypeError, 'error must be a FormattingError' unless error.is_a?(FormattingError)

        add(
          :invalid_value,
          error.message,
          term_id: term.id,
          group_id: term.group_id,
          path: path || error.details[:path] || term.xpath,
          details: error.details
        )
      end

      def report
        Report.new(profile:, issues: @issues)
      end

      def raise_if_invalid!
        current_report = report
        return current_report if current_report.valid?

        raise ConformanceError.new(
          'Document does not conform to the selected profile',
          profile: profile.id,
          issues: current_report.issues,
          report: current_report
        )
      end

      private

      def observed_value(value, values)
        both_provided = !value.equal?(UNSET) && !values.equal?(UNSET)
        raise ArgumentError, 'provide either value: or values:, not both' if both_provided
        raise ArgumentError, 'provide value: or values:' if value.equal?(UNSET) && values.equal?(UNSET)

        values.equal?(UNSET) ? value : values
      end

      def value_count(value)
        return value.size if value.is_a?(Array)
        return 0 if value.nil?

        1
      end
    end
  end
end
