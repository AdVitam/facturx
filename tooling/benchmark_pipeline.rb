# frozen_string_literal: true

require_relative 'benchmark'
require_relative 'benchmark_pipeline/memory_sampler'
require_relative 'benchmark_pipeline/fixture'
require_relative 'benchmark_pipeline/engines'
require_relative '../spec/pdf/support/pdf_builder'
require 'eu_einvoice/fr'
require 'eu_einvoice/validation/fr'

module PipelineBenchmark
  class Runner
    ITERATIONS = 3

    def initialize
      @pack = EuEinvoice::France::Pack.new
      @specification = @pack.specification
      @profile = @specification.profile
      @client = EuEinvoice::Client.new(packs: [@pack], validation: :structural)
      @parser = EuEinvoice::Xml::Parser.new
      @schema = EuEinvoice::Xml::SchemaValidator.new(registry: EuEinvoice::Xml::SchemaRegistry.new)
      @schematron = EuEinvoice::Validation::France.validator
      @pdf = Object.new.extend(PdfSupport).build_pdf
      @composer = EuEinvoice::Pdf::Composer.new(embedding: EuEinvoice::France::EMBEDDING)
      @extractor = EuEinvoice::Pdf::Extractor.new(embedding: EuEinvoice::France::EMBEDDING)
    end

    def run
      fixture = Fixture.new(@client)
      results = [1, 100, 500].map { |count| sample(fixture.document(count), count) }
      { ruby: RUBY_DESCRIPTION, platform: RUBY_PLATFORM, fixture: Fixture::PATH,
        fixture_sha256: Digest::SHA256.hexdigest(fixture.source), samples: results, engines: Engines.versions,
        memory_interval_seconds: MemorySampler::INTERVAL,
        note: 'Absolute sampled RSS; descendant sum double-counts shared pages. Sampler is excluded.' }
    end

    private

    def sample(document, count)
      warn "Pipeline benchmark: #{count} lines"
      xml = build(document)
      parsed = @parser.call(xml:)
      stages = xml_stages(document, xml, parsed)
      stages.merge!(pdf_stages(xml))
      { lines: count, xml_bytes: xml.bytesize, xml_sha256: Digest::SHA256.hexdigest(xml), stages:,
        checks: { xsd_valid: true, schematron_valid: true, extracted_xml_exact: true } }
    end

    def xml_stages(document, xml, parsed)
      {
        xml_parse: measure { @parser.call(xml:) },
        xml_write_with_xsd: measure { build(document) },
        xsd_only_warm: measure { @schema.call(document: parsed, profile: @profile) },
        schematron_only: measure(1) { verify_schematron(parsed) }
      }
    end

    def pdf_stages(xml)
      output = nil
      compose = measure(1) { output = @composer.call(pdf: @pdf, xml:, profile: @profile) }
      extract = measure(1) { raise 'Extracted XML differs' unless @extractor.call(output).xml == xml }
      { pdf_compose_with_verification: compose.merge(output_bytes: output.bytesize), pdf_extract: extract }
    end

    def measure(iterations = ITERATIONS, &block)
      MemoryCapture.new.call { InvoiceBenchmark.measure(iterations, &block) }.merge(iterations:)
    end

    def build(document)
      artifact = @client.build_xml(document:, specification: @specification)
      raise 'Writer returned an invalid report' unless artifact.report.valid?

      artifact.bytes
    end

    def verify_schematron(document)
      issues = @schematron.call(document:, profile: @profile)
      errors = issues.reject { |issue| issue.severity == :warning }
      raise "Schematron rejected benchmark document: #{errors.map(&:details)}" unless errors.empty?
    end
  end
end

if $PROGRAM_NAME == __FILE__
  unless File.directory?('/proc/self') && Process.respond_to?(:fork)
    abort 'This benchmark requires Linux /proc and fork'
  end
  puts JSON.pretty_generate(PipelineBenchmark::Runner.new.run)
end
