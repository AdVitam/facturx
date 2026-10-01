# frozen_string_literal: true

require 'digest'

RSpec.describe 'Package integrity' do
  let(:root) { File.expand_path('../..', __dir__) }
  let(:specifications) { Dir[File.join(root, 'gems/*/*.gemspec')].map { |path| Gem::Specification.load(path) } }

  it 'builds exactly six new identities with one release version' do
    expect(specifications.map(&:name)).to contain_exactly(
      'eu-einvoice', 'eu-einvoice-syntax-cii', 'eu-einvoice-container-pdf',
      'eu-einvoice-fr', 'eu-einvoice-validation-fr', 'eu-einvoice-rails'
    )
    expect(specifications.map(&:version).uniq.map(&:to_s)).to eq(['1.0.0'])
  end

  it 'packages runtime files and licenses without development files' do
    specifications.each do |spec|
      expect(spec.files).to include('LICENSE.txt')
      expect(spec.files.grep(%r{\A(?:spec|pkg|vendor)/})).to be_empty
      expect(spec.files.grep(/\.(?:icc|icm|ps)\z/i)).to be_empty
    end
  end

  it 'keeps the central dependency graph independent of adapters and Rails' do
    core = specifications.find { |spec| spec.name == 'eu-einvoice' }
    expect(core.runtime_dependencies.map(&:name)).to match_array(%w[bigdecimal date])
    expect(specifications.flat_map(&:runtime_dependencies).map(&:name)).not_to include('sorbet-runtime', 'facturx')
  end

  it 'checks every vendored schema and rule against its recorded bytes' do
    manifests = Dir[File.join(root, 'gems/**/SHA256SUMS')]
    expect(manifests.size).to eq(2)
    manifests.each do |manifest|
      File.readlines(manifest, chomp: true).reject(&:empty?).each do |line|
        digest, relative = line.split(/\s+/, 2)
        expect(Digest::SHA256.file(File.join(File.dirname(manifest), relative)).hexdigest).to eq(digest)
      end
    end
  end
end
