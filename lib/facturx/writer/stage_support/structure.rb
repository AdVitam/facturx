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
            next unless unrepresentable_attribute?(group, model, attribute, value, represented_attributes)

            tracker.unrepresentable_attribute(group, model:, attribute:)
          end
        end

        def report_unrepresentable_attribute(group_id, model:, attribute:)
          tracker.unrepresentable_attribute(Terms.group(group_id), model:, attribute:)
        end

        def attribute_supported_in_group?(group, model, attribute)
          return true if group.model == :document && document_attribute?(model, attribute)

          supported_term?(group, model, attribute) || supported_child_group?(group, attribute)
        end

        def unrepresentable_attribute?(group, model, attribute, value, represented_attributes)
          populated?(value) && !represented_attributes.include?(attribute) &&
            !attribute_supported_in_group?(group, model, attribute)
        end

        def populated?(value)
          !value.nil? && (!value.respond_to?(:empty?) || !value.empty?)
        end

        def supported_term?(group, model, attribute)
          group_ids(group).any? do |group_id|
            Terms.all.any? { |term| term.group_id == group_id && term.model == model && term.attribute == attribute }
          end
        end

        def supported_child_group?(group, attribute)
          group_ids(group).any? do |group_id|
            Terms.groups.any? { |candidate| candidate.parent_id == group_id && candidate.attribute == attribute }
          end
        end

        def group_ids(group)
          [group.id, group.parent_id].compact
        end

        def document_attribute?(model, attribute)
          model == :document && (document_term?(attribute) || document_group?(attribute))
        end

        def document_term?(attribute)
          Terms.all.any? { |term| term.model == :document && term.attribute == attribute }
        end

        def document_group?(attribute)
          Terms.groups.any? { |candidate| candidate.attribute == attribute }
        end

        def model_for(item)
          item.class.name.split('::').last.gsub(/([a-z\\d])([A-Z])/, '\\1_\\2').downcase.to_sym
        end
      end
    end
  end
end
