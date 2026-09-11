# frozen_string_literal: true

require 'facturx/xml/verifier'
require_relative 'support/fixture'

RSpec.describe Facturx::Xml::Verifier do
  include XmlFixtureSupport

  subject(:verifier) { described_class.new }

  Facturx::Profiles.all.each do |profile|
    it "returns the validated #{profile.id} profile for orchestration reuse" do
      expect(verifier.call(xml: xml_fixture(profile.id))).to equal(profile)
    end
  end

  it 'stops before schema validation when profile detection fails' do
    schema_validator = instance_spy(Facturx::Xml::SchemaValidator)

    verify_with_unknown_profile(schema_validator)
    expect(schema_validator).not_to have_received(:call)
  end

  def verify_with_unknown_profile(schema_validator)
    detector = instance_double(Facturx::Xml::ProfileDetector, call: nil)
    allow(detector).to receive(:call).and_raise(Facturx::UnknownProfileError, 'unknown')
    described_class.new(profile_detector: detector, schema_validator: schema_validator).call(xml: xml_fixture(:minimum))
  rescue Facturx::UnknownProfileError
    nil
  end
end
