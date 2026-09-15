# frozen_string_literal: true

require 'eu_einvoice/pdf/extractor'
require 'eu_einvoice/pdf/verifier'

RSpec.describe EuEinvoice::Pdf::Verifier do
  subject(:verifier) { described_class.new(embedding: EuEinvoice::France::EMBEDDING) }

  let(:xml) { '<invoice>é</invoice>'.b }
  let(:profile) { Struct.new(:conformance_level).new('EN 16931') }
  let(:metadata) do
    <<~XML
      <?xml version="1.0"?>
      <x:xmpmeta xmlns:x="adobe:ns:meta/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:pdfaid="http://www.aiim.org/pdfa/ns/id/"
                 xmlns:fx="urn:factur-x:pdfa:CrossIndustryDocument:invoice:1p0#">
          <rdf:Description>
            <pdfaid:part>3</pdfaid:part>
            <pdfaid:conformance>B</pdfaid:conformance>
            <fx:DocumentFileName>factur-x.xml</fx:DocumentFileName>
            <fx:DocumentType>INVOICE</fx:DocumentType>
            <fx:Version>1.0</fx:Version>
            <fx:ConformanceLevel>EN 16931</fx:ConformanceLevel>
          </rdf:Description>
        </rdf:RDF>
      </x:xmpmeta>
    XML
  end
  let(:result) do
    EuEinvoice::Pdf::Extractor::Result.new(
      xml:, filename: 'factur-x.xml', relationship: :Alternative, metadata:, page_count: 1
    )
  end

  it 'accepts matching attachment and XMP metadata' do
    expect { verifier.call(result:, expected_xml: xml, expected_page_count: 1, profile:) }.not_to raise_error
  end

  it 'compares XML as exact bytes' do
    details = verification_error(expected_xml: '<invoice />').details

    expect(details).to include(
      reason: :result_mismatch, field: :xml, expected_size: 11, actual_size: xml.bytesize
    ).and include(:expected_sha256, :actual_sha256)
  end

  it 'verifies the attachment filename' do
    invalid = result.with(filename: 'invoice.xml')

    expect(verification_error(result: invalid).details)
      .to include(reason: :result_mismatch, field: :filename)
  end

  it 'verifies the AF relationship' do
    invalid = result.with(relationship: :Data)

    expect(verification_error(result: invalid).details)
      .to include(reason: :result_mismatch, field: :relationship)
  end

  it 'verifies that composition preserves the source page count' do
    expect(verification_error(expected_page_count: 2).details)
      .to include(reason: :result_mismatch, field: :page_count, expected: 2, actual: 1)
  end

  it 'rejects missing XMP metadata' do
    expect(verification_error(result: result.with(metadata: nil)).details).to include(reason: :missing_xmp)
  end

  it 'rejects malformed XMP metadata' do
    expect(verification_error(result: result.with(metadata: '<rdf')).details).to include(reason: :invalid_xmp)
  end

  it 'verifies each required XMP value' do
    invalid = result.with(metadata: metadata.sub('<pdfaid:part>3', '<pdfaid:part>2'))

    expect(verification_error(result: invalid).details)
      .to include(reason: :xmp_mismatch, field: :pdfa_part, expected: '3', actual: '2')
  end

  it 'accepts PDF/A identification stored as RDF attributes' do
    expect do
      verifier.call(result: result.with(metadata: metadata_with_pdfaid_attributes), expected_xml: xml,
                    expected_page_count: 1, profile:)
    end.not_to raise_error
  end

  it 'rejects duplicate XMP properties even when one value matches' do
    duplicate = metadata.sub('</rdf:Description>', '<pdfaid:part>2</pdfaid:part></rdf:Description>')

    expect(verification_error(result: result.with(metadata: duplicate)).details)
      .to include(reason: :xmp_mismatch, field: :pdfa_part, actual: %w[3 2])
  end

  it 'ignores matching decoys outside the RDF description' do
    invalid = metadata.sub('<pdfaid:part>3</pdfaid:part>', '<pdfaid:part>2</pdfaid:part>')
                      .sub('</rdf:RDF>', '<pdfaid:part>3</pdfaid:part></rdf:RDF>')

    expect(verification_error(result: result.with(metadata: invalid)).details)
      .to include(reason: :xmp_mismatch, field: :pdfa_part, actual: '2')
  end

  it 'verifies the profile conformance level' do
    invalid_profile = Struct.new(:conformance_level).new('EXTENDED')

    expect(verification_error(profile: invalid_profile).details)
      .to include(reason: :xmp_mismatch, field: :facturx_conformance_level)
  end

  it 'does not mask programmer errors as verification failures' do
    expect do
      verifier.call(result:, expected_xml: xml, expected_page_count: 1, profile: Object.new)
    end.to raise_error(NoMethodError)
  end

  def verification_error(result: self.result, expected_xml: xml, expected_page_count: 1, profile: self.profile)
    verifier.call(result:, expected_xml:, expected_page_count:, profile:)
    raise 'Expected verification to fail'
  rescue EuEinvoice::VerificationError => e
    e
  end

  def metadata_with_pdfaid_attributes
    metadata
      .sub('<pdfaid:part>3</pdfaid:part>', '')
      .sub('<pdfaid:conformance>B</pdfaid:conformance>', '')
      .sub('<rdf:Description>', '<rdf:Description pdfaid:part="3" pdfaid:conformance="B">')
  end
end
