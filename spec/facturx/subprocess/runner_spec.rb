# frozen_string_literal: true

require 'rbconfig'
require 'spec_helper'

RSpec.describe Facturx::Subprocess::Runner do
  it 'writes stdin and applies the working directory' do
    expect(configured_execution.to_h).to eq(expected_result(stdout: "invoice|#{Dir.tmpdir}"))
  end

  it 'returns non-zero exits to the domain adapter' do
    result = described_class.new.call(ruby_command('STDERR.write("failure"); exit(9)'))

    expect(result.to_h).to eq(expected_result(stdout: '', stderr: 'failure', exit_status: 9))
  end

  it 'bounds captured output and tracks truncation per stream' do
    result = described_class.new(output_limit: 32).call(ruby_command('STDOUT.write("x" * 1_000); STDERR.write("ok")'))

    expect(result.to_h).to eq(expected_result(stdout: truncated_output, stderr: 'ok', stdout_truncated: true))
  end

  it 'tracks stderr truncation separately' do
    result = described_class.new(output_limit: 32).call(ruby_command('STDOUT.write("ok"); STDERR.write("x" * 1_000)'))

    expect(result.to_h).to eq(expected_result(stdout: 'ok', stderr: truncated_output, stderr_truncated: true))
  end

  it 'terminates processes that exceed the timeout', :aggregate_failures do
    runner = described_class.new(timeout: 0.05, termination_grace: 0.05)

    expect { runner.call(ruby_command('sleep 10')) }
      .to raise_error(Facturx::Subprocess::Error) do |error|
        expect(error.details).to include(reason: :timeout, timeout: 0.05)
      end
  end

  def configured_execution
    command = ruby_command('STDOUT.write([STDIN.read, Dir.pwd].join("|"))')
    described_class.new.call(command, input: 'invoice', chdir: Dir.tmpdir)
  end

  def ruby_command(program)
    [RbConfig.ruby, '-e', program]
  end

  def truncated_output
    "#{'x' * 18}...[truncated]"
  end

  def expected_result(stdout:, stderr: '', exit_status: 0, stdout_truncated: false, stderr_truncated: false)
    { stdout:, stderr:, exit_status:, stdout_truncated:, stderr_truncated: }
  end
end
