# frozen_string_literal: true

require 'eu_einvoice/xml/verifier'
require_relative 'support/fixture'

RSpec.describe EuEinvoice::Xml::Verifier do
  include XmlFixtureSupport

  subject(:verifier) { described_class.new(validator: cii_validator) }

  it 'returns the validated profile for orchestration reuse' do
    profile = EuEinvoice::Profiles.fetch(:minimum)

    expect(verifier.call(xml: xml_fixture(profile.id))).to equal(profile)
  end

  {
    syntax: EuEinvoice::InvalidXmlError,
    profile: EuEinvoice::UnknownProfileError,
    xsd: EuEinvoice::XsdValidationError,
    schematron: EuEinvoice::SchematronValidationError
  }.each do |layer, error_class|
    it "raises #{error_class} for a #{layer} validation issue", :aggregate_failures do
      error, report = verification_error(layer)

      expect(error).to be_a(error_class)
      expect(error.details).to include(report:, issues: report.issues)
    end
  end

  it 'raises from the first error when warnings precede it' do
    validator = instance_double(EuEinvoice::Xml::Validator, call: warning_before_error_report)

    expect { described_class.new(validator:).call(xml: '<xml/>') }
      .to raise_error(EuEinvoice::SchematronValidationError, 'Error')
  end

  def verification_error(layer)
    issue = EuEinvoice::Validation::Issue.new(code: :invalid, message: 'Invalid', layer:)
    report = EuEinvoice::Validation::Report.new(issues: [issue])
    validator = instance_double(EuEinvoice::Xml::Validator, call: report)
    [described_class.new(validator:).call(xml: '<xml/>'), report]
  rescue EuEinvoice::ValidationError => e
    [e, report]
  end

  def warning_before_error_report
    warning = EuEinvoice::Validation::Issue.new(
      code: :schematron_violation,
      message: 'Warning',
      layer: :schematron,
      severity: :warning
    )
    EuEinvoice::Validation::Report.new(issues: [warning, warning.with(message: 'Error', severity: :error)])
  end
end
