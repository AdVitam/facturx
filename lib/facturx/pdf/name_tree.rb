# frozen_string_literal: true

module Facturx
  module Pdf
    class NameTree
      def initialize(document)
        @document = document
      end

      def call
        names = objects.deref_hash(document.catalog[:Names])
        root = names && names[:EmbeddedFiles]
        root ? collect(root, {}) : []
      end

      private

      attr_reader :document

      def objects
        document.objects
      end

      def collect(reference, visited)
        key = reference_key(reference)
        visit!(visited, key)
        node = objects.deref_hash(reference) || invalid_tree!

        entries(node[:Names]) + children(node).flat_map { |child| collect(child, visited) }
      ensure
        visited.delete(key)
      end

      def entries(reference)
        return [] unless reference

        names = objects.deref_array(reference)
        invalid_tree! unless names&.length&.even?
        names.each_slice(2).map { |tree_name, file_specification| [tree_name, file_specification] }
      end

      def children(node)
        objects.deref_array(node[:Kids]) || []
      end

      def visit!(visited, key)
        invalid_tree!('Embedded files name tree contains a cycle') if visited.key?(key)
        visited[key] = true
      end

      def reference_key(reference)
        reference.is_a?(PDF::Reader::Reference) ? [reference.id, reference.gen] : reference.object_id
      end

      def invalid_tree!(message = 'Embedded files name tree is invalid')
        raise ExtractionError.new(message, reason: :invalid_name_tree)
      end
    end
  end
end
