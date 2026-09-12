# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      class ExchangedDocument < Stage
        term_ids 'BT-1', 'BT-3', 'BT-2', 'BT-22', 'BT-21'

        def call
          node = context.element(context.root, 'rsm:ExchangedDocument')
          emit('BT-1', document.invoice_number, element: 'ram:ID', parent: node)
          emit('BT-3', document.type_code, element: 'ram:TypeCode', parent: node)
          issue_date(node)
          notes(node)
        end

        private

        def notes(parent)
          each_group('BG-1', document.notes, element: 'ram:IncludedNote', parent:) do |note_node, note|
            emit('BT-22', note.content, element: 'ram:Content', parent: note_node)
            emit('BT-21', note.subject_code, element: 'ram:SubjectCode', parent: note_node)
          end
        end

        def issue_date(parent)
          value = document.issue_date
          unless value
            emit('BT-2', nil, element: 'udt:DateTimeString', parent: parent)
            return
          end

          container(parent, 'ram:IssueDateTime') do |node|
            emit('BT-2', value, element: 'udt:DateTimeString', parent: node, attributes: { 'format' => '102' })
          end
        end
      end
    end
  end
end
