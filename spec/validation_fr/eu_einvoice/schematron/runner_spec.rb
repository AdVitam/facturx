# frozen_string_literal: true

require_relative '../../spec_helper'
require 'eu_einvoice/schematron/runner'

RSpec.describe EuEinvoice::Schematron::Runner, :aggregate_failures do
  it 'applies the configured timeout to real child processes' do
    runner = described_class.new(limits: EuEinvoice::ResourceLimits.new(process_timeout: 0.05))
    expect { runner.call([Gem.ruby, '-e', 'sleep 5']) }.to raise_error(EuEinvoice::Subprocess::Error) do |error|
      expect(error.details[:reason]).to eq(:timeout)
    end
  end

  it 'applies the memory budget and keeps diagnostic stderr independently bounded' do
    limit = 512 * 1024 * 1024
    runner = described_class.new(limits: EuEinvoice::ResourceLimits.new(process_memory_bytes: limit))
    result = runner.call([Gem.ruby, '-e', 'puts Process.getrlimit(:AS).first; warn "x" * 9000'])
    expect(result.stdout.to_i).to eq(limit)
    expect(result.stderr.bytesize).to eq(8192)
  end
end
