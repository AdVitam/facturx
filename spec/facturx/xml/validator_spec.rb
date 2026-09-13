# frozen_string_literal: true

require 'facturx/xml/validator'
require_relative 'support/fixture'

RSpec.describe Facturx::Xml::Validator do
  include XmlFixtureSupport

  subject(:validator) { described_class.new }

  Facturx::Profiles.all.each do |profile|
    it "returns a valid report for the #{profile.id} profile" do
      expect(validator.call(xml: xml_fixture(profile.id))).to have_attributes(
        valid?: true, profile:, issues: []
      )
    end
  end

  it 'reports a non-string input as a syntax issue', :aggregate_failures do
    report = validator.call(xml: nil)
    issue = have_attributes(code: :invalid_xml, layer: :syntax, severity: :error,
                            details: { input_class: 'NilClass' })

    expect(report).to have_attributes(profile: nil, invalid?: true, issues: contain_exactly(issue))
  end

  it 'reports malformed XML with its location', :aggregate_failures do
    issue = validator.call(xml: '<broken').issues.fetch(0)

    expect(issue).to have_attributes(code: :invalid_xml, layer: :syntax)
    expect([issue.line, issue.column]).to all(be_a(Integer))
  end

  it 'distinguishes a missing profile' do
    xml = xml_fixture(:minimum).sub(Facturx::Profiles.fetch(:minimum).guideline_urn, '')

    expect(validator.call(xml: xml).issues).to contain_exactly(
      have_attributes(code: :missing_profile, layer: :profile)
    )
  end

  it 'reports an unknown profile value' do
    xml = xml_fixture(:minimum).sub(Facturx::Profiles.fetch(:minimum).guideline_urn, 'urn:example:unknown')

    expect(validator.call(xml: xml).issues).to contain_exactly(
      have_attributes(code: :unknown_profile, layer: :profile,
                      details: { guideline_urn: 'urn:example:unknown' })
    )
  end

  it 'reports every XSD violation with the detected profile', :aggregate_failures do
    xml = xml_fixture(:minimum).sub(%r{<rsm:ExchangedDocument>.*?</rsm:ExchangedDocument>}m, '')
    report = validator.call(xml:)

    expect(report).to have_attributes(profile: Facturx::Profiles.fetch(:minimum), invalid?: true)
    expect(report.issues).not_to be_empty
    expect(report.issues).to all(have_attributes(code: :xsd_violation, layer: :xsd, severity: :error))
  end

  it 'stops before schema validation when profile detection fails' do
    schema_validator = instance_spy(FacturxSpec::XmlSchemaValidator)
    profile_detector = instance_double(FacturxSpec::XmlProfileDetector)
    allow(profile_detector).to receive(:call).and_raise(Facturx::UnknownProfileError, 'unknown')

    described_class.new(profile_detector:, schema_validator:).call(xml: xml_fixture(:minimum))

    expect(schema_validator).not_to have_received(:call)
  end
end
