# frozen_string_literal: true

require_relative '../../spec_helper'
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
    allow(locator).to receive(:preflight!).and_return(Struct.new(:binary).new('/usr/bin/Transform'))
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

  it 'caches the engine configuration' do
    validator.preflight!
    validator.call(document:, profile:)

    expect(locator).to have_received(:preflight!).once
  end

  it 'raises a typed execution error on nonzero exit' do
    allow(runner).to receive(:call).and_return(process_result(stderr: "failure\xFF".b, exit_status: 7))
    error = execution_error { validator.call(document:, profile:) }

    expect(error.details).to include(reason: :nonzero_exit, profile: :minimum, exit_status: 7, stderr: 'failure?')
  end

  it 'wraps subprocess failures without leaking internal errors' do
    allow(runner).to receive(:call).and_raise(subprocess_error)
    error = execution_error { validator.call(document:, profile:) }

    expect(error.details).to eq(reason: :timeout, subprocess_error: { reason: :timeout, timeout: 2 })
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

  def process_result(stdout: '<svrl/>', stderr: '', exit_status: 0)
    Struct.new(:stdout, :stderr, :exit_status).new(stdout, stderr, exit_status)
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

  def execution_error
    yield
  rescue Facturx::Schematron::ExecutionError => e
    e
  end

  def subprocess_error
    Facturx.const_get(:Subprocess).const_get(:Error).new('Timed out', reason: :timeout, timeout: 2)
  end
end
