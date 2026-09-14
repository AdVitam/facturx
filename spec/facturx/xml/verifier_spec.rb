# frozen_string_literal: true

require 'facturx/xml/verifier'
require_relative 'support/fixture'

RSpec.describe Facturx::Xml::Verifier do
  include XmlFixtureSupport

  subject(:verifier) { described_class.new }

  it 'returns the validated profile for orchestration reuse' do
    profile = Facturx::Profiles.fetch(:minimum)

    expect(verifier.call(xml: xml_fixture(profile.id))).to equal(profile)
  end

  {
    syntax: Facturx::InvalidXmlError,
    profile: Facturx::UnknownProfileError,
    xsd: Facturx::XsdValidationError
  }.each do |layer, error_class|
    it "raises #{error_class} for a #{layer} validation issue", :aggregate_failures do
      error, report = verification_error(layer)

      expect(error).to be_a(error_class)
      expect(error.details).to include(report:, issues: report.issues)
    end
  end

  def verification_error(layer)
    issue = Facturx::Validation::Issue.new(code: :invalid, message: 'Invalid', layer:)
    report = Facturx::Validation::Report.new(issues: [issue])
    validator = instance_double(Facturx::Xml::Validator, call: report)
    [described_class.new(validator:).call(xml: '<xml/>'), report]
  rescue Facturx::ValidationError => e
    [e, report]
  end
end
