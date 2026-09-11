# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Facturx::Composers::Ghostscript do
  subject(:composer) do
    described_class.new(
      locator: instance_double(described_class::Locator, available?: true, preflight!: config),
      runner:
    )
  end

  let(:config) do
    described_class::Locator::Config.new(
      binary: '/opt/ghostscript/bin/gs',
      zugferd_ps: '/opt/ghostscript/lib/zugferd.ps',
      icc_profile: '/opt/ghostscript/icc/default_rgb.icc'
    )
  end
  let(:runner) { instance_double(described_class::Runner) }
  let(:profile) { Struct.new(:conformance_level).new('EN 16931') }
  let(:capture) { {} }

  before do
    allow(runner).to receive(:call) do |argv|
      capture_arguments_and_inputs(argv)
      File.binwrite(output_path(argv), '%PDF-A-3 result'.b)
    end
  end

  it 'returns the generated PDF byte string' do
    expect(compose).to eq('%PDF-A-3 result'.b)
  end

  it 'writes the input byte strings without transcoding' do
    compose

    expect(capture.fetch(:inputs)).to eq(pdf: "%PDF-1.7\n\xFF".b, xml: '<xml>é</xml>'.b)
  end

  it 'cleans its temporary directory' do
    compose

    expect(Dir).not_to exist(capture.fetch(:directory))
  end

  it 'requests PDF/A-3 with strict compatibility' do
    compose

    expect(capture.fetch(:arguments)).to include(*described_class::DEVICE_ARGUMENTS)
  end

  it 'passes the Factur-X profile metadata' do
    compose

    expect(capture.fetch(:arguments)).to include(*expected_facturx_arguments)
  end

  it 'uses the expected script and temporary filenames' do
    compose

    expect(captured_filenames).to eq(xml: 'factur-x.xml', input: 'input.pdf', script: 'zugferd.ps')
  end

  it 'grants Ghostscript read access only to the required files' do
    compose

    expect(permitted_files.map { |path| File.basename(path) })
      .to contain_exactly('input.pdf', 'factur-x.xml', 'zugferd.ps', 'default_rgb.icc')
  end

  it 'raises when Ghostscript does not create an output' do
    allow(runner).to receive(:call)

    expect { compose }.to raise_error(Facturx::CompositionError, /non-empty PDF/)
  end

  it 'raises when Ghostscript creates an empty output' do
    allow(runner).to receive(:call) { |argv| File.binwrite(output_path(argv), '') }

    expect { compose }.to raise_error(Facturx::CompositionError, /non-empty PDF/)
  end

  it 'delegates availability checks to the locator' do
    expect(composer).to be_available
  end

  it 'delegates preflight checks to the locator' do
    expect(composer.preflight!).to equal(config)
  end

  def compose
    composer.call(pdf: "%PDF-1.7\n\xFF".b, xml: '<xml>é</xml>'.b, profile:)
  end

  def capture_arguments_and_inputs(argv)
    capture[:arguments] = argv
    capture[:directory] = File.dirname(argv.last)
    capture[:inputs] = { pdf: File.binread(argv.last), xml: File.binread(xml_path(argv)) }
  end

  def output_path(argv)
    argv.fetch(argv.index('-o') + 1)
  end

  def xml_path(argv)
    argv.grep(/^-sZUGFeRDXMLFile=/).fetch(0).delete_prefix('-sZUGFeRDXMLFile=')
  end

  def expected_facturx_arguments
    [
      "-sZUGFeRDProfile=#{config.icc_profile}",
      '-sZUGFeRDVersion=2p1',
      '-sZUGFeRDConformanceLevel=EN 16931'
    ]
  end

  def permitted_files
    argument = capture.fetch(:arguments).grep(/^--permit-file-read=/).fetch(0)
    argument.delete_prefix('--permit-file-read=').split(File::PATH_SEPARATOR)
  end

  def captured_filenames
    arguments = capture.fetch(:arguments)
    {
      xml: File.basename(xml_path(arguments)),
      input: File.basename(arguments.last),
      script: File.basename(arguments[-2])
    }
  end
end
