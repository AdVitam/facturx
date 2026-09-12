# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      module TradeAgreementSupport
        module References
          private

          def write_references(parent)
            document_references(parent)
            additional_references(parent)
            project(parent)
          end

          def document_references(parent)
            reference(parent, 'BT-14', document.sales_order_reference, 'ram:SellerOrderReferencedDocument')
            reference(parent, 'BT-13', document.purchase_order_reference, 'ram:BuyerOrderReferencedDocument')
            reference(parent, 'BT-12', document.contract_reference, 'ram:ContractReferencedDocument')
          end

          def reference(parent, id, value, element)
            unless value
              observe?(id, nil)
              return
            end

            container(parent, element) { |node| emit(id, value.id, element: 'ram:IssuerAssignedID', parent: node) }
          end

          def additional_references(parent)
            typed_reference(parent, 'BT-17', document.tender_or_lot_reference, '50')
            invoiced_object_reference(parent)
            each_group('BG-24', document.supporting_documents, element: 'ram:AdditionalReferencedDocument',
                                                               parent:) do |node, item|
              write_supporting_document(node, item)
            end
          end

          def write_supporting_document(node, item)
            emit('BT-122', item.reference, element: 'ram:IssuerAssignedID', parent: node)
            emit('BT-124', item.external_location, element: 'ram:URIID', parent: node)
            technical(node, 'ram:TypeCode', '916')
            emit('BT-123', item.description, element: 'ram:Name', parent: node)
            attachment(node, item)
          end

          def typed_reference(parent, id, value, type_code)
            unless value
              observe?(id, nil)
              return
            end

            container(parent, 'ram:AdditionalReferencedDocument') do |node|
              emit(id, value.id, element: 'ram:IssuerAssignedID', parent: node)
              technical(node, 'ram:TypeCode', type_code)
            end
          end

          def invoiced_object_reference(parent)
            item = document.invoiced_object_identifier
            return observe_missing_invoiced_object? unless item

            container(parent, 'ram:AdditionalReferencedDocument') do |node|
              emit('BT-18', item.value, element: 'ram:IssuerAssignedID', parent: node)
              technical(node, 'ram:TypeCode', '130')
              emit('BT-18-1', item.scheme_id, element: 'ram:ReferenceTypeCode', parent: node)
            end
          end

          def observe_missing_invoiced_object?
            observe?('BT-18', nil)
            observe?('BT-18-1', nil, group_present: false)
            nil
          end

          def attachment(parent, item)
            node = emit('BT-125', item.content, element: 'ram:AttachmentBinaryObject', parent:).first
            present = !item.content.nil?
            emit_attribute('BT-125-1', item.mime_code, node:, attribute: 'mimeCode', group_present: present)
            emit_attribute('BT-125-2', item.filename, node:, attribute: 'filename', group_present: present)
          end

          def project(parent)
            value = document.project_reference
            unless value && (value.id || value.name)
              observe?('BT-11', nil)
              return
            end

            return unrepresentable('BT-11', 'Project reference requires an identifier') unless value.id

            container(parent, 'ram:SpecifiedProcuringProject') do |node|
              emit('BT-11', value.id, element: 'ram:ID', parent: node)
              technical(node, 'ram:Name', value.name || value.id)
            end
          end
        end
      end
    end
  end
end
