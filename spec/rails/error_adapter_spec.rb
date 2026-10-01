# frozen_string_literal: true

require 'eu_einvoice/rails'

RSpec.describe EuEinvoice::Rails::ErrorAdapter do
  let(:record) { Class.new { include ActiveModel::Model }.new }

  def issue(**attributes)
    EuEinvoice::Validation::Issue.new(code: :missing_value, message: 'Detail', layer: :document,
                                      term_id: 'BT-1', path: '/invoice', **attributes)
  end

  it 'maps known terms and retains structured details without exposing raw messages' do
    report = EuEinvoice::Validation::Report.new(issues: [issue])

    described_class.apply(record, report: report, attributes: { 'BT-1' => :number })

    expect(record.errors.details[:number]).to contain_exactly(
      error: :eu_einvoice, code: :missing_value, term_id: 'BT-1', path: '/invoice'
    )
  end

  it 'places unmapped rules on base and ignores warnings' do
    report = EuEinvoice::Validation::Report.new(issues: [issue(term_id: nil), issue(severity: :warning)])

    described_class.apply(record, report: report)

    expect(record.errors.attribute_names).to eq([:base])
    expect(record.errors.count).to eq(1)
  end

  it 'preserves preexisting application errors' do
    record.errors.add(:base, :invalid)
    described_class.apply(record, report: EuEinvoice::Validation::Report.new)

    expect(record.errors.of_kind?(:base, :invalid)).to be(true)
  end
end
