# frozen_string_literal: true

require_relative '../spec_helper'
require 'facturx/schematron'

RSpec.describe Facturx::Schematron, :aggregate_failures, :saxonc do
  it 'exposes only the companion error contract' do
    expect(described_class.constants(false).sort).to eq(%i[Error ExecutionError UnavailableError])
  end

  %i[minimum basic_wl basic en16931 extended].each do |profile_id|
    it "validates the official #{profile_id} example through the public API" do
      expect_valid_report(Facturx.validate_xml(xml: fixture_xml(profile_id)), profile_id)
    end
  end

  it 'reports an XSD-valid missing invoice number as BR-02' do
    expect_br02_report(Facturx.validate_xml(xml: invoice_without_number))
  end

  %i[basic en16931 extended].each do |profile_id|
    it "keeps the #{profile_id} report valid when R008 is emitted as a warning" do
      expect_warning_report(validate_with_empty_note(profile_id), profile_id)
    end
  end

  it 'raises a strict Schematron validation error with the real BR-02 issue' do
    expect_strict_br02 { Facturx::Xml::Verifier.new.call(xml: invoice_without_number) }
  end

  it 'validates and builds typed documents through the shared pipeline' do
    document = Facturx.read(fixture_xml(:minimum)).document

    expect_valid_document_pipeline(document)
  end

  it 'stops attach at strict XML verification before PDF composition' do
    expect_strict_br02 { Facturx.attach(pdf: 'not a PDF', xml: invoice_without_number) }
  end

  def expect_valid_report(report, profile_id)
    expect(report).to have_attributes(
      profile: Facturx::Profiles.fetch(profile_id),
      issues: [],
      valid?: true
    )
  end

  def expect_br02_report(report)
    expect(report).to have_attributes(profile: Facturx::Profiles.fetch(:en16931), invalid?: true)
    expect(report.issues).to all(have_attributes(layer: :schematron))
    expect(find_rule(report, 'BR-02')).to have_attributes(code: :schematron_violation, severity: :error)
  end

  def expect_warning_report(report, profile_id)
    expect(report).to have_attributes(profile: Facturx::Profiles.fetch(profile_id), valid?: true)
    expect(report.issues).to all(have_attributes(layer: :schematron, severity: :warning))
    expect(find_rule(report, 'PEPPOL-EN16931-R008'))
      .to have_attributes(code: :schematron_violation, severity: :warning)
  end

  def expect_strict_br02(&block)
    expect(&block).to raise_error(Facturx::SchematronValidationError) do |error|
      expect(find_rule(error.details.fetch(:issues), 'BR-02'))
        .to have_attributes(code: :schematron_violation, severity: :error)
    end
  end

  def expect_valid_document_pipeline(document)
    expect(Facturx.validate_document(document:, profile: :minimum)).to be_valid
    expect(Facturx.build_xml(document:, profile: :minimum)).to include(
      Facturx::Profiles.fetch(:minimum).guideline_urn
    )
  end

  def fixture_xml(profile_id)
    File.binread(File.expand_path("../fixtures/xml/#{profile_id}.xml", __dir__))
  end

  def invoice_without_number
    empty_element(
      fixture_xml(:en16931),
      '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:ID'
    )
  end

  def validate_with_empty_note(profile_id)
    xml = empty_element(
      fixture_xml(profile_id),
      '/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IncludedNote[1]/ram:Content'
    )
    Facturx.validate_xml(xml:)
  end

  def empty_element(xml, xpath)
    document = Nokogiri::XML::Document.parse(xml) { |config| config.strict.nonet }
    node = document.at_xpath(xpath, xml_namespaces)
    raise "Fixture element not found: #{xpath}" unless node

    node.content = ''
    document.to_xml
  end

  def find_rule(report_or_issues, rule_id)
    issues = report_or_issues.respond_to?(:issues) ? report_or_issues.issues : report_or_issues
    issues.find { |issue| issue.details[:rule_id] == rule_id }
  end

  def xml_namespaces
    {
      'rsm' => 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100',
      'ram' => 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'
    }
  end
end
