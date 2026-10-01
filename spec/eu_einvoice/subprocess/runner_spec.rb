# frozen_string_literal: true

require 'rbconfig'
require 'spec_helper'

RSpec.describe EuEinvoice::Subprocess::Runner, :aggregate_failures do
  it 'writes stdin and applies the working directory' do
    expect(configured_execution.to_h).to eq(expected_result(stdout: "invoice|#{Dir.tmpdir}"))
  end

  it 'returns non-zero exits to the domain adapter' do
    result = described_class.new.call(ruby_command('STDERR.write("failure"); exit(9)'))

    expect(result.to_h).to eq(expected_result(stdout: '', stderr: 'failure', exit_status: 9))
  end

  it 'keeps normal output as raw bytes' do
    result = described_class.new.call(raw_output_command)

    expect(result.to_h).to eq(expected_result(stdout: "\xFF".b, stderr: "\xFE".b))
  end

  it 'bounds captured output and tracks stdout truncation' do
    result = described_class.new(output_limit: 32).call(ruby_command('STDOUT.write("x" * 1_000); STDERR.write("ok")'))

    expect(result.to_h).to eq(expected_result(stdout: truncated_output, stderr: 'ok', stdout_truncated: true))
  end

  it 'sanitizes stderr in timeout errors' do
    error = begin
      described_class.new(timeout: 0.2, termination_grace: 0.05)
                     .call(['/bin/sh', '-c', 'printf "\\377" >&2; sleep 10'])
    rescue EuEinvoice::Subprocess::Error => e
      e
    end

    expect(error.details).to include(reason: :timeout, timeout: 0.2, stderr: '?')
  end

  it 'times out when a descendant retains stdout after its parent exits' do
    error = timeout_error('fork { trap("TERM", "IGNORE"); sleep 10 }; exit!')

    expect(error.details).to include(reason: :timeout)
  end

  it 'times out while writing to a process that does not consume stdin' do
    runner = described_class.new(timeout: 0.2, termination_grace: 0.05)

    expect { runner.call(ruby_command('sleep 10'), input: 'x' * 1_000_000) }
      .to raise_error(EuEinvoice::Subprocess::Error) do |error|
        expect(error.details).to include(reason: :timeout)
      end
  end

  it 'limits diagnostic output independently from result output' do
    result = described_class.new(output_limit: 16, stdout_limit: 100)
                            .call(ruby_command('STDOUT.write("x" * 64); STDERR.write("y" * 64)'))

    expect(result.stdout).to eq('x' * 64)
    expect(result.stderr.bytesize).to eq(16)
    expect(result.stdout_truncated).to be(false)
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

  def raw_output_command
    ruby_command(<<~RUBY)
      STDOUT.binmode
      STDERR.binmode
      STDOUT.write("\\xFF".b)
      STDERR.write("\\xFE".b)
    RUBY
  end

  def expected_result(stdout:, stderr: '', exit_status: 0, stdout_truncated: false)
    { stdout:, stderr:, exit_status:, stdout_truncated: }
  end

  def timeout_error(program)
    described_class.new(timeout: 0.2, termination_grace: 0.05).call(ruby_command(program))
  rescue EuEinvoice::Subprocess::Error => e
    e
  end
end
