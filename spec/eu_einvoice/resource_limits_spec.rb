# frozen_string_literal: true

require 'eu_einvoice/pdf/extractor'
require 'zlib'
require_relative '../pdf/support/pdf_builder'

RSpec.describe EuEinvoice::ResourceLimits, :aggregate_failures do
  include PdfSupport

  it 'bounds bytes before launching a worker' do
    inspector = EuEinvoice::Pdf::Inspector.new(limits: described_class.new(pdf_bytes: 4))

    expect { inspector.call(build_pdf) }.to raise_error(EuEinvoice::ResourceLimitError)
  end

  it 'enforces attachment budgets in the isolated worker' do
    pdf = build_pdf(catalog: '/AF [4 0 R 4 0 R]', extra_objects: embedded_file_objects('<invoice/>'))
    extractor = limited_extractor(attachments: 1)

    expect { extractor.call(pdf) }.to raise_error(EuEinvoice::ResourceLimitError) do |error|
      expect(error.details).to include(resource: :attachments)
    end
  end

  it 'bounds decompressed embedded XML independently from PDF size' do
    pdf = compressed_attachment_pdf
    extractor = limited_extractor(xml_bytes: 16)

    expect { extractor.call(pdf) }.to raise_error(EuEinvoice::ResourceLimitError)
  end

  it 'rejects excessive PDF object counts before traversing pages' do
    inspector = EuEinvoice::Pdf::Inspector.new(limits: described_class.new(pdf_objects: 1))

    expect { inspector.call(build_pdf) }.to raise_error(EuEinvoice::ResourceLimitError)
  end

  it 'rejects a cyclic embedded-file name tree' do
    pdf = build_pdf(catalog: '/Names << /EmbeddedFiles 4 0 R >>', extra_objects: ['<< /Kids [4 0 R] >>'])

    expect { limited_extractor.call(pdf) }.to raise_error(EuEinvoice::ExtractionError)
  end

  it 'enforces the page tree depth budget' do
    inspector = EuEinvoice::Pdf::Inspector.new(limits: described_class.new(tree_depth: 1))

    expect { inspector.call(build_pdf) }.to raise_error(EuEinvoice::ResourceLimitError)
  end

  it 'rejects page tree cycles without recursing indefinitely' do
    pdf = build_pdf.sub('/Kids [3 0 R]', '/Kids [2 0 R]')

    expect { EuEinvoice::Pdf::Inspector.new.call(pdf) }.to raise_error(EuEinvoice::InvalidPdfError)
  end

  def compressed_attachment_pdf
    compressed = Zlib.deflate('x' * 32_768)
    objects = embedded_file_objects(compressed)
    objects[1] = objects[1].sub('/Type /EmbeddedFile', '/Type /EmbeddedFile /Filter /FlateDecode')
    build_pdf(catalog: '/AF [4 0 R]', extra_objects: objects)
  end

  def limited_extractor(**values)
    EuEinvoice::Pdf::Extractor.new(embedding: EuEinvoice::France::EMBEDDING, limits: described_class.new(**values))
  end
end
