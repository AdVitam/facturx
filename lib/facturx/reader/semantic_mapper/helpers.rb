# frozen_string_literal: true

module Facturx
  class Reader
    class SemanticMapper
      private

      def reference(id, context: @document, base_xpath: nil, field: :id)
        item = value(id, context:, base_xpath:)
        DocumentReference.new(**{ field => item }) if item
      end

      def identifier(value_id, scheme_id = nil, context: @document, base_xpath: nil)
        return unless value_id

        item = value(value_id, context:, base_xpath:)
        return unless item

        scheme = value(scheme_id, context:, base_xpath:) if scheme_id
        Identifier.new(value: item, scheme_id: scheme)
      end

      def quantity(value_id, unit_id, context:, base_xpath:)
        amount = value(value_id, context:, base_xpath:)
        return unless amount

        unit = value(unit_id, context:, base_xpath:)
        Quantity.new(value: amount, unit_code: unit)
      end

      def tax_registration(attribute, scheme_id, node, base, group_id)
        term = term_for(:party, group_id, attribute)
        return unless term

        nodes = node.xpath("./ram:SpecifiedTaxRegistration/ram:ID[@schemeID='#{scheme_id}']", NAMESPACES)
        item = value(term.id, context: node, base_xpath: base, nodes:)
        Identifier.new(value: item, scheme_id:) if item
      end

      def read_price_allowance_indicator(node, base)
        allowance = node.at_xpath('./ram:AppliedTradeAllowanceCharge', NAMESPACES)
        return unless allowance

        indicator = allowance.at_xpath('./ram:ChargeIndicator', NAMESPACES)
        @terms.mark(indicator)
        allowance_base = "#{base}/ram:AppliedTradeAllowanceCharge"
        value('BT-147-02', context: allowance, base_xpath: allowance_base)
      end

      def technical_value(xpath, context)
        @terms.raw_value(xpath, context:)
      end

      def technical_boolean(xpath, context, term_id:, required: false, missing_path: xpath)
        @terms.coerced_value(xpath, context:, type: :boolean, term_id:, required:, missing_path:)
      end

      def value(id, context: @document, base_group: nil, base_xpath: nil, nodes: nil)
        return unless id

        @terms.value(id, context:, base_xpath: base_xpath || (base_group && group_xpath(base_group)), nodes:)
      end

      def scalar_value(id, **)
        Array(value(id, **)).first
      end

      def scalar_attributes(model, group_id, context: @document, base_xpath: nil, **selection)
        only = selection[:only]
        except = selection.fetch(:except, [])
        model_terms(model, group_id)
          .group_by(&:attribute)
          .select { |attribute, terms| terms.one? && selected_attribute?(attribute, only, except) }
          .to_h { |attribute, terms| [attribute, value(terms.first.id, context:, base_xpath:)] }
      end

      def selected_attribute?(attribute, only, except)
        (only.nil? || only.include?(attribute)) && !except.include?(attribute)
      end

      def model_terms(model, group_id)
        @terms_by_model_and_group.fetch([model, group_id], EMPTY_TERMS)
      end

      def term_for(model, group_id, attribute, xpath_suffix: nil)
        terms = model_terms(model, group_id).select { |term| term.attribute == attribute }
        terms.find { |term| xpath_suffix.nil? || term.xpath.end_with?(xpath_suffix) }
      end

      def term_for_attribute(model, attribute, xpath_suffix: nil)
        terms = @terms_by_model_and_attribute.fetch([model, attribute], EMPTY_TERMS)
        terms.find { |term| xpath_suffix.nil? || term.xpath.end_with?(xpath_suffix) }
      end

      def group_nodes(id, **, &)
        @terms.group_nodes(id, **, &)
      end

      def first_group(id, **)
        group_nodes(id, **).first
      end

      def group_xpath(id)
        @registry.group(id).xpath
      end
    end
  end
end
