# frozen_string_literal: true

require 'eu_einvoice/xml/parser'
require 'eu_einvoice/xml/profile_detector'
require_relative 'support/fixture'

RSpec.describe EuEinvoice::Xml::ProfileDetector do
  include XmlFixtureSupport

  subject(:detector) { described_class.new(profiles: EuEinvoice::Profiles.all) }

  let(:parser) { EuEinvoice::Xml::Parser.new }
  let(:unknown_document) do
    parser.call(xml: xml_fixture(:minimum).sub(EuEinvoice::Profiles.fetch(:minimum).guideline_urn,
                                               'urn:example:unknown'))
  end
  let(:missing_document) do
    parser.call(xml: <<~XML)
      <rsm:CrossIndustryInvoice
        xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"
        xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100" />
    XML
  end

  EuEinvoice::Profiles.all.each do |profile|
    it "detects the #{profile.id} profile from BT-24" do
      document = parser.call(xml: xml_fixture(profile.id))

      expect(detector.call(document: document)).to equal(profile)
    end
  end

  it 'defines the five profiles in increasing conformance order' do
    expect(EuEinvoice::Profiles.all.map(&:id)).to eq(%i[minimum basic_wl basic en16931 extended])
  end

  it 'keeps the public profile catalog immutable' do
    expect(EuEinvoice::Profiles.all).to be_frozen
  end

  it 'rejects a missing BT-24' do
    expect { detector.call(document: missing_document) }
      .to raise_error(EuEinvoice::UnknownProfileError, 'Factur-X BT-24 is missing')
  end

  it 'rejects an unknown BT-24 and reports its value' do
    expect(unknown_profile_error).to have_attributes(
      message: 'Factur-X BT-24 is unknown', details: { guideline_urn: 'urn:example:unknown' }
    )
  end

  def unknown_profile_error
    detector.call(document: unknown_document)
  rescue EuEinvoice::UnknownProfileError => e
    e
  end
end
