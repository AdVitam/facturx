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
      pdf_composer: adapter(:compose_pdf, '%PDF-A')
    }
  end

  it 'validates the XML once before composing the PDF' do
    expect([attach.call(pdf: '%PDF', xml: '<xml/>'), events]).to eq(['%PDF-A', expected_events])
  end

  it 'does not compose when XML validation fails' do
    adapters.fetch(:xml_verifier).error = Facturx::InvalidXmlError.new('invalid XML')

    expect { attach.call(pdf: '%PDF', xml: '<xml/>') }.to raise_error(Facturx::InvalidXmlError)
      .and change(events, :dup).from([]).to([[:verify_xml, [], { xml: '<xml/>' }]])
  end

  def adapter(name, result)
    adapter_class.new(events, name, result)
  end

  def expected_events
    [
      [:verify_xml, [], { xml: '<xml/>' }],
      [:compose_pdf, [], { pdf: '%PDF', xml: '<xml/>', profile: }]
    ]
  end
end
