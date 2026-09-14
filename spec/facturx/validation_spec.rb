# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Facturx::Validation, :aggregate_failures do
  let(:profile) do
    Facturx::Profile.new(id: :en16931, guideline_urn: 'urn:example:en16931', conformance_level: 'EN 16931')
  end

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
end
