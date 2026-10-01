# frozen_string_literal: true

require 'fileutils'
require 'spec_helper'

RSpec.describe EuEinvoice::Composers::Ghostscript::Locator do
  let(:directory) { Dir.mktmpdir }
  let(:version_probe) do
    instance_double(EuEinvoice::Composers::Ghostscript::VersionProbe, call: Gem::Version.new('10.0'))
  end
  let(:missing_locator) do
    described_class.new(
      binary: '/missing/gs',
      zugferd_ps: '/missing/zugferd.ps',
      icc_profile: '/missing/default_rgb.icc',
      env: { 'PATH' => '' },
      candidates: { zugferd_ps: [], icc_profile: [] }
    )
  end

  after { FileUtils.remove_entry(directory) }

  it 'prefers explicit overrides over environment configuration' do
    overrides = resources('override')
    locator = build_locator(overrides, env: environment(resources('env')))

    expect(locator.preflight!.to_h).to eq(overrides)
  end

  it 'uses environment configuration before auto-detection' do
    configured = resources('configured')
    locator = build_locator(env: environment(configured))

    expect(locator.preflight!.to_h).to eq(configured)
  end

  it 'auto-detects the executable and resource files' do
    detected = resources('auto', binary_name: 'gs')
    locator = auto_detecting_locator(detected)

    expect(locator.preflight!.to_h).to eq(detected)
  end

  it 'is unavailable when any resource is missing' do
    expect(missing_locator).not_to be_available
  end

  it 'retries discovery after an unavailable preflight' do
    paths = missing_resources
    locator = build_locator(env: environment(paths))
    locator.available?
    create_resources(paths)

    expect(locator).to be_available
  end

  it 'reports every missing or unusable resource' do
    error = unavailable_error(missing_locator)

    expect(error.details.fetch(:missing)).to contain_exactly(:binary, :zugferd_ps, :icc_profile)
  end

  def build_locator(overrides = {}, env: {}, candidates: {})
    described_class.new(**overrides, version_probe:, env:, candidates:)
  end

  def auto_detecting_locator(detected)
    build_locator(
      env: { 'PATH' => directory },
      candidates: { zugferd_ps: [detected[:zugferd_ps]], icc_profile: [detected[:icc_profile]] }
    )
  end

  def resources(prefix, binary_name: "#{prefix}-gs")
    {
      binary: executable(binary_name),
      zugferd_ps: file("#{prefix}-zugferd.ps"),
      icc_profile: file("#{prefix}-default_rgb.icc")
    }
  end

  def missing_resources
    {
      binary: File.join(directory, 'later-gs'),
      zugferd_ps: File.join(directory, 'later-zugferd.ps'),
      icc_profile: File.join(directory, 'later-default_rgb.icc')
    }
  end

  def create_resources(paths)
    File.binwrite(paths.fetch(:binary), 'fixture')
    File.chmod(0o755, paths.fetch(:binary))
    File.binwrite(paths.fetch(:zugferd_ps), 'fixture')
    File.binwrite(paths.fetch(:icc_profile), 'fixture')
  end

  def environment(resources)
    {
      'EU_EINVOICE_GHOSTSCRIPT' => resources.fetch(:binary),
      'EU_EINVOICE_ZUGFERD_PS' => resources.fetch(:zugferd_ps),
      'EU_EINVOICE_RGB_ICC_PROFILE' => resources.fetch(:icc_profile),
      'PATH' => ''
    }
  end

  def executable(name)
    path = file(name)
    File.chmod(0o755, path)
    path
  end

  def file(name)
    File.join(directory, name).tap { |path| File.binwrite(path, 'fixture') }
  end

  def unavailable_error(locator)
    locator.preflight!
  rescue EuEinvoice::ComposerUnavailableError => e
    e
  end
end
