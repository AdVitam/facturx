# frozen_string_literal: true

require 'rbconfig'
require 'spec_helper'

RSpec.describe EuEinvoice::Composers::Ghostscript::Runner do
  it 'executes an argument vector without a shell' do
    argument = '$(this-must-not-run) with spaces'
    result = described_class.new.call(ruby_command('STDOUT.write(ARGV.fetch(0))', argument))

    expect(result.to_h).to eq(
      stdout: argument, stderr: '', exit_status: 0, stdout_truncated: false
    )
  end

  it 'captures a bounded and sanitized stderr when the process fails' do
    runner = described_class.new(output_limit: 64)
    error = composition_error { runner.call(failing_command) }

    expect(error.details).to include(exit_status: 7, stderr: valid_bounded_stderr)
  end

  it 'normalizes a signal termination into an exit status' do
    error = composition_error { described_class.new.call(ruby_command('Process.kill(:TERM, Process.pid)')) }

    expect(error.details).to include(exit_status: 143)
  end

  it 'terminates a process which exceeds the timeout' do
    runner = described_class.new(timeout: 0.05, termination_grace: 0.05)
    error = composition_error { runner.call(ruby_command('sleep 10')) }

    expect(error.details).to include(timeout: 0.05)
  end

  it 'wraps process startup failures' do
    expect { described_class.new.call(['/missing/facturx-ghostscript']) }
      .to raise_error(EuEinvoice::CompositionError, /could not be executed/)
  end

  def ruby_command(program, *arguments)
    [RbConfig.ruby, '-e', program, *arguments]
  end

  def failing_command
    ruby_command('STDERR.binmode; STDERR.write("\\xFF".b * 1_000); exit(7)')
  end

  def composition_error
    yield
    raise 'Expected composition to fail'
  rescue EuEinvoice::CompositionError => e
    e
  end

  def valid_bounded_stderr
    satisfy do |stderr|
      stderr.bytesize <= 64 && stderr.end_with?('...[truncated]') && stderr.valid_encoding?
    end
  end
end
