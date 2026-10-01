# frozen_string_literal: true

require_relative '../pdf/support/pdf_builder'

RSpec.describe EuEinvoice::Client do
  include PdfSupport

  let(:specification) { EuEinvoice::France::Pack.new.specification }
  let(:alternate) { specification.with(version: 'synthetic-provider-test') }
  let(:xml) { File.binread('spec/fixtures/xml/en16931.xml') }
  let(:client) do
    described_class.new(packs: [pdf_pack(specification, 'factur-x.xml'), pdf_pack(alternate, 'alternate.xml')],
                        validation: :structural)
  end
  let(:pdf) do
    first = embedded_file_objects(xml)
    second = embedded_file_objects(alternate_xml, filename: 'alternate.xml', stream_id: 7)
    build_pdf(catalog: '/AF [4 0 R 6 0 R]', extra_objects: first + second)
  end

  it 'requires an explicit choice when both nonempty packs can extract PDFs' do
    expect { client.extract_xml(pdf:) }.to raise_error(EuEinvoice::AmbiguousSpecificationError)
  end

  it 'extracts through the provider selected by the exact specification' do
    expect(client.extract_xml(pdf:, specification: alternate).bytes).to eq(alternate_xml)
  end

  it 'can still select the first provider explicitly' do
    expect(client.extract_xml(pdf:, specification:).bytes).to eq(xml)
  end

  it 'uses the same exact selection for extraction and semantic PDF reading' do
    expect(client.read(pdf, specification: alternate)).to have_attributes(
      source_type: :pdf, specification: alternate, document: have_attributes(invoice_number: 'ALTERNATE-PROVIDER')
    )
  end

  def alternate_xml
    xml.sub('F-2023-004', 'ALTERNATE-PROVIDER')
  end

  def pdf_pack(specification, filename)
    embedding = EuEinvoice::Pdf::Embedding.new(**EuEinvoice::France::EMBEDDING.to_h, filename:)
    Struct.new(:specifications, :embedding) do
      def adapter(validation:, limits:)
        EuEinvoice::France::Adapter.new(specifications:, validation:, limits:)
      end

      def extract_xml(pdf:, limits:)
        EuEinvoice::Pdf::Extractor.new(embedding:, limits:).call(pdf).xml
      end
    end.new([specification], embedding)
  end
end
