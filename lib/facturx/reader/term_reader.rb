# frozen_string_literal: true

require_relative '../coerce'
require_relative '../diagnostic'

module Facturx
  class Reader
    class TermReader
      attr_reader :diagnostics

      def initialize(document:, profile:, registry:, coercer:, diagnostics:)
        @document = document
        @profile = profile
        @registry = registry
        @coercer = coercer
        @diagnostics = diagnostics
        @matched_nodes = {}.compare_by_identity
      end

      def value(id, context: @document, base_xpath: nil, nodes: nil)
        term = active_term(id)
        return unless term

        selected = nodes || context.xpath(relative_xpath(term.xpath, base_xpath), NAMESPACES)
        selected.each { |node| mark(node) }
        cardinality = term.cardinalities.fetch(@profile.id)
        diagnose_cardinality(term, selected, cardinality)
        materialize(term, selected, cardinality)
      end

      def group_nodes(id, context: @document, base_xpath: nil, &)
        group = active_group(id)
        return [].freeze unless group

        nodes = context.xpath(relative_xpath(group.xpath, base_xpath), NAMESPACES).to_a
        nodes.select!(&) if block_given?
        cardinality = group.cardinalities.fetch(@profile.id)
        diagnose_cardinality(group, nodes, cardinality)
        nodes.each { |node| mark(node) }
        nodes.freeze
      end

      def raw_value(xpath, context:, mark_node: true)
        node = context.at_xpath(xpath, NAMESPACES)
        mark(node) if node && mark_node
        node&.text
      end

      def mark(node)
        return unless node

        @matched_nodes[node] = true
      end

      def add(code, term_id, path, message, details = {})
        @diagnostics << Diagnostic.new(
          code:,
          term_id:,
          path:,
          message:,
          details:
        )
      end

      private

      def active_term(id)
        term = @registry.fetch(id)
        term if term.cardinalities.key?(@profile.id)
      end

      def active_group(id)
        group = @registry.group(id)

        group if group.cardinalities.key?(@profile.id)
      rescue KeyError
        raise KeyError, "Unknown Factur-X group: #{id}"
      end

      def diagnose_cardinality(definition, nodes, cardinality)
        missing(definition) if nodes.empty? && required?(cardinality)
        multiple(definition, nodes.size) if nodes.size > 1 && !repeated?(cardinality)
      end

      def materialize(term, nodes, cardinality)
        values = nodes.map { |node| coerce(node, term) }
        return values.freeze if repeated?(cardinality)

        values.first
      end

      def missing(definition)
        add(:missing_required_term, definition.id, definition.xpath, 'Required value is missing')
      end

      def multiple(definition, count)
        add(:multiple_values, definition.id, definition.xpath, 'Multiple values found for a scalar field', count:)
      end

      def relative_xpath(xpath, base_xpath)
        return xpath unless base_xpath

        suffix = xpath.delete_prefix(base_xpath)
        raise ArgumentError, "#{xpath} is outside #{base_xpath}" if suffix == xpath

        suffix.empty? ? '.' : ".#{suffix}"
      end

      def required?(cardinality) = cardinality.start_with?('1')

      def repeated?(cardinality) = cardinality.end_with?('n')
    end
  end
end

require_relative 'term_reader/unmapped'
require_relative 'term_reader/coercion'
