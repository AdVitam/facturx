# frozen_string_literal: true

require 'facturx/pdf/extractor'
require_relative '../../../spec/pdf/support/pdf_builder'

RSpec.describe Facturx::Pdf::Extractor do
  include PdfSupport

  subject(:extractor) { described_class.new }

  let(:xml) { '<rsm:CrossIndustryInvoice>facture n° 42</rsm:CrossIndustryInvoice>'.b }

  it 'extracts exact XML bytes and attachment metadata from the catalog AF entry' do
    pdf = build_pdf(catalog: '/AF [4 0 R]', extra_objects: embedded_file_objects(xml))

    expect(extractor.call(pdf)).to have_attributes(
      xml: xml, filename: 'factur-x.xml', relationship: :Alternative, page_count: 1
    )
  end

  it 'decodes the UTF-16BE Unicode filename emitted by Ghostscript' do
    objects = embedded_file_objects(xml)
    unicode_name = 'factur-x.xml'.encode(Encoding::UTF_16BE).unpack1('H*').upcase
    objects[0] = objects[0].sub('/UF (factur-x.xml)', "/UF <FEFF#{unicode_name}>")
    pdf = build_pdf(catalog: '/AF [4 0 R]', extra_objects: objects)

    expect(extractor.call(pdf).filename).to eq('factur-x.xml')
  end

  it 'does not validate the extracted bytes as XML' do
    pdf = build_pdf(catalog: '/AF [4 0 R]', extra_objects: embedded_file_objects('not XML'))

    expect(extractor.call(pdf).xml).to eq('not XML')
  end

  it 'returns exact XMP bytes from the catalog metadata stream' do
    xmp = '<x:xmpmeta>metadata</x:xmpmeta>'.b
    objects = embedded_file_objects(xml) + [raw_stream(xmp, '/Subtype /XML')]
    pdf = build_pdf(catalog: '/AF [4 0 R] /Metadata 6 0 R', extra_objects: objects)

    expect(extractor.call(pdf).metadata).to eq(xmp)
  end

  it 'recursively searches the EmbeddedFiles name tree' do
    objects = embedded_file_objects(xml)
    objects << '<< /Kids [7 0 R] >>'
    objects << '<< /Names [(factur-x.xml) 4 0 R] >>'
    pdf = build_pdf(catalog: '/Names << /EmbeddedFiles 6 0 R >>', extra_objects: objects)

    expect(extractor.call(pdf).xml).to eq(xml)
  end

  it 'uses the catalog AF entry before the EmbeddedFiles name tree' do
    expect(extractor.call(pdf_with_two_sources).xml).to eq(xml)
  end

  it 'falls back to the name tree when AF contains only unrelated attachments' do
    expect(extractor.call(pdf_with_two_sources(af_filename: 'other.xml', fallback_xml: xml)).xml).to eq(xml)
  end

  it 'rejects a missing Factur-X attachment' do
    expect(extraction_error(build_pdf).details).to include(reason: :missing_attachment)
  end

  it 'rejects multiple Factur-X attachments' do
    objects = embedded_file_objects(xml)
    objects.concat(embedded_file_objects(xml, stream_id: 7))
    pdf = build_pdf(catalog: '/AF [4 0 R 6 0 R]', extra_objects: objects)

    expect(extraction_error(pdf).details).to include(reason: :ambiguous_attachment)
  end

  it 'rejects inconsistent attachment filenames' do
    objects = embedded_file_objects(xml)
    objects[0] = objects[0].sub('/UF (factur-x.xml)', '/UF (invoice.xml)')
    pdf = build_pdf(catalog: '/AF [4 0 R]', extra_objects: objects)

    expect(extraction_error(pdf).details).to include(reason: :invalid_filename)
  end

  it 'rejects an attachment without the Alternative relationship' do
    objects = embedded_file_objects(xml, relationship: 'Data')
    pdf = build_pdf(catalog: '/AF [4 0 R]', extra_objects: objects)

    expect(extraction_error(pdf).details).to include(reason: :invalid_relationship)
  end

  it 'rejects an attachment without an embedded stream' do
    file_specification = '<< /Type /Filespec /F (factur-x.xml) /UF (factur-x.xml) /AFRelationship /Alternative >>'
    pdf = build_pdf(catalog: '/AF [4 0 R]', extra_objects: [file_specification])

    expect(extraction_error(pdf).details).to include(reason: :missing_stream)
  end

  it 'propagates invalid PDF errors' do
    expect { extractor.call('not a PDF') }.to raise_error(Facturx::InvalidPdfError)
  end

  it 'extracts XML from a signed PDF without rewriting it' do
    signed_pdf = build_pdf(
      catalog: '/AF [4 0 R]',
      extra_objects: embedded_file_objects(xml) + ['<< /Type /Sig /ByteRange [0 1 2 3] /Contents <00> >>']
    )

    expect(extractor.call(signed_pdf).xml).to eq(xml)
  end

  def extraction_error(pdf)
    extractor.call(pdf)
    raise 'Expected extraction to fail'
  rescue Facturx::ExtractionError => e
    e
  end

  def pdf_with_two_sources(af_filename: 'factur-x.xml', fallback_xml: '<invoice>fallback</invoice>')
    direct = embedded_file_objects(xml, filename: af_filename)
    fallback = embedded_file_objects(fallback_xml, stream_id: 7)
    objects = direct + fallback + ['<< /Names [(factur-x.xml) 6 0 R] >>']
    build_pdf(catalog: '/AF [4 0 R] /Names << /EmbeddedFiles 8 0 R >>', extra_objects: objects)
  end

  def raw_stream(bytes, dictionary = '')
    "<< /Length #{bytes.bytesize} #{dictionary} >>\nstream\n#{bytes}\nendstream"
  end
end
