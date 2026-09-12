# frozen_string_literal: true

module Facturx
  class Writer
    module StageSupport
      module Structure
        private

        def within_group(id, value, element:, parent:)
          group = Terms.group(id)
          values = present_values(value)
          accepted = tracker.observe_group(group, count: values.size, path: group.xpath)
          return unless accepted

          values.each do |item|
            node = context.element(parent, element)
            yield(node, item)
            remove_if_empty(node)
          end
        end

        def each_group(id, values, element:, parent:, &)
          within_group(id, Array(values), element:, parent:, &)
        end

        def technical(parent, element, value, attributes: {})
          return if value.nil?

          text = value.to_s
          return if text.strip.empty?

          context.element(parent, element, text:, attributes:)
        end

        def container(parent, element)
          node = context.element(parent, element)
          yield node
          remove_if_empty(node)
          node
        end

        def remove_if_empty(node)
          node.remove if node.element_children.empty? && node.text.empty? && node.attribute_nodes.empty?
        end
      end
    end
  end
end
