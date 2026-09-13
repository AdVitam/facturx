# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Facturx::Generate do
  let(:events) { [] }
  let(:writer) do
    instance_double(FacturxSpec::Writer).tap do |value|
      allow(value).to receive(:call) { |**arguments|
        events << [:write, arguments]
        '<invoice/>'
      }
    end
  end
  let(:pdf_composer) do
    instance_double(pdf_composer_class).tap do |value|
      allow(value).to receive(:call) { |**arguments|
        events << [:compose, arguments]
        '%PDF'
      }
    end
  end

  it 'writes and validates the document once before composing the PDF' do
    profile = Facturx::Profiles.fetch(:en16931)
    document = Facturx::Document.new

    result = described_class.new(writer:, pdf_composer:).call(pdf: 'source-pdf', document:, profile:)
    expect([result, events]).to eq(['%PDF', [[:write, { document:, profile: }],
                                             [:compose, { pdf: 'source-pdf', xml: '<invoice/>', profile: }]]])
  end

  it 'rejects unsupported profiles before writing' do
    generator = described_class.new(writer:, pdf_composer:)

    expect { generator.call(pdf: 'source-pdf', document: Facturx::Document.new, profile: :unknown) }
      .to raise_error(Facturx::UnsupportedProfileError)
  end

  def pdf_composer_class
    FacturxSpec::PdfComposer
  end
end
