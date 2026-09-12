# frozen_string_literal: true

require 'spec_helper'
require 'facturx/conformance'
require 'facturx/document'
require 'facturx/format'
require 'facturx/group'
require 'facturx/profile'
require 'facturx/term'

RSpec.describe Facturx::Conformance, :aggregate_failures do
  let(:profile) do
    Facturx::Profile.new(id: :en16931, guideline_urn: 'urn:example:en16931', xsd_path: '/schema.xsd',
                         conformance_level: 'EN 16931')
  end
  let(:tracker) { Facturx::Conformance::Tracker.new(profile:) }

  describe Facturx::Conformance::Issue do
    it 'deep-copies and freezes all mutable input' do
      details = { nested: [+'value'] }
      issue = described_class.new(code: :invalid_value, message: +'Invalid', details:)
      details[:nested].first.replace('changed')

      expect([issue.message.frozen?, issue.details, issue.details.frozen?])
        .to eq([true, { nested: ['value'] }, true])
    end
  end

  describe Facturx::Conformance::Report do
    it 'owns an immutable issue snapshot and exposes validity predicates' do
      issues = []
      report = described_class.new(profile:, issues:)
      issues << :late

      expect([report.issues, report.issues.frozen?, report.valid?, report.invalid?]).to eq([[], true, true, false])
    end
  end

  describe Facturx::Conformance::Tracker do
    it 'accepts a nil or matching document guideline' do
      document = Facturx::Document.new(guideline_urn: profile.guideline_urn)

      expect([tracker.check_guideline(nil), tracker.check_document(document), tracker.report.valid?])
        .to eq([nil, nil, true])
    end

    it 'reports a profile mismatch' do
      tracker.check_guideline('urn:example:minimum', path: '/guideline')

      expect(issue_attributes(tracker.report.issues.first)).to include(
        code: :profile_mismatch, term_id: 'BT-24', path: '/guideline',
        details: { expected: profile.guideline_urn, actual: 'urn:example:minimum' }
      )
    end

    it 'aggregates missing and forbidden terms' do
      results = [tracker.observe_term(required_term, value: nil),
                 tracker.observe_term(optional_term, value: nil),
                 tracker.observe_term(forbidden_term, value: 'forbidden')]

      expect([*results, tracker.report.issues.map(&:code)])
        .to eq([false, false, false, %i[missing_required_term forbidden_term]])
    end

    it 'reports scalar cardinality while keeping present values emit-able' do
      results = [tracker.observe_term(required_term, value: %w[first second]),
                 tracker.observe_group(required_group, count: 2)]

      expect([*results, tracker.report.issues.map(&:code)])
        .to eq([true, true, %i[invalid_cardinality invalid_cardinality]])
    end

    it 'aggregates missing and forbidden groups' do
      results = [tracker.observe_group(required_group, count: 0),
                 tracker.observe_group(optional_group, count: 0),
                 tracker.observe_group(forbidden_group, count: 1)]

      expect([*results, tracker.report.issues.map(&:code)])
        .to eq([false, false, false, %i[missing_required_group forbidden_group]])
    end

    it 'does not cascade into children of missing or forbidden groups' do
      results = [tracker.observe_group(required_group, count: 0),
                 tracker.observe_group(forbidden_group, count: 1)]
      tracker.observe_term(required_term, value: nil, group_present: false)

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
    Facturx::Term.new(
      id, :document, :invoice_number, 'BG-0', '/ram:ID', :date_102, nil,
      cardinality ? { en16931: cardinality }.freeze : {}.freeze
    )
  end

  def required_term = term('BT-1', '1..1')

  def optional_term = term('BT-2', '0..1')

  def forbidden_term = term('BT-3', nil)

  def group(id, cardinality)
    Facturx::Group.new(
      id, :document, nil, nil, '/ram:Group',
      cardinality ? { en16931: cardinality }.freeze : {}.freeze
    )
  end

  def required_group = group('BG-1', '1..1')

  def optional_group = group('BG-2', '0..1')

  def forbidden_group = group('BG-3', nil)

  def formatting_error(term)
    Facturx::Format.call('not a date', term:)
  rescue Facturx::FormattingError => e
    e
  end

  def issue_attributes(issue)
    issue.to_h
  end
end
