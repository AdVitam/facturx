# frozen_string_literal: true

require 'facturx/pdf/inspector'
require_relative '../../../spec/pdf/support/pdf_builder'

RSpec.describe Facturx::Pdf::Inspector do
  include PdfSupport

  subject(:inspector) { described_class.new }

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
    allow(PDF::Reader).to receive(:new).and_raise(PDF::Reader::EncryptedPDFError)

    expect(inspector_error(build_pdf)).to be_a(Facturx::ProtectedPdfError)
      .and have_attributes(details: include(protection: :encryption))
  end

  it 'rejects PDFs containing a signature dictionary' do
    signed_pdf = build_pdf(extra_objects: ['<< /Type /Sig /ByteRange [0 1 2 3] /Contents <00> >>'])

    expect(inspector_error(signed_pdf)).to be_a(Facturx::ProtectedPdfError)
      .and have_attributes(details: include(protection: :signature))
  end

  def inspector_error(pdf)
    inspector.call(pdf)
    raise 'Expected inspection to fail'
  rescue Facturx::InvalidPdfError => e
    e
  end
end
