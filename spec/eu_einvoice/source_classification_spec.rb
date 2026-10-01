# frozen_string_literal: true

RSpec.describe EuEinvoice::Source do
  it 'does not mistake an XML comment for a PDF header' do
    expect(described_class.pdf?("\xEF\xBB\xBF\n<!-- %PDF-1.7 --><invoice/>".b)).to be(false)
  end

  it 'recognizes a PDF header after a permitted byte prefix' do
    expect(described_class.pdf?("prefix\n%PDF-1.7\n".b)).to be(true)
  end

  it 'preserves XML classification in the standalone reader' do
    bytes = "<!-- %PDF-1.7 -->#{File.binread('spec/fixtures/xml/en16931.xml').sub(/<\?xml.*?\?>/, '')}"

    expect(EuEinvoice::SourceReader.new.call(bytes).source_type).to eq(:xml)
  end

  it 'reads valid invoice XML mentioning PDF through the public client' do
    pack = EuEinvoice::France::Pack.new
    client = EuEinvoice::Client.new(packs: [pack], validation: :structural)
    xml = File.binread('spec/fixtures/xml/en16931.xml').sub('?>', '?><!-- %PDF-1.7 -->')

    expect(client.read(xml).source_type).to eq(:xml)
  end
end
