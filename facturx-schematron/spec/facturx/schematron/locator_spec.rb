# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'
require_relative '../../spec_helper'
require 'facturx/schematron/locator'

RSpec.describe Facturx::Schematron::Locator do
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
    config = locator(env: { 'FACTURX_SAXONC_TRANSFORM' => binary, 'PATH' => directory }).preflight!

    expect(config).to have_attributes(binary:, version: Gem::Version.new('12.10'))
  end

  it 'probes the resolved executable once' do
    binary = executable('custom-transform')
    candidate = locator(env: { 'FACTURX_SAXONC_TRANSFORM' => binary })
    2.times { candidate.preflight! }

    expect(runner).to have_received(:call).once.with([binary, '-?'])
  end

  it 'finds Transform on PATH' do
    binary = executable('Transform')

    expect(locator(env: { 'PATH' => directory }).preflight!.binary).to eq(binary)
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

  def locator(env:)
    executable('Transform') unless env['FACTURX_SAXONC_TRANSFORM'] || env['PATH'].to_s.empty?
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
  rescue Facturx::Schematron::UnavailableError => e
    e
  end
end
