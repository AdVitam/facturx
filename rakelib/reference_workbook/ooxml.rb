# frozen_string_literal: true

require 'nokogiri'

module Facturx
  class ReferenceWorkbook
    class Ooxml
      XML_NAMESPACE = { 'x' => 'http://schemas.openxmlformats.org/spreadsheetml/2006/main' }.freeze
      DOCUMENT_RELATIONSHIP = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
      PACKAGE_RELATIONSHIPS = { 'r' => 'http://schemas.openxmlformats.org/package/2006/relationships' }.freeze
      Sheet = Data.define(:name, :rows)

      def initialize(archive:, path:)
        @archive = archive
        @path = path
      end

      def sheets
        strings = shared_strings
        workbook_sheets.map do |name, path|
          Sheet.new(name:, rows: read_rows(entry(path), strings))
        end
      end

      private

      def shared_strings
        item = @archive.find_entry('xl/sharedStrings.xml')
        return [] unless item

        document = Nokogiri::XML(item.get_input_stream.read)
        document.xpath('//x:si', XML_NAMESPACE).map do |node|
          node.xpath('.//x:t', XML_NAMESPACE).map(&:text).join
        end
      end

      def workbook_sheets
        document = Nokogiri::XML(entry('xl/workbook.xml').get_input_stream.read)
        relationships = workbook_relationships
        document.xpath('//x:sheets/x:sheet', XML_NAMESPACE).map do |node|
          relationship = node.attribute_with_ns('id', DOCUMENT_RELATIONSHIP).value
          [node['name'], relationship_path(relationships.fetch(relationship))]
        end
      end

      def workbook_relationships
        document = Nokogiri::XML(entry('xl/_rels/workbook.xml.rels').get_input_stream.read)
        document.xpath('//r:Relationship', PACKAGE_RELATIONSHIPS).to_h do |node|
          [node['Id'], node['Target']]
        end
      end

      def relationship_path(target)
        path = target.delete_prefix('/')
        path = "xl/#{path}" unless path.start_with?('xl/')
        File.expand_path(path, '/').delete_prefix('/')
      end

      def read_rows(item, strings)
        document = Nokogiri::XML(item.get_input_stream.read)
        document.xpath('//x:sheetData/x:row', XML_NAMESPACE).map do |row|
          row.xpath('./x:c', XML_NAMESPACE).to_h do |cell|
            [column_index(cell['r']), cell_value(cell, strings)]
          end
        end
      end

      def cell_value(cell, strings)
        value = raw_cell_value(cell)
        value = shared_string(value, strings) if cell['t'] == 's' && value
        value&.strip&.gsub(/\s+/, ' ')
      end

      def raw_cell_value(cell)
        return cell.xpath('.//x:is/x:t', XML_NAMESPACE).map(&:text).join if cell['t'] == 'inlineStr'

        cell.at_xpath('./x:v', XML_NAMESPACE)&.text
      end

      def shared_string(value, strings)
        strings.fetch(Integer(value, 10))
      end

      def column_index(reference)
        reference[/\A[A-Z]+/].each_byte.reduce(0) { |index, byte| (index * 26) + byte - 64 } - 1
      end

      def entry(path)
        @archive.find_entry(path) || raise("Missing #{path} in #{@path}")
      end
    end
  end
end
