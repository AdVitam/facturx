# frozen_string_literal: true

require 'facturx/xml/parser'
require 'facturx/xml/schema_validator'
require_relative 'support/fixture'

RSpec.describe Facturx::Xml::SchemaValidator do
  include XmlFixtureSupport

  subject(:validator) { described_class.new }

  let(:parser) { Facturx::Xml::Parser.new }
  let(:minimum_profile) { Facturx::Profiles.fetch(:minimum) }
  let(:minimum_document) { parser.call(xml: xml_fixture(:minimum)) }
  let(:missing_profile) do
    Facturx::Profile.new(id: :missing, guideline_urn: 'urn:example:missing', conformance_level: 'MISSING')
  end

  Facturx::Profiles.all.each do |profile|
    it "validates a #{profile.id} invoice with the complete imported XSD set" do
      document = parser.call(xml: xml_fixture(profile.id))

      expect { validator.call(document: document, profile: profile) }.not_to raise_error
    end
  end

  it 'raises a typed error containing structured XSD diagnostics' do
    xml = xml_fixture(:minimum).sub(%r{<rsm:ExchangedDocument>.*?</rsm:ExchangedDocument>}m, '')
    document = parser.call(xml: xml)

    expect(validation_error(document).details).to match(
      profile: :minimum, errors: [include(:message, :line, :column, :level)]
    )
  end

  it 'loads a schema once per absolute path across validator instances' do
    validator_class = Class.new(described_class)
    allow(Nokogiri::XML).to receive(:Schema).and_call_original

    2.times { validator_class.new.call(document: minimum_document, profile: minimum_profile) }

    expect(Nokogiri::XML).to have_received(:Schema).once
  end

  it 'wraps a missing schema without leaking Errno exceptions' do
    registry = instance_double(Facturx::Xml::SchemaRegistry, fetch: '/missing/facturx.xsd')

    expect { described_class.new(registry:).call(document: minimum_document, profile: missing_profile) }
      .to raise_error(Facturx::SchemaLoadError, 'Unable to load the Factur-X missing schema')
  end

  it 'does not wrap schema validation failures as schema load failures' do
    expect { validation_failure_validator.call(document: minimum_document, profile: minimum_profile) }
      .to raise_error(Nokogiri::XML::SyntaxError, 'validation failure')
  end

  def validation_error(document)
    validator.call(document: document, profile: minimum_profile)
  rescue Facturx::XsdValidationError => e
    e
  end

  def validation_failure_validator
    validator_class = Class.new(described_class)
    schema = instance_double(Nokogiri::XML::Schema)
    allow(Nokogiri::XML).to receive(:Schema).and_return(schema)
    allow(schema).to receive(:validate).and_raise(Nokogiri::XML::SyntaxError, 'validation failure')
    validator_class.new
  end
end
