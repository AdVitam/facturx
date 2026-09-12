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
          emit_identifier_scheme(node, identifier, value, options)
          node
        end

        def emit_party_identifiers(parent, identifiers, value_id, scheme_id)
          items = Array(identifiers)
          return unless observe?(value_id, items.map(&:value))

          local, global = items.partition { |item| item.scheme_id.nil? }
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

        def emit_identifier_scheme(node, identifier, value, options)
          scheme_id = options[:scheme_id]
          return unless scheme_id

          emit_attribute(
            scheme_id,
            identifier&.scheme_id,
            node:,
            attribute: options.fetch(:scheme_attribute, 'schemeID'),
            group_present: !value.nil?
          )
        end

        def emit_local_identifiers(parent, identifiers, value_id)
          identifiers.each do |item|
            technical(parent, 'ram:ID', format_identifier_value(value_id, item.value))
          end
        end

        def emit_global_identifiers(parent, identifiers, value_id, scheme_id)
          nodes = identifiers.map do |item|
            technical(parent, 'ram:GlobalID', format_identifier_value(value_id, item.value))
          end
          schemes = identifiers.map(&:scheme_id)
          return unless observe?(scheme_id, schemes, group_present: !identifiers.empty?)

          nodes.zip(schemes).each { |node, scheme| assign_scheme(node, scheme_id, scheme) }
        end

        def assign_scheme(node, scheme_id, scheme)
          formatted = format_identifier_value(scheme_id, scheme)
          node['schemeID'] = formatted if node && formatted
        end
      end
    end
  end
end
