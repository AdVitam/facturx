# frozen_string_literal: true

require_relative '../../spec_helper'
require 'facturx/schematron/registry'

RSpec.describe Facturx::Schematron::Registry do
  subject(:registry) { described_class.new }

  Facturx::Profiles.all.each do |profile|
    it "resolves readable artifacts for the #{profile.id} profile" do
      rule_set = registry.fetch(profile)

      expect(rule_set).to satisfy do |candidate|
        [candidate.stylesheet, candidate.code_db].all? { |path| File.file?(path) && File.readable?(path) } &&
          File.dirname(candidate.stylesheet) == candidate.directory
      end
    end
  end

  it 'caches the immutable rule set for each profile' do
    profile = Facturx::Profiles.fetch(:minimum)

    expect(registry.fetch(profile)).to equal(registry.fetch(profile))
  end

  it 'raises a typed error for an unregistered profile' do
    profile = Facturx::Profile.new(id: :custom, guideline_urn: 'urn:custom', conformance_level: 'CUSTOM')
    error = rule_pack_error { registry.fetch(profile) }

    expect(error.details[:reason]).to eq(:unknown_profile)
  end

  def rule_pack_error
    yield
  rescue Facturx::Schematron::RulePackError => e
    e
  end
end
