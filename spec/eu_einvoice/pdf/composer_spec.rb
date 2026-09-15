# frozen_string_literal: true

require_relative '../../pdf/support/pdf_builder'

RSpec.describe EuEinvoice::Pdf::Composer do
  include PdfSupport

  subject(:composer) do
    described_class.new(embedding: EuEinvoice::France::EMBEDDING, adapters: described_class::Adapters.new(**adapters))
  end

  let(:events) { [] }
  let(:profile) { EuEinvoice::Profiles.fetch(:en16931) }
  let(:adapter_class) do
    Class.new do
      attr_writer :error

      def initialize(events, name, result)
        @events = events
        @name = name
        @result = result
      end

      def call(*arguments, **keywords)
        @events << [@name, arguments, keywords]
        raise @error if @error

        @result
      end
    end
  end
  let(:adapters) do
    {
      inspector: adapter(:inspect_pdf, EuEinvoice::Pdf::Inspector::Result.new(page_count: 2)),
      backend: adapter(:compose, '%PDF-A'),
      extractor: adapter(:extract, :result),
      verifier: adapter(:verify_pdf, true)
    }
  end

  it 'composes and self-verifies the PDF in order' do
    expect([composer.call(pdf: '%PDF', xml: '<xml/>', profile:), events]).to eq(['%PDF-A', expected_events])
  end

  it 'propagates self-verification failures' do
    adapters.fetch(:verifier).error = EuEinvoice::VerificationError.new('invalid output')

    expect { composer.call(pdf: '%PDF', xml: '<xml/>', profile:) }.to raise_error(EuEinvoice::VerificationError)
  end

  it 'uses an injected backend without requiring a full adapter bundle' do
    backend = adapter(:compose, build_pdf)
    injected = described_class.new(embedding: EuEinvoice::France::EMBEDDING, backend:)

    expect { injected.call(pdf: build_pdf, xml: '<xml/>', profile:) }.to raise_error(EuEinvoice::ExtractionError)
    expect(events).to include([:compose, [], { pdf: a_string_starting_with('%PDF-'), xml: '<xml/>', profile: }])
  end

  it 'rejects competing backend injection styles' do
    expect do
      described_class.new(embedding: EuEinvoice::France::EMBEDDING, backend: adapter(:compose, '%PDF-A'),
                          adapters: described_class::Adapters.new(**adapters))
    end.to raise_error(ArgumentError)
  end

  def adapter(name, result)
    adapter_class.new(events, name, result)
  end

  def expected_events
    [
      [:inspect_pdf, ['%PDF'], {}],
      [:compose, [], { pdf: '%PDF', xml: '<xml/>', profile: }],
      [:extract, ['%PDF-A'], {}],
      [:verify_pdf, [], { result: :result, expected_xml: '<xml/>', expected_page_count: 2, profile: }]
    ]
  end
end
