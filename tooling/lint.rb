# frozen_string_literal: true

require 'open3'
require 'English'

module ProjectLint
  module_function

  def files(staged:)
    if staged
      output, status = Open3.capture2('git', 'diff', '--cached', '--name-only', '--diff-filter=ACMR', '-z')
      abort 'Cannot list staged files' unless status.success?

      output.split("\0").select { |file| File.file?(file) && file.end_with?('.rb', '.gemspec') }
    else
      Dir['gems/**/*.{rb,gemspec}', 'tooling/**/*.rb', 'rakelib/**/*.{rb,rake}', 'spec/**/*.rb'] + %w[Gemfile Rakefile]
    end
  end

  def run(staged: false, autocorrect: false)
    tests, production = files(staged:).partition { |path| path.start_with?('spec/') }
    command = %w[bundle exec rubocop]
    command << '-A' if autocorrect
    lint_tests(command, tests)
    success = production.empty? || system(*command, *production)
    system('git', 'add', '--', *files(staged: true), exception: true) if staged && autocorrect && success
    success
  end

  def lint_tests(command, tests)
    return if tests.empty?

    system(*command, *tests)
    abort 'Test lint could not execute' unless [0, 1].include?($CHILD_STATUS.exitstatus)
  end
end

exit(ProjectLint.run(staged: ARGV.include?('--staged'), autocorrect: ARGV.include?('--autocorrect')) ? 0 : 1)
