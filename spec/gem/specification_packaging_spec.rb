# frozen_string_literal: true

require 'digest'

RSpec.describe Gem::Specification do
  subject(:specification) do
    Dir.chdir(root) { described_class.load('facturx.gemspec') }
  end

  let(:root) { File.expand_path('../..', __dir__) }
  let(:files) { specification.files }
  let(:schema_root) { File.join(root, 'lib/facturx/schema') }
  let(:checksums) do
    File.readlines(File.join(schema_root, 'SHA256SUMS'), chomp: true).to_h do |line|
      digest, path = line.split(/\s+/, 2)
      [path, digest]
    end
  end

  it 'packages every runtime file and required notice' do
    runtime_files = Dir.chdir(root) do
      Dir['lib/**/*'].select { |path| File.file?(path) }
    end

    expect(files).to include(*runtime_files, 'DOCUMENTATION.md', 'LICENSE.txt', 'NOTICE.md', 'README.md')
  end

  it 'packages every RBI file' do
    rbi_files = Dir.chdir(root) do
      Dir['rbi/**/*'].select { |path| File.file?(path) }
    end

    expect(files).to include('rbi/facturx.rbi', *rbi_files)
  end

  it 'packages every schema referenced by a profile' do
    profile_schemas = Facturx::Profiles.all.map { |profile| profile.xsd_path.delete_prefix("#{root}/") }

    expect(files).to include(*profile_schemas)
  end

  it 'lists every bundled schema in the checksum manifest' do
    schemas = Dir.chdir(schema_root) { Dir['**/*.xsd'] }

    expect(checksums.keys).to match_array(schemas)
  end

  it 'keeps valid checksums for the bundled schemas' do
    actual = checksums.to_h do |path, _digest|
      [path, Digest::SHA256.file(File.join(schema_root, path)).hexdigest]
    end

    expect(actual).to eq(checksums)
  end

  it 'does not distribute Ghostscript assets' do
    expect(files.grep(/\.(?:icc|icm|ps)\z/i)).to be_empty
  end

  it 'does not distribute development files' do
    development_files = files.grep(%r{\A(?:spec|coverage|pkg)/}) + (files & %w[AGENTS.md Gemfile.lock])

    expect(development_files).to be_empty
  end

  it 'does not add Sorbet as a runtime dependency' do
    expect(specification.runtime_dependencies.map(&:name)).not_to include('sorbet-runtime')
  end
end
