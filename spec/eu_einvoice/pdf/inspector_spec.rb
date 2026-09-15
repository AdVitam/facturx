# frozen_string_literal: true

require 'eu_einvoice/pdf/inspector'
require_relative '../../../spec/pdf/support/pdf_builder'

RSpec.describe EuEinvoice::Pdf::Inspector, :aggregate_failures do
  include PdfSupport

  subject(:inspector) { described_class.new(isolate:) }

  let(:isolate) { true }

  it 'accepts a structurally valid, unprotected PDF byte string' do
    expect(inspector.call(build_pdf)).to have_attributes(page_count: 1)
  end

  it 'rejects values that are not byte strings' do
    expect(inspector_error(nil)).to have_attributes(details: include(reason: :invalid_input))
  end

  it 'normalizes malformed PDF errors' do
    expect(inspector_error('not a PDF')).to have_attributes(details: include(reason: :malformed))
  end

  it 'rejects encrypted PDFs' do
    inspector = described_class.new(isolate: false)
    allow(PDF::Reader).to receive(:new).and_raise(PDF::Reader::EncryptedPDFError)

    expect { inspector.call(build_pdf) }.to raise_error(EuEinvoice::ProtectedPdfError) do |error|
      expect(error.details).to include(protection: :encryption)
    end
  end

  it 'rejects PDFs containing a signature dictionary' do
    signed_pdf = build_pdf(extra_objects: ['<< /Type /Sig /ByteRange [0 1 2 3] /Contents <00> >>'])

    expect(inspector_error(signed_pdf)).to be_a(EuEinvoice::ProtectedPdfError)
      .and have_attributes(details: include(protection: :signature))
  end

  it 'normalizes malformed errors raised while inspecting signatures' do
    stub_reader_with_malformed_signature(build_pdf)
    expect(inspector_error(build_pdf, isolate: false)).to have_attributes(
      details: include(reason: :malformed, cause: 'PDF::Reader::MalformedPDFError')
    )
  end

  def inspector_error(pdf, isolate: true)
    described_class.new(isolate:).call(pdf)
    raise 'Expected inspection to fail'
  rescue EuEinvoice::InvalidPdfError => e
    e
  end

  def stub_reader_with_malformed_signature(pdf)
    reader = PDF::Reader.new(StringIO.new(pdf))
    allow(PDF::Reader).to receive(:new).and_return(reader)
    allow(reader.objects).to receive(:any?)
      .and_raise(PDF::Reader::MalformedPDFError, 'malformed signature object')
  end
end
