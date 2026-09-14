# frozen_string_literal: true

require 'facturx/xml/conformance_validator'

RSpec.describe Facturx::Xml::ConformanceValidator do
  let(:document) { Nokogiri::XML('<invoice/>') }
  let(:profile) { Facturx::Profiles.fetch(:minimum) }
  let(:schema_validator) { instance_spy(Facturx::Xml::SchemaValidator) }
  let(:schematron_validator) { class_double(Facturx::SchematronAdapter, call: [:issue]) }
  let(:validator) { described_class.new(schema_validator:, schematron_validator:) }

  it 'runs XSD before returning Schematron issues', :aggregate_failures do
    expect(validator.call(document:, profile:)).to eq([:issue])
    expect(schema_validator).to have_received(:call).with(document:, profile:).ordered
    expect(schematron_validator).to have_received(:call).with(document:, profile:).ordered
  end

  it 'does not invoke Schematron after an XSD failure', :aggregate_failures do
    allow(schema_validator).to receive(:call).and_raise(Facturx::XsdValidationError, 'Invalid')

    expect { validator.call(document:, profile:) }.to raise_error(Facturx::XsdValidationError)
    expect(schematron_validator).not_to have_received(:call)
  end
end
