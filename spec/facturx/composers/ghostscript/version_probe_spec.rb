# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Facturx::Composers::Ghostscript::VersionProbe do
  subject(:probe) { described_class.new(runner:) }

  let(:runner) { instance_double(Facturx::Composers::Ghostscript::Runner) }

  it 'executes the version command as a shell-free argument vector' do
    allow(runner).to receive(:call).and_return(result('10.06.0'))
    probe.call('/path with spaces/gs')

    expect(runner).to have_received(:call).with(['/path with spaces/gs', '--version'])
  end

  it 'accepts the minimum supported version' do
    allow(runner).to receive(:call).and_return(result('9.54.0'))

    expect(probe.call('/gs')).to eq(Gem::Version.new('9.54.0'))
  end

  it 'rejects an absent version' do
    allow(runner).to receive(:call).and_return(result("\n"))

    expect(probe_error.details).to eq(reason: :missing_version)
  end

  it 'rejects a malformed version' do
    allow(runner).to receive(:call).and_return(result('Ghostscript development build'))

    expect(probe_error.details).to eq(reason: :invalid_version)
  end

  it 'rejects versions older than 9.54' do
    allow(runner).to receive(:call).and_return(result('9.53.3'))

    expect(probe_error.details).to eq(unsupported_version_details)
  end

  it 'wraps execution failures as an unavailable version' do
    failure = Facturx::CompositionError.new('failed', stderr: 'bounded diagnostic')
    allow(runner).to receive(:call).and_raise(failure)

    expect(probe_error.details).to eq(reason: :version_unavailable, probe_error: failure.details)
  end

  def result(stdout)
    Facturx::Subprocess::Result.new(
      stdout:, stderr: '', exit_status: 0, stdout_truncated: false, stderr_truncated: false
    )
  end

  def unsupported_version_details
    { reason: :unsupported_version, detected_version: '9.53.3', minimum_version: '9.54' }
  end

  def probe_error
    probe.call('/gs')
    raise 'Expected version probing to fail'
  rescue Facturx::ComposerUnavailableError => e
    e
  end
end
