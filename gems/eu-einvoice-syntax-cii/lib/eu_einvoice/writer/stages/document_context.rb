# frozen_string_literal: true

module EuEinvoice
  class Writer
    module Stages
      class DocumentContext < Stage
        term_ids 'BT-23', 'BT-24'

        def call
          within_group('BG-2', document, element: 'rsm:ExchangedDocumentContext', parent: context.root,
                                         represented_attributes: [:vat_point_date_code]) do |node,|
            emit_context_parameter(node, 'BT-23', document.business_process,
                                   'ram:BusinessProcessSpecifiedDocumentContextParameter')
            guideline = document.guideline_urn || profile.guideline_urn
            emit_context_parameter(node, 'BT-24', guideline, 'ram:GuidelineSpecifiedDocumentContextParameter')
          end
        end

        private

        def emit_context_parameter(parent, id, value, element)
          if value
            container(parent, element) { |node| emit(id, value, element: 'ram:ID', parent: node) }
          else
            emit(id, nil, element: 'ram:ID', parent: parent)
          end
        end
      end
    end
  end
end
