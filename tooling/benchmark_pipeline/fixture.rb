# frozen_string_literal: true

module PipelineBenchmark
  class Fixture
    PATH = 'spec/validation_fr/fixtures/xml/en16931.xml'

    attr_reader :source, :base

    def initialize(client)
      @source = File.binread(PATH)
      reading = client.read(source)
      raise 'Benchmark source contains unmapped data' unless reading.diagnostics.empty?

      @base = reading.document
      raise 'Benchmark requires a one-line invoice' unless base.lines.one?
    end

    def document(count)
      lines = Array.new(count) { |index| base.lines.first.with(id: (index + 1).to_s) }
      base.with(lines:, tax_breakdowns: taxes(count), totals: totals(count))
    end

    private

    def totals(count)
      values = base.totals.to_h.transform_values { |value| value && (value * count) }
      base.totals.with(**values)
    end

    def taxes(count)
      base.tax_breakdowns.map do |tax|
        tax.with(basis_amount: tax.basis_amount * count, tax_amount: tax.tax_amount * count)
      end
    end
  end
end
