# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Facturx::Generate do
  let(:events) { [] }
  let(:writer) do
    instance_double(Facturx::Writer).tap do |value|
      allow(value).to receive(:call) { |**arguments|
        events << [:write, arguments]
        '<invoice/>'
      }
    end
  end
  let(:attacher) do
    instance_double(Facturx::Attach).tap do |value|
      allow(value).to receive(:call) { |**arguments|
        events << [:attach, arguments]
        '%PDF'
      }
    end
  end

  it 'writes the document before attaching the generated XML' do
    profile = Facturx::Profiles.fetch(:en16931)
    document = Facturx::Document.new

    result = described_class.new(writer:, attacher:).call(pdf: 'source-pdf', document:, profile:)
    expect([result, events]).to eq(['%PDF', [[:write, { document:, profile: }],
                                             [:attach, { pdf: 'source-pdf', xml: '<invoice/>' }]]])
  end

  it 'rejects unsupported profiles before writing' do
    generator = described_class.new(writer:, attacher:)

    expect { generator.call(pdf: 'source-pdf', document: Facturx::Document.new, profile: :unknown) }
      .to raise_error(Facturx::UnsupportedProfileError)
  end
end
