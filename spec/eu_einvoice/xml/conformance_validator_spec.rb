# frozen_string_literal: true

require 'eu_einvoice/xml/conformance_validator'

RSpec.describe EuEinvoice::Xml::ConformanceValidator do
  let(:document) { Nokogiri::XML('<invoice/>') }
  let(:profile) { EuEinvoice::Profiles.fetch(:minimum) }
  let(:schema_validator) { instance_spy(EuEinvoice::Xml::SchemaValidator) }
  let(:schematron_validator) { double('Schematron validator', call: [:issue]) }
  let(:validator) { described_class.new(schema_validator:, schematron_validator:) }

  it 'runs XSD before returning Schematron issues', :aggregate_failures do
    expect(validator.call(document:, profile:)).to eq([:issue])
    expect(schema_validator).to have_received(:call).with(document:, profile:).ordered
    expect(schematron_validator).to have_received(:call).with(document:, profile:).ordered
  end

  it 'does not invoke Schematron after an XSD failure', :aggregate_failures do
    allow(schema_validator).to receive(:call).and_raise(EuEinvoice::XsdValidationError, 'Invalid')

    expect { validator.call(document:, profile:) }.to raise_error(EuEinvoice::XsdValidationError)
    expect(schematron_validator).not_to have_received(:call)
  end
end
