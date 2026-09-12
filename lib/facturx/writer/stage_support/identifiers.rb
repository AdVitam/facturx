# frozen_string_literal: true

module Facturx
  class Writer
    module StageSupport
      module Identifiers
        private

        def emit_compound_identifier(parent, identifier, **options)
          value_id = options.fetch(:value_id)
          value = identifier&.value
          node = emit(value_id, value, element: options.fetch(:element), parent:).first
          emit_identifier_scheme(node, identifier, options)
          node
        end

        def emit_party_identifiers(parent, identifiers, value_id, scheme_id)
          items = Array(identifiers)
          local, global = items.partition { |item| item.scheme_id.nil? }
          missing, global = global.partition { |item| item.value.to_s.strip.empty? }
          emit_global_identifiers(parent, missing, value_id, scheme_id)

          return unless observe?(value_id, items.map(&:value))

          emit_local_identifiers(parent, local, value_id)
          emit_global_identifiers(parent, global, value_id, scheme_id)
        end

        def format_identifier_value(id, value)
          return if value.nil?

          format(value, Terms.fetch(id))
        end

        def emit_tax_registration(parent, id, identifier, scheme)
          value = identifier&.value
          unless value
            observe?(id, nil)
            return
          end

          container(parent, 'ram:SpecifiedTaxRegistration') do |node|
            emit(id, value, element: 'ram:ID', parent: node, attributes: { 'schemeID' => scheme })
          end
        end

        def emit_document_reference(parent, id, reference, element, represented_attributes: [])
          unless reference
            observe?(id, nil)
            return
          end

          represented = [:id, *represented_attributes]
          report_unrepresentable_reference_attributes(id, reference, represented_attributes: represented)

          container(parent, element) do |node|
            emit(id, reference.id, element: 'ram:IssuerAssignedID', parent: node)
          end
        end

        def report_unrepresentable_reference_attributes(id, reference, represented_attributes: [])
          %i[id line_id name issue_date].each do |attribute|
            next unless reference.public_send(attribute) && !represented_attributes.include?(attribute)

            unrepresentable(id, "Document reference #{attribute} cannot be represented")
          end
        end

        def emit_identifier_scheme(node, identifier, options)
          scheme_id = options[:scheme_id]
          return unless scheme_id

          emit_attribute(
            scheme_id,
            identifier&.scheme_id,
            node:,
            attribute: options.fetch(:scheme_attribute, 'schemeID'),
            group_present: !node.nil?
          )
        end

        def emit_local_identifiers(parent, identifiers, value_id)
          identifiers.each do |item|
            technical(parent, 'ram:ID', format_identifier_value(value_id, item.value))
          end
        end

        def emit_global_identifiers(parent, identifiers, value_id, scheme_id)
          identifiers.each do |item|
            if item.value.to_s.strip.empty?
              unrepresentable(value_id, 'Global identifier requires a value')
              next
            end

            node = technical(parent, 'ram:GlobalID', format_identifier_value(value_id, item.value))
            emit_attribute(scheme_id, item.scheme_id, node:, attribute: 'schemeID', group_present: true)
          end
        end
      end
    end
  end
end
