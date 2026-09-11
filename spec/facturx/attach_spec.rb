# frozen_string_literal: true

RSpec.describe Facturx::Attach do
  subject(:attach) { described_class.new(**adapters) }

  let(:events) { [] }
  let(:profile) { Facturx::Profiles.fetch(:en16931) }
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
      xml_verifier: adapter(:verify_xml, profile),
      pdf_inspector: adapter(:inspect_pdf, Facturx::Pdf::Inspector::Result.new(page_count: 2)),
      composer: adapter(:compose, '%PDF-A'),
      extractor: adapter(:extract, :result),
      pdf_verifier: adapter(:verify_pdf, true)
    }
  end

  it 'orchestrates composition and self-verification in order' do
    expect([attach.call(pdf: '%PDF', xml: '<xml/>'), events]).to eq(['%PDF-A', expected_events])
  end

  it 'propagates self-verification failures' do
    adapters.fetch(:pdf_verifier).error = Facturx::VerificationError.new('invalid output')

    expect { attach.call(pdf: '%PDF', xml: '<xml/>') }.to raise_error(Facturx::VerificationError)
  end

  def adapter(name, result)
    adapter_class.new(events, name, result)
  end

  def expected_events
    [
      [:verify_xml, [], { xml: '<xml/>' }],
      [:inspect_pdf, ['%PDF'], {}],
      [:compose, [], { pdf: '%PDF', xml: '<xml/>', profile: }],
      [:extract, ['%PDF-A'], {}],
      [:verify_pdf, [], { result: :result, expected_xml: '<xml/>', expected_page_count: 2, profile: }]
    ]
  end
end
