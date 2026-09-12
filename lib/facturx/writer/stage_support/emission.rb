# frozen_string_literal: true

module Facturx
  class Writer
    module StageSupport
      module Emission
        private

        def emit(id, value, **options)
          term = Terms.fetch(id)
          values = present_values(value)
          return [] unless options.fetch(:group_present, true)

          accepted = tracker.observe_term?(term, values:, path: term.xpath)
          return [] unless accepted

          values.filter_map { |item| emit_value(term, item, options) }
        end

        def emit_attribute(id, value, **options)
          term = Terms.fetch(id)
          values = present_values(value)
          group_present = options.fetch(:group_present, !options.fetch(:node).nil?)
          return unless group_present

          accepted = tracker.observe_term?(term, values:, path: term.xpath)
          return unless accepted

          emit_attribute_value(term, values, options)
        end

        def observe?(id, value, group_present: true)
          return false unless group_present

          term = Terms.fetch(id)
          tracker.observe_term?(term, values: present_values(value), path: term.xpath)
        end

        def unrepresentable(id, message)
          term = Terms.fetch(id)
          tracker.invalid_term(term, error: FormattingError.new(message, path: term.xpath), path: term.xpath)
        end

        def present_values(value)
          (value.is_a?(Array) ? value : [value]).compact
        end

        def format(value, term)
          Format.call(value, term:)
        rescue FormattingError => e
          tracker.invalid_term(term, error: e, path: term.xpath)
          nil
        end

        def emit_value(term, value, options)
          formatted = format(value, term)
          return unless formatted

          context.element(
            options.fetch(:parent),
            options.fetch(:element),
            text: formatted,
            attributes: options.fetch(:attributes, {})
          )
        end

        def emit_attribute_value(term, values, options)
          node = options.fetch(:node)
          return unless node && values.one?

          formatted = format(values.first, term)
          node[options.fetch(:attribute)] = formatted if formatted
        end
      end
    end
  end
end
