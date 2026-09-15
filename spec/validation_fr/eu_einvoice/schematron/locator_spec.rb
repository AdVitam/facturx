# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'
require 'rbconfig'
require_relative '../../spec_helper'
require 'eu_einvoice/schematron/locator'

RSpec.describe EuEinvoice::Schematron::Locator do
  let(:result) { Struct.new(:stdout, :stderr, :exit_status).new('SaxonC-HE 12.10 from Saxonica', '', 0) }
  let(:runner) { Object.new }
  let(:directory) { Dir.mktmpdir('facturx-saxonc-') }

  before do
    allow(runner).to receive(:call).and_return(result)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  it 'prefers the explicit environment override' do
    binary = executable('custom-transform')
    resolved = locator(env: { 'EU_EINVOICE_SAXONC_TRANSFORM' => binary, 'PATH' => directory }).preflight!

    expect(resolved).to eq(binary)
  end

  it 'probes the resolved executable once' do
    binary = executable('custom-transform')
    candidate = locator(env: { 'EU_EINVOICE_SAXONC_TRANSFORM' => binary })
    2.times { candidate.preflight! }

    expect(runner).to have_received(:call).once.with([binary, '-?'])
  end

  it 'finds Transform on PATH' do
    binary = executable('Transform')

    expect(locator(env: { 'PATH' => directory }).preflight!).to eq(binary)
  end

  it 'rejects a missing executable' do
    error = unavailable_error { locator(env: { 'PATH' => '' }).preflight! }

    expect(error.details[:reason]).to eq(:missing_binary)
  end

  it 'rejects an unsupported SaxonC version' do
    allow(runner).to receive(:call).and_return(Struct.new(:stdout, :stderr, :exit_status).new('SaxonC-HE 12.9', '', 0))
    error = unavailable_error { locator(env: { 'PATH' => directory }).preflight! }

    expect(error.details).to include(reason: :unsupported_version, detected_version: '12.9')
  end

  it 'rejects a failing probe' do
    allow(runner).to receive(:call).and_return(Struct.new(:stdout, :stderr, :exit_status).new('', '', 4))
    error = unavailable_error { locator(env: { 'PATH' => directory }).preflight! }

    expect(error.details[:reason]).to eq(:probe_failed)
  end

  it 'preserves sanitized timeout diagnostics from the probe' do
    allow(runner).to receive(:call).and_raise(timeout_error)
    error = unavailable_error { locator(env: { 'PATH' => directory }).preflight! }

    expect(error.details.dig(:probe_error, :stderr)).to eq('?')
  end

  def locator(env:)
    executable('Transform') unless env['EU_EINVOICE_SAXONC_TRANSFORM'] || env['PATH'].to_s.empty?
    described_class.new(runner:, env:)
  end

  def executable(name)
    path = File.join(directory, name)
    File.write(path, '')
    File.chmod(0o755, path)
    path
  end

  def unavailable_error
    yield
  rescue EuEinvoice::Schematron::UnavailableError => e
    e
  end

  def timeout_error
    runner = EuEinvoice::Subprocess::Runner.new(timeout: 0.2, termination_grace: 0.05)
    runner.call([RbConfig.ruby, '-e', 'STDERR.binmode; STDERR.write("\\xFF".b); sleep 10'])
  rescue EuEinvoice::Subprocess::Error => e
    e
  end
end
