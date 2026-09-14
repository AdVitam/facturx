# frozen_string_literal: true

require 'rbconfig'
require 'spec_helper'

RSpec.describe Facturx::Subprocess::Runner do
  it 'writes stdin and applies the working directory and environment' do
    expect(configured_execution.to_h).to eq(
      stdout: "invoice|#{Dir.tmpdir}|configured",
      stderr: '',
      exit_status: 0
    )
  end

  it 'returns non-zero exits to the domain adapter' do
    result = described_class.new.call(ruby_command('STDERR.write("failure"); exit(9)'))

    expect(result.to_h).to eq(stdout: '', stderr: 'failure', exit_status: 9)
  end

  it 'bounds captured output' do
    result = described_class.new(output_limit: 32).call(ruby_command('STDOUT.write("x" * 1_000)'))

    expect(result.stdout).to have_attributes(bytesize: 32).and end_with('...[truncated]')
  end

  it 'terminates processes that exceed the timeout', :aggregate_failures do
    runner = described_class.new(timeout: 0.05, termination_grace: 0.05)

    expect { runner.call(ruby_command('sleep 10')) }
      .to raise_error(Facturx::Subprocess::Error) do |error|
        expect(error.details).to include(reason: :timeout, timeout: 0.05)
      end
  end

  def configured_execution
    command = ruby_command('STDOUT.write([STDIN.read, Dir.pwd, ENV.fetch("VALUE")].join("|"))')
    described_class.new.call(command, input: 'invoice', chdir: Dir.tmpdir, env: { 'VALUE' => 'configured' })
  end

  def ruby_command(program)
    [RbConfig.ruby, '-e', program]
  end
end
