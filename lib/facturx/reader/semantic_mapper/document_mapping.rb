# frozen_string_literal: true

module Facturx
  class Reader
    class SemanticMapper
      DOCUMENT_REFERENCE_ATTRIBUTES = %i[
        sales_order_reference purchase_order_reference contract_reference receiving_advice_reference
        despatch_advice_reference
      ].freeze
      DOCUMENT_COMPOSITE_ATTRIBUTES = [
        *DOCUMENT_REFERENCE_ATTRIBUTES, :tender_or_lot_reference, :invoiced_object_identifier, :project_reference
      ].freeze

      private

      def document_attributes
        scalar_document_attributes.merge(
          reference_document_attributes,
          tender_or_lot_reference: additional_reference(:tender_or_lot_reference, type_code: '50'),
          invoiced_object_identifier: invoiced_object_identifier,
          project_reference: project_reference
        )
      end

      def scalar_document_attributes
        attributes = [nil, 'BG-2', 'BG-19'].each_with_object({}) do |group_id, result|
          result.merge!(scalar_attributes(:document, group_id, except: DOCUMENT_COMPOSITE_ATTRIBUTES))
        end
        tax_breakdown = first_group('BG-23')
        return attributes unless tax_breakdown

        base = group_xpath('BG-23')
        attributes.merge!(scalar_attributes(:document, 'BG-23', context: tax_breakdown, base_xpath: base))
        attributes.merge(vat_point_date_code: value('BT-8', context: tax_breakdown, base_xpath: base))
      end

      def reference_document_attributes
        DOCUMENT_REFERENCE_ATTRIBUTES.to_h do |attribute|
          [attribute, reference(term_for_attribute(:document, attribute)&.id)]
        end
      end

      def notes
        group_nodes('BG-1').map do |node|
          Note.new(**scalar_attributes(:note, 'BG-1', context: node, base_xpath: group_xpath('BG-1')))
        end
      end

      def preceding_invoices
        group_nodes('BG-3').map do |node|
          base = group_xpath('BG-3')
          DocumentReference.new(**scalar_attributes(:document_reference, 'BG-3', context: node, base_xpath: base))
        end
      end

      def supporting_documents
        group_nodes('BG-24') { |node| supporting_document?(node) }.map do |node|
          base = group_xpath('BG-24')
          SupportingDocument.new(**supporting_document_attributes(node, base))
        end
      end

      def supporting_document_attributes(node, base)
        binary = %i[content mime_code filename]
        attributes = scalar_attributes(:supporting_document, 'BG-24', context: node, base_xpath: base, except: binary)
        attributes.merge!(embedded_document_attributes(node, base)) if node.at_xpath('./ram:AttachmentBinaryObject',
                                                                                     NAMESPACES)
        attributes
      end

      def embedded_document_attributes(node, base)
        scalar_attributes(:supporting_document, 'BG-24', context: node, base_xpath: base,
                                                         only: %i[content mime_code filename])
      end

      def supporting_document?(node)
        technical_value('./ram:TypeCode', node) == '916'
      end

      def additional_reference(attribute, type_code:)
        node = @document.at_xpath("#{group_xpath('BG-24')}[ram:TypeCode='#{type_code}']", NAMESPACES)
        return unless node

        technical_value('./ram:TypeCode', node)
        term = term_for_attribute(:document, attribute)
        reference(term&.id, context: node, base_xpath: group_xpath('BG-24'))
      end

      def invoiced_object_identifier
        node = @document.at_xpath("#{group_xpath('BG-24')}[ram:TypeCode='130']", NAMESPACES)
        return unless node

        technical_value('./ram:TypeCode', node)
        value_term = term_for_attribute(:document, :invoiced_object_identifier, xpath_suffix: '/ram:IssuerAssignedID')
        scheme_term = term_for_attribute(:document, :invoiced_object_identifier, xpath_suffix: '/ram:ReferenceTypeCode')
        identifier(value_term&.id, scheme_term&.id, context: node, base_xpath: group_xpath('BG-24'))
      end

      def project_reference
        node = @document.at_xpath(
          '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/' \
          'ram:ApplicableHeaderTradeAgreement/ram:SpecifiedProcuringProject',
          NAMESPACES
        )
        return unless node

        id = value(term_for_attribute(:document, :project_reference)&.id)
        name = technical_value('./ram:Name', node)
        DocumentReference.new(id:, name:)
      end
    end
  end
end
