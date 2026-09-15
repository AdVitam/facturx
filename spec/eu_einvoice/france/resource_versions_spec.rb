# frozen_string_literal: true

require 'spec_helper'
require 'digest'

RSpec.describe 'Specification resource isolation', :aggregate_failures do
  let(:root) { File.expand_path('spec/fixtures/version_isolation') }
  let(:alpha) { specification('alpha') }
  let(:beta) { specification('beta') }
  let(:adapter) { build_adapter(:structural) }

  it 'runs distinct schemas for identical guideline identifiers without cache contamination' do
    reports = [[alpha, 'alpha'], [beta, 'alpha'], [beta, 'beta'], [alpha, 'beta']].map do |spec, variant|
      adapter.validate_xml(xml: xml(variant), specification: spec)
    end
    expect(reports.map(&:valid?)).to eq([true, false, true, false])
    expect(reports.map(&:specification)).to eq([alpha, beta, beta, alpha])
  end

  it 'isolates concurrent validation operations sharing the compiled-schema cache' do
    threads = [alpha, beta].map do |spec|
      Thread.new { Array.new(3) { adapter.validate_xml(xml: xml(spec.version), specification: spec).valid? } }
    end
    expect(threads.flat_map(&:value)).to all(be(true))
  end

  it 'runs distinct rules and adjacent code lists through real SaxonC', :saxonc do
    full = build_adapter(:full)
    reports = [alpha, beta].map { |spec| full.validate_xml(xml: xml(spec.version), specification: spec) }
    expect(reports.map { |report| report.issues.first.details[:rule_id] }).to eq(%w[SYNTHETIC-ALPHA SYNTHETIC-BETA])
    expect(reports).to all(be_complete)
    expect(reports.map(&:resources).uniq.size).to eq(2)
  end

  def build_adapter(validation)
    EuEinvoice::France::Adapter.new(specifications: [alpha, beta], validation:, schema_root: root, rules_root: root)
  end

  def specification(version)
    base = EuEinvoice::France::Pack.new.specification(profile: :minimum)
    manifest = base.manifest.merge(
      resources: checksums(version, ['invoice.xsd']), schema_entrypoint: "#{version}/invoice.xsd",
      optional_resources: checksums(version, %w[rules.xslt codes.xml]), rule_entrypoint: "#{version}/rules.xslt",
      code_list_entrypoint: "#{version}/codes.xml", code_lists: checksums(version, ['codes.xml']),
      source: 'Synthetic contract fixture', official_source: nil, artifact_version: version
    )
    base.with(id: "synthetic/#{version}", version:, manifest:)
  end

  def checksums(version, files)
    files.to_h { |file| ["#{version}/#{file}", Digest::SHA256.file(File.join(root, version, file)).hexdigest] }
  end

  def xml(version)
    document = Nokogiri::XML(File.binread('spec/fixtures/xml/minimum.xml'))
    document.root['synthetic-version'] = version
    document.to_xml
  end
end
