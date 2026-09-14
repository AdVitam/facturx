# frozen_string_literal: true

require_relative '../../spec_helper'
require 'rbconfig'
require 'facturx/schematron/validator'

RSpec.describe Facturx::Schematron::Validator do
  subject(:validator) do
    described_class.new(**dependencies)
  end

  let(:dependencies) do
    {
      runner: Object.new,
      locator: Object.new,
      registry: Object.new,
      parser: Object.new
    }
  end
  let(:profile) { Facturx::Profiles.fetch(:minimum) }
  let(:document) do
    Nokogiri::XML::Document.parse('<!DOCTYPE invoice><invoice><id>42</id></invoice>')
  end
  let(:issues) do
    [Facturx::Validation::Issue.new(code: :schematron_violation, message: 'Invalid', layer: :schematron)]
  end

  before do
    allow(locator).to receive(:preflight!).and_return('/usr/bin/Transform')
    allow(registry).to receive(:fetch).with(profile).and_return(rule_set)
    allow(runner).to receive(:call).and_return(process_result)
    allow(parser).to receive(:call).with(svrl: '<svrl/>').and_return(issues)
  end

  it 'returns the parsed issues' do
    expect(validator.call(document:, profile:)).to eq(issues)
  end

  it 'executes the selected stylesheet with root XML on stdin' do
    validator.call(document:, profile:)

    expect(runner).to have_received(:call).once.with(
      expected_arguments, input: safe_invoice_xml, chdir: rule_set.directory
    )
  end

  it 'returns itself after preflight' do
    expect(validator.preflight!).to equal(validator)
  end

  it 'delegates repeated preflights to the locator' do
    2.times { validator.preflight! }

    expect(locator).to have_received(:preflight!).twice
  end

  it 'serializes non-UTF-8 XML as UTF-8 for SaxonC' do
    validator.call(document: iso_8859_1_document, profile:)

    expect(runner).to have_received(:call).once.with(
      expected_arguments, input: valid_utf8_invoice, chdir: rule_set.directory
    )
  end

  it 'raises a typed execution error on nonzero exit' do
    allow(runner).to receive(:call).and_return(process_result(stderr: "failure\xFF".b, exit_status: 7))
    error = execution_error { validator.call(document:, profile:) }

    expect(error.details).to include(reason: :nonzero_exit, profile: :minimum, exit_status: 7, stderr: 'failure?')
  end

  it 'raises a typed error when validation output is truncated' do
    allow(runner).to receive(:call).and_return(process_result(stdout_truncated: true))
    error = execution_error { validator.call(document:, profile:) }

    expect(error.details).to include(reason: :output_limit, stream: :stdout)
  end

  it 'wraps subprocess failures without leaking internal errors' do
    allow(runner).to receive(:call).and_raise(subprocess_error)
    error = execution_error { validator.call(document:, profile:) }

    expect(error.details).to eq(reason: :timeout, subprocess_error: { reason: :timeout, timeout: 0.2, stderr: '?' })
  end

  def runner = dependencies.fetch(:runner)
  def locator = dependencies.fetch(:locator)
  def registry = dependencies.fetch(:registry)
  def parser = dependencies.fetch(:parser)

  def rule_set
    directory = '/rules/minimum'
    Struct.new(:directory, :stylesheet, :code_db).new(
      directory,
      File.join(directory, 'FACTUR-X_MINIMUM.xslt'),
      File.join(directory, 'FACTUR-X_MINIMUM_codedb.xml')
    )
  end

  def process_result(stdout: '<svrl/>', stderr: '', exit_status: 0, stdout_truncated: false)
    Struct.new(:stdout, :stderr, :exit_status, :stdout_truncated).new(stdout, stderr, exit_status, stdout_truncated)
  end

  def expected_arguments
    [
      '/usr/bin/Transform', '-s:-', '-dtd:off', '-expand:off', '-ext:off', '-xi:off',
      '-warnings:silent', '-versionmsg:off', '-xsl:FACTUR-X_MINIMUM.xslt'
    ]
  end

  def safe_invoice_xml
    satisfy do |input|
      parsed = Nokogiri::XML::Document.parse(input)
      parsed.at_xpath('/invoice/id')&.text == '42' && !input.include?('<!DOCTYPE')
    end
  end

  def iso_8859_1_document
    xml = "<?xml version='1.0' encoding='ISO-8859-1'?><invoice><id>é</id></invoice>"
    Nokogiri::XML::Document.parse(xml.encode(Encoding::ISO_8859_1))
  end

  def valid_utf8_invoice
    satisfy do |input|
      input.encoding == Encoding::UTF_8 && input.valid_encoding? && invoice_id(input) == 'é'
    end
  end

  def invoice_id(xml)
    Nokogiri::XML::Document.parse(xml).at_xpath('/invoice/id')&.text
  end

  def execution_error
    yield
  rescue Facturx::Schematron::ExecutionError => e
    e
  end

  def subprocess_error
    runner = Facturx::Subprocess::Runner.new(timeout: 0.2, termination_grace: 0.05)
    runner.call([RbConfig.ruby, '-e', 'STDERR.binmode; STDERR.write("\\xFF".b); sleep 10'])
  rescue Facturx::Subprocess::Error => e
    e
  end
end
