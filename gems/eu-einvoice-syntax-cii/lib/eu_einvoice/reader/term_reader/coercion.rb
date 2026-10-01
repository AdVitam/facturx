# frozen_string_literal: true

module EuEinvoice
  class Reader
    class TermReader
      def coerced_value(xpath, context:, type:, term_id: nil, **options)
        node = context.at_xpath(xpath, NAMESPACES)
        return diagnose_raw_missing(options.fetch(:missing_path, xpath), term_id) if node.nil? && options[:required]
        return unless node

        coerce_raw_value(node, type:, term_id:)
      rescue CoercionError => e
        add(:invalid_value, term_id, node.path, e.message, e.details)
        nil
      end

      private

      def coerce_raw_value(node, type:, term_id:)
        mark(node)
        return diagnose_raw_empty(node, term_id) if node.text.strip.empty?

        @coercer.call(node.text, type:, term_id:, path: node.path)
      end

      def coerce_term_value(node, term)
        @coercer.call(node.text, type: term.type, scale: term.scale, term_id: term.id, path: node.path)
      end

      def coerce(node, term)
        return diagnose_date_format(node, term) if invalid_date_format?(node, term)
        return diagnose_empty(node, term) if node.text.strip.empty?

        coerce_term_value(node, term)
      rescue CoercionError => e
        add(:invalid_value, term.id, node.path, e.message, e.details)
        nil
      end

      def diagnose_empty(node, term)
        add(:empty_value, term.id, node.path, 'Value is empty', value: node.text)
        nil
      end

      def diagnose_raw_empty(node, term_id)
        add(:empty_value, term_id, node.path, 'Value is empty', value: node.text)
        nil
      end

      def diagnose_raw_missing(path, term_id)
        add(:missing_required_term, term_id, path, 'Required value is missing')
        nil
      end

      def invalid_date_format?(node, term)
        return false unless term.type == :date_102

        format = node.attribute('format')
        mark(format)
        format&.value != '102'
      end

      def diagnose_date_format(node, term)
        add(:invalid_value, term.id, node.path, 'Date format must be 102', format: node['format'])
        nil
      end
    end
  end
end
