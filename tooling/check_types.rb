# frozen_string_literal: true

require 'open3'

module TypeSmoke
  module_function

  def binary
    return ENV.fetch('SORBET_BIN') if ENV.key?('SORBET_BIN')

    specification = Gem::Specification.find_by_name('sorbet-static')
    File.join(specification.full_gem_path, 'libexec/sorbet')
  rescue Gem::MissingSpecError
    abort 'Install sorbet-static or set SORBET_BIN to run the type smoke check'
  end

  def check(command, expected_status, *)
    output, status = Open3.capture2e(*command, *)
    abort output unless status.exitstatus == expected_status
  end

  def run
    root = File.expand_path('..', __dir__)
    command = [binary, '--no-config', *Dir[File.join(root, 'gems/*/rbi/*.rbi')],
               File.join(__dir__, 'typecheck/dependencies.rbi')]
    check(command, 0, File.join(__dir__, 'typecheck/usage.rb'))
    check(command, 100, '-e', 'EuEinvoice::Document.build(invoice_number: 123)')
    check(command, 100, '-e', 'EuEinvoice::Document.build { |builder| builder.buyer(name: 123) }')
    check(command, 100, '-e', 'class IncompletePack; include EuEinvoice::Pack; def specifications; []; end; end')
    check(command, 100, '-e', 'class IncompleteAdapter; include EuEinvoice::Adapter; end')
    puts success_message
  end

  def success_message
    [
      'Shipped RBI smoke: valid usage accepted;',
      'invalid constructors, nested builders and incomplete extension ports rejected.'
    ].join(' ')
  end
end

TypeSmoke.run if $PROGRAM_NAME == __FILE__
