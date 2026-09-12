# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Facturx::Terms do
  subject(:registry) { described_class }

  let(:namespaces) do
    {
      'qdt' => 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100',
      'ram' => 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100',
      'rsm' => 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100',
      'udt' => 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100'
    }
  end
  let(:empty_cii_xml) do
    Nokogiri::XML(
      '<rsm:CrossIndustryInvoice xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"/>'
    )
  end

  it 'contains the complete EN16931 intersection and its groups' do
    expect(
      [registry.all.size, registry.groups.size, registry.all.map(&:id).uniq.size, registry.groups.map(&:id).uniq.size]
    ).to eq([184, 41, 184, 41])
  end

  it 'contains the expected number of terms per profile' do
    counts = %i[minimum basic_wl basic en16931 extended].map { |profile| registry.for_profile(profile).size }
    expect(counts).to eq([22, 113, 140, 184, 184])
  end

  it 'contains each lower profile as a strict EN16931 subset' do
    differences = [%i[minimum basic_wl], %i[basic_wl basic], %i[basic en16931]].map do |subset, superset|
      registry.for_profile(subset) - registry.for_profile(superset)
    end
    expect(differences).to all(be_empty)
  end

  it 'returns shared empty indexes for unknown profiles' do
    expect([registry.for_profile(:unknown).equal?(described_class::EMPTY_TERMS),
            registry.groups_for_profile(:unknown).equal?(described_class::EMPTY_GROUPS)]).to eq([true, true])
  end

  it 'uses immutable profile and group indexes' do
    expect([described_class.for_profile(:en16931), described_class.groups_for_profile(:en16931),
            described_class.group('BG-23')]).to eq(index_entries)
  end

  it 'uses compilable namespace-aware XPath expressions' do
    expect do
      (registry.all + registry.groups).each { |entry| empty_cii_xml.xpath(entry.xpath, namespaces) }
    end.not_to raise_error
  end

  it 'targets existing immutable model attributes' do
    expect(invalid_terms + invalid_groups).to be_empty
  end

  it 'freezes all declarations and cardinality maps' do
    declarations = [registry.all, registry.groups, (registry.all + registry.groups).map(&:cardinalities)]
    expect(declarations).to all(all(be_frozen))
  end

  def model_for(name)
    Facturx.const_get(name.to_s.split('_').map(&:capitalize).join)
  end

  def index_entries
    [described_class::TERMS_BY_PROFILE[:en16931], described_class::GROUPS_BY_PROFILE[:en16931],
     described_class::GROUPS_BY_ID['BG-23']]
  end

  def invalid_terms
    registry.all.reject { |term| model_for(term.model).members.include?(term.attribute) }
  end

  def invalid_groups
    registry.groups.filter_map do |group|
      next unless group.attribute

      parent = registry.groups.find { |candidate| candidate.id == group.parent_id }
      owner = parent ? model_for(parent.model) : Facturx::Document
      group unless owner.members.include?(group.attribute)
    end
  end
end
