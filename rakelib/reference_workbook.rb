# frozen_string_literal: true

require 'zip'
require_relative 'reference_workbook/ooxml'

module Facturx
  class ReferenceWorkbook
    TERM_ID_PATTERN = /\ABT-\d+(?:-\d+)*\z/
    CARDINALITY_PATTERN = /\A[01]\.\.(?:1|n)\z/i
    CARDINALITY_HEADER = /\AEN16931 Cardinality\z/i
    Candidate = Data.define(:name, :entries)

    def initialize(path:, term_ids:)
      @path = path
      @term_ids = term_ids.to_h { |term_id| [term_id, true] }.freeze
    end

    def cardinalities
      candidates = Zip::File.open(@path) do |archive|
        Ooxml.new(archive:, path: @path).sheets.filter_map { |sheet| analyze_sheet(sheet) }
      end
      raise "No Factur-X semantic term table found in #{@path}" if candidates.empty?

      select_candidate(candidates).entries.freeze
    end

    private

    def analyze_sheet(sheet)
      id_column = term_id_column(sheet.rows)
      return unless id_column

      first_term = sheet.rows.index { |row| term_id?(row[id_column]) }
      cardinality_column = cardinality_column(sheet.rows.take(first_term), id_column)
      return unless cardinality_column

      entries = entries(sheet.rows, id_column, cardinality_column, sheet.name)
      Candidate.new(name: sheet.name, entries:) unless entries.empty?
    end

    def term_id_column(rows)
      counts = rows.each_with_object(Hash.new(0)) do |row, result|
        row.each { |column, value| result[column] += 1 if term_id?(value) }
      end
      counts.max_by { |column, count| [count, -column] }&.first
    end

    def cardinality_column(header_rows, id_column)
      columns = header_rows.flat_map do |row|
        row.filter_map { |column, value| column if CARDINALITY_HEADER.match?(value.to_s) }
      end.uniq
      columns.min_by { |column| [(column - id_column).abs, column] }
    end

    def entries(rows, id_column, cardinality_column, sheet_name)
      rows.each_with_object({}) do |row, result|
        register_entry(result, row[id_column], row[cardinality_column], sheet_name)
      end
    end

    def register_entry(entries, term_id, cardinality, sheet_name)
      return unless term_id?(term_id) && @term_ids.key?(term_id)

      normalized = cardinality&.downcase
      unless CARDINALITY_PATTERN.match?(normalized.to_s)
        raise "Missing cardinality for #{term_id} in sheet #{sheet_name.inspect} of #{@path}"
      end

      existing = entries[term_id]
      if existing && existing != normalized
        raise "Conflicting cardinalities for #{term_id} in sheet #{sheet_name.inspect} of #{@path}"
      end

      entries[term_id] = normalized
    end

    def select_candidate(candidates)
      largest_size = candidates.map { |candidate| candidate.entries.size }.max
      largest = candidates.select { |candidate| candidate.entries.size == largest_size }
      return largest.first if largest.map(&:entries).uniq.one?

      names = largest.map(&:name).join(', ')
      raise "Ambiguous Factur-X semantic term tables in #{@path}: #{names}"
    end

    def term_id?(value)
      TERM_ID_PATTERN.match?(value.to_s)
    end
  end
end
