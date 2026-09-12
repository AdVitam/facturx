# frozen_string_literal: true

module Facturx
  class Writer
    module StageSupport
      module Structure
        private

        def within_group(id, value, element:, parent:, represented_attributes: [])
          group = Terms.group(id)
          values = present_values(value)
          accepted = tracker.observe_group?(group, count: values.size, path: group.xpath)
          return unless accepted

          values.each do |item|
            report_unrepresentable_attributes(group.id, item, represented_attributes:)
            node = context.element(parent, element)
            yield(node, item)
            remove_if_empty(node)
          end
        end

        def each_group(id, values, element:, parent:, represented_attributes: [], &)
          within_group(id, Array(values), element:, parent:, represented_attributes:, &)
        end

        def technical(parent, element, value, default: nil)
          text = value.to_s
          text = default.to_s if text.strip.empty?
          return if text.strip.empty?

          context.element(parent, element, text:)
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

        def report_unrepresentable_attributes(group_id, item, model: model_for(item), represented_attributes: [])
          return unless item.is_a?(Data) && model_for(item) == model

          group = Terms.group(group_id)
          item.members.each do |attribute|
            value = item.public_send(attribute)
            next if value.nil? || (value.respond_to?(:empty?) && value.empty?) || represented_attributes.include?(attribute)
            next if attribute_supported_in_group?(group, model, attribute)

            tracker.unrepresentable_attribute(group, model:, attribute:)
          end
        end

        def report_unrepresentable_attribute(group_id, model:, attribute:)
          tracker.unrepresentable_attribute(Terms.group(group_id), model:, attribute:)
        end

        def attribute_supported_in_group?(group, model, attribute)
          return true if group.model == :document && document_attribute?(model, attribute)

          Terms.all.any? { |term| term.group_id == group.id && term.model == model && term.attribute == attribute } ||
            group.parent_id && Terms.all.any? do |term|
              term.group_id == group.parent_id && term.model == model && term.attribute == attribute
            end ||
            Terms.groups.any? do |candidate|
              candidate.parent_id == group.id && candidate.attribute == attribute
            end ||
            Terms.groups.any? do |candidate|
              candidate.parent_id == group.parent_id && candidate.attribute == attribute
            end
        end

        def document_attribute?(model, attribute)
          model == :document && (Terms.all.any? { |term| term.model == model && term.attribute == attribute } ||
            Terms.groups.any? { |candidate| candidate.attribute == attribute })
        end

        def model_for(item)
          item.class.name.split('::').last.gsub(/([a-z\\d])([A-Z])/, '\\1_\\2').downcase.to_sym
        end
      end
    end
  end
end
