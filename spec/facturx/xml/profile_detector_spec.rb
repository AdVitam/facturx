# frozen_string_literal: true

require 'facturx/xml/parser'
require 'facturx/xml/profile_detector'
require_relative 'support/fixture'

RSpec.describe Facturx::Xml::ProfileDetector do
  include XmlFixtureSupport

  subject(:detector) { described_class.new }

  let(:parser) { Facturx::Xml::Parser.new }
  let(:unknown_document) do
    parser.call(xml: xml_fixture(:minimum).sub(Facturx::Profiles.fetch(:minimum).guideline_urn,
                                               'urn:example:unknown'))
  end
  let(:missing_document) do
    parser.call(xml: <<~XML)
      <rsm:CrossIndustryInvoice
        xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"
        xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100" />
    XML
  end

  Facturx::Profiles.all.each do |profile|
    it "detects the #{profile.id} profile from BT-24" do
      document = parser.call(xml: xml_fixture(profile.id))

      expect(detector.call(document: document)).to equal(profile)
    end
  end

  it 'defines the five profiles in increasing conformance order' do
    expect(Facturx::Profiles.all.map(&:id)).to eq(%i[minimum basic_wl basic en16931 extended])
  end

  it 'keeps the public profile catalog immutable' do
    expect(Facturx::Profiles.all).to be_frozen
  end

  it 'rejects a missing BT-24' do
    expect { detector.call(document: missing_document) }
      .to raise_error(Facturx::UnknownProfileError, 'Factur-X BT-24 is missing')
  end

  it 'rejects an unknown BT-24 and reports its value' do
    expect(unknown_profile_error).to have_attributes(
      message: 'Factur-X BT-24 is unknown', details: { guideline_urn: 'urn:example:unknown' }
    )
  end

  def unknown_profile_error
    detector.call(document: unknown_document)
  rescue Facturx::UnknownProfileError => e
    e
  end
end
