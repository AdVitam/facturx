# frozen_string_literal: true

require 'spec_helper'
require 'facturx/validation'
require 'facturx/document'
require 'facturx/format'
require 'facturx/group'
require 'facturx/profile'
require 'facturx/term'

RSpec.describe Facturx::Validation, :aggregate_failures do
  let(:profile) do
    Facturx::Profile.new(id: :en16931, guideline_urn: 'urn:example:en16931', conformance_level: 'EN 16931')
  end
  let(:tracker) { FacturxSpec::ValidationTracker.new(profile:) }

  describe Facturx::Validation::Issue do
    it 'deep-copies and freezes all mutable input' do
      details = { nested: [+'value'] }
      issue = described_class.new(code: :invalid_value, message: +'Invalid', layer: :document, details:)
      details[:nested].first.replace('changed')

      expect([issue.message.frozen?, issue.details, issue.details.frozen?])
        .to eq([true, { nested: ['value'] }, true])
    end

    it 'rejects unknown severity values' do
      expect do
        described_class.new(code: :invalid_value, message: 'Invalid', layer: :document, severity: :erroor)
      end.to raise_error(ArgumentError, 'Unknown validation severity: :erroor')
    end
  end

  describe Facturx::Validation::Report do
    it 'owns an immutable issue snapshot and exposes validity predicates' do
      issues = []
      report = described_class.new(profile:, issues:)
      issues << :late

      expect([report.issues, report.issues.frozen?, report.valid?, report.invalid?]).to eq([[], true, true, false])
    end

    it 'supports a report without a resolved profile' do
      report = described_class.new(issues: [Facturx::Validation::Issue.new(
        code: :invalid_xml, message: 'Invalid XML', layer: :syntax
      )])

      expect(report).to have_attributes(profile: nil, invalid?: true)
    end

    it 'ignores non-error issues when determining validity' do
      issue = Facturx::Validation::Issue.new(
        code: :unmapped_term, message: 'Unmapped term', layer: :document, severity: :warning
      )

      expect(described_class.new(profile:, issues: [issue])).to have_attributes(valid?: true, invalid?: false)
    end
  end

  describe FacturxSpec::ValidationTracker do
    it 'accepts a nil or matching document guideline' do
      document = Facturx::Document.new(guideline_urn: profile.guideline_urn)

      expect([tracker.check_guideline(nil), tracker.check_document(document), tracker.report.valid?])
        .to eq([nil, nil, true])
    end

    it 'reports a profile mismatch' do
      tracker.check_guideline('urn:example:minimum', path: '/guideline')

      expect(issue_attributes(tracker.report.issues.first)).to include(
        code: :profile_mismatch, layer: :document, severity: :error, term_id: 'BT-24', path: '/guideline',
        details: { expected: profile.guideline_urn, actual: 'urn:example:minimum' }
      )
    end

    it 'aggregates missing and forbidden terms' do
      results = [tracker.observe_term?(required_term, values: []),
                 tracker.observe_term?(optional_term, values: []),
                 tracker.observe_term?(forbidden_term, values: ['forbidden'])]

      expect([*results, tracker.report.issues.map(&:code)])
        .to eq([false, false, false, %i[missing_required_term forbidden_term]])
    end

    it 'reports scalar cardinality while keeping present values emit-able' do
      results = [tracker.observe_term?(required_term, values: %w[first second]),
                 tracker.observe_group?(required_group, count: 2)]

      expect([*results, tracker.report.issues.map(&:code)])
        .to eq([true, true, %i[invalid_cardinality invalid_cardinality]])
    end

    it 'aggregates missing and forbidden groups' do
      results = [tracker.observe_group?(required_group, count: 0),
                 tracker.observe_group?(optional_group, count: 0),
                 tracker.observe_group?(forbidden_group, count: 1)]

      expect([*results, tracker.report.issues.map(&:code)])
        .to eq([false, false, false, %i[missing_required_group forbidden_group]])
    end

    it 'reports missing and forbidden groups independently' do
      results = [tracker.observe_group?(required_group, count: 0),
                 tracker.observe_group?(forbidden_group, count: 1)]

      expect([*results, tracker.report.issues.map(&:code)])
        .to eq([false, false, %i[missing_required_group forbidden_group]])
    end

    it 'turns formatting failures into invalid-value issues' do
      tracker.invalid_term(required_term, error: formatting_error(required_term), path: '/invoice/id')

      expect(issue_attributes(tracker.report.issues.first)).to include(
        code: :invalid_value, term_id: 'BT-1', group_id: 'BG-0', path: '/invoice/id'
      )
    end
  end

  def term(id, cardinality)
    FacturxSpec::Term.new(
      id, :document, :invoice_number, 'BG-0', '/ram:ID', :date_102, nil,
      cardinality ? { en16931: cardinality }.freeze : {}.freeze
    )
  end

  def required_term = term('BT-1', '1..1')

  def optional_term = term('BT-2', '0..1')

  def forbidden_term = term('BT-3', nil)

  def group(id, cardinality)
    FacturxSpec::Group.new(
      id, :document, nil, nil, '/ram:Group',
      cardinality ? { en16931: cardinality }.freeze : {}.freeze
    )
  end

  def required_group = group('BG-1', '1..1')

  def optional_group = group('BG-2', '0..1')

  def forbidden_group = group('BG-3', nil)

  def formatting_error(term)
    FacturxSpec::Format.call('not a date', term:)
  rescue Facturx::Error => e
    raise unless e.is_a?(FacturxSpec::FormattingError)

    e
  end

  def issue_attributes(issue)
    issue.to_h
  end
end
