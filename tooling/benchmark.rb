# frozen_string_literal: true

require 'json'
require 'digest'

module InvoiceBenchmark
  class Library
    def initialize(mode)
      @baseline = mode == 'baseline'
      if @baseline
        require 'facturx'
        @api = Object.const_get(:Facturx)
      else
        require 'eu_einvoice/fr'
        pack = EuEinvoice::France::Pack.new
        @specification = pack.specification
        @api = EuEinvoice::Client.new(packs: [pack], validation: :structural)
      end
    end

    def read(xml) = @api.read(xml)

    def validate(xml) = @api.validate_xml(xml:)

    def build(document)
      return @api.build_xml(document:, profile: :en16931) if @baseline

      @api.build_xml(document:, specification: @specification).bytes
    end
  end

  module_function

  def measure(iterations, &)
    GC.start
    allocations = GC.stat(:total_allocated_objects)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    iterations.times(&)
    {
      seconds_per_call: (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) / iterations,
      allocations_per_call: (GC.stat(:total_allocated_objects) - allocations).fdiv(iterations)
    }
  end

  def document(base, count)
    lines = Array.new(count) { |index| base.lines.first.with(id: (index + 1).to_s) }
    base.with(lines:)
  end

  def sample(api, base, count)
    invoice = document(base, count)
    xml = api.build(invoice)
    { lines: count, bytes: xml.bytesize,
      build_xml: measure(10) { api.build(invoice) },
      read: measure(10) { api.read(xml) },
      xsd_warm: measure(10) { api.validate(xml) } }
  end

  def run(mode, fixture)
    api = Library.new(mode)
    source = File.binread(fixture)
    cold = measure(1) { raise 'Invalid fixture' if api.validate(source).invalid? }
    base = api.read(source).document
    samples = [1, 100, 500].map { |count| sample(api, base, count) }
    { ruby: RUBY_DESCRIPTION, mode:, fixture_sha256: Digest::SHA256.hexdigest(source),
      iterations: 10, xsd_cold: cold, samples: }
  end
end

if $PROGRAM_NAME == __FILE__
  puts JSON.pretty_generate(InvoiceBenchmark.run(ARGV.fetch(0, 'current'),
                                                 ARGV.fetch(1, 'spec/validation_fr/fixtures/xml/en16931.xml')))
end
