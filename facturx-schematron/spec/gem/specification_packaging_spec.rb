# frozen_string_literal: true

require 'digest'

RSpec.describe Gem::Specification do
  subject(:specification) do
    Dir.chdir(root) { described_class.load('facturx-schematron.gemspec') }
  end

  let(:root) { File.expand_path('../..', __dir__) }
  let(:files) { specification.files }
  let(:rules_root) { File.join(root, 'lib/facturx/schematron/rules') }
  let(:checksums) do
    File.readlines(File.join(rules_root, 'SHA256SUMS'), chomp: true).to_h do |line|
      digest, path = line.split(/\s+/, 2)
      [path, digest]
    end
  end

  it 'uses the core version' do
    expect(specification.version.to_s).to eq(Facturx::VERSION)
  end

  it 'depends on the core gem' do
    expect(specification.runtime_dependencies.map(&:name)).to contain_exactly('facturx')
  end

  it 'requires the exact matching core release' do
    dependency = specification.runtime_dependencies.find { |candidate| candidate.name == 'facturx' }

    expect(dependency.requirement.requirements).to eq([['=', Gem::Version.new(Facturx::VERSION)]])
  end

  it 'packages every runtime file and required notice' do
    runtime_files = Dir.chdir(root) do
      Dir['lib/**/*'].select { |path| File.file?(path) }
    end

    expect(files).to include(*runtime_files, 'LICENSE.txt', 'NOTICE.md')
  end

  it 'packages the companion RBI' do
    expect(files).to include('rbi/facturx-schematron.rbi')
  end

  it 'packages one compiled rule set per profile' do
    artifacts = Dir.chdir(rules_root) { Dir['1.09.2/**/*'].select { |path| File.file?(path) } }

    expect(artifacts.grep(/\.xslt\z/).size).to eq(5)
  end

  it 'packages one code database per profile' do
    artifacts = Dir.chdir(rules_root) { Dir['1.09.2/**/*'].select { |path| File.file?(path) } }

    expect(artifacts.grep(/_codedb\.xml\z/).size).to eq(5)
  end

  it 'does not package source Schematron or unrelated schemas' do
    artifacts = Dir.chdir(rules_root) { Dir['1.09.2/**/*'].select { |path| File.file?(path) } }

    expect(artifacts.grep(/\.(?:sch|xsd|xlsx)\z/i)).to be_empty
  end

  it 'lists every bundled rule artifact in the checksum manifest' do
    artifacts = Dir.chdir(rules_root) { Dir['1.09.2/**/*'].select { |path| File.file?(path) } }

    expect(checksums.keys).to match_array(artifacts)
  end

  it 'keeps valid checksums for the bundled rule artifacts' do
    actual = checksums.to_h do |path, _digest|
      [path, Digest::SHA256.file(File.join(rules_root, path)).hexdigest]
    end

    expect(actual).to eq(checksums)
  end

  it 'does not distribute development files' do
    development_files = files.grep(%r{\A(?:spec|coverage|pkg)/}) + (files & %w[AGENTS.md Gemfile.lock])

    expect(development_files).to be_empty
  end
end
