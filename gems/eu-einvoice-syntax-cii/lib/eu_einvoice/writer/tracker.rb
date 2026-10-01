# frozen_string_literal: true

require 'eu_einvoice/error'
require 'eu_einvoice/validation'
require 'eu_einvoice/writer/document_version'

module EuEinvoice
  class Writer
    class Tracker
      include DocumentVersion

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
        check_semantic_version(document)
        check_guideline(document.guideline_urn, path:)
      end

      def observe_group?(group, count:, path: nil)
        definition_observed?(group, count, path)
      end

      def observe_term?(term, values:, path: nil)
        definition_observed?(term, values.size, path)
      end

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

      def unrepresentable_attribute(group, model:, attribute:, path: nil)
        add(
          :unrepresentable_attribute,
          'Model attribute cannot be represented in this group',
          group_id: group.id,
          path: path || group.xpath,
          details: { model:, attribute: }
        )
      end

      def report
        Validation::Report.new(profile:, issues: @issues, executed_steps: [:document])
      end

      private

      def definition_observed?(definition, count, path)
        cardinality = profile.cardinality(definition)
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
        @issues << Validation::Issue.new(code:, message:, layer: :document, **context)
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
    end
  end
end
