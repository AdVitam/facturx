# frozen_string_literal: true

require 'facturx/builders'

RSpec.describe Facturx::Builders do
  describe Facturx::Document do
    subject(:document) do
      described_class.build(invoice_number: 'INV-42') do |invoice|
        invoice.seller(name: 'Seller')
        invoice.delivery do |delivery|
          delivery.date = Date.new(2026, 9, 12)
          delivery.party(name: 'Recipient')
        end
        invoice.line(id: '1')
      end
    end

    it 'builds an immutable document' do
      expect(document).to be_frozen
    end

    it 'sets scalar keyword attributes' do
      expect(document.invoice_number).to eq('INV-42')
    end

    it 'builds singular keyword associations' do
      expect(document.seller).to eq(Facturx::Party.new(name: 'Seller'))
    end

    it 'builds nested block associations' do
      expect(document.delivery.party.name).to eq('Recipient')
    end

    it 'builds collection items' do
      expect(document.lines).to eq([Facturx::Line.new(id: '1')])
    end

    it 'accepts exact immutable association objects' do
      seller = Facturx::Party.new(name: 'Seller')

      document = described_class.build { |invoice| invoice.seller(seller) }

      expect(document.seller).to equal(seller)
    end

    it 'rejects the wrong association model' do
      expect do
        described_class.build { |invoice| invoice.seller(Facturx::Address.new(city: 'Paris')) }
      end.to raise_error(TypeError, /immutable Facturx::Party/)
    end

    it 'rejects mutable uninitialized model objects' do
      expect do
        described_class.build { |invoice| invoice.seller(Facturx::Party.allocate) }
      end.to raise_error(TypeError, /immutable Facturx::Party/)
    end

    it 'rejects an object combined with keyword attributes' do
      seller = Facturx::Party.new(name: 'Seller')

      expect do
        described_class.build { |invoice| invoice.seller(seller, name: 'Other') }
      end.to raise_error(ArgumentError, /exactly one/)
    end

    it 'rejects keyword attributes combined with a block' do
      expect do
        described_class.build { |invoice| invoice.seller(name: 'Seller') { |_party| nil } }
      end.to raise_error(ArgumentError, /exactly one/)
    end

    it 'rejects an association call without an input form' do
      expect do
        described_class.build(&:seller)
      end.to raise_error(ArgumentError, /exactly one/)
    end

    it 'makes singular helpers write-once' do
      first = Facturx::Party.new(name: 'First')
      builder = Facturx::Builders::DocumentBuilder.new(seller: first)

      expect { builder.seller(name: 'Second') }.to raise_error(ArgumentError, /seller is already set/)
    end

    it 'lets explicit singular setters replace an association' do
      builder = Facturx::Builders::DocumentBuilder.new(seller: Facturx::Party.new(name: 'First'))
      replacement = Facturx::Party.new(name: 'Replacement')
      builder.seller = replacement

      expect(builder.build.seller).to equal(replacement)
    end

    it 'appends collection helpers in call order' do
      builder = Facturx::Builders::DocumentBuilder.new
      builder.line(id: '1')
      builder.line(Facturx::Line.new(id: '2'))

      expect(builder.build.lines.map(&:id)).to eq(%w[1 2])
    end

    it 'lets explicit collection setters replace prior items' do
      builder = Facturx::Builders::DocumentBuilder.new
      builder.line(id: '1')
      second = Facturx::Line.new(id: '2')
      builder.lines = [second]

      expect(builder.build.lines).to eq([second])
    end

    it 'does not retain mutable collection inputs' do
      lines = [Facturx::Line.new(id: '1')]
      builder = Facturx::Builders::DocumentBuilder.new(lines:)
      lines << Facturx::Line.new(id: '2')

      expect(builder.build.lines.map(&:id)).to eq(['1'])
    end

    it 'exposes a frozen empty collection snapshot' do
      builder = Facturx::Builders::DocumentBuilder.new
      line = Facturx::Line.new(id: '1')
      snapshot = builder.lines

      expect([snapshot, snapshot.frozen?, error_class { snapshot << line }]).to eq([[], true, FrozenError])
    end

    it 'does not expose its initialized collection storage' do
      builder = Facturx::Builders::DocumentBuilder.new
      line = Facturx::Line.new(id: '1')
      builder.line(line)
      snapshot = builder.lines

      expect([snapshot.frozen?, error_class { snapshot.clear }, builder.build.lines]).to eq([true, FrozenError, [line]])
    end
  end

  it 'defines a named builder for every model in the association schema' do
    Facturx::Builders::Schema::ASSOCIATIONS.each_key do |model|
      builder_name = "#{model.name.delete_prefix('Facturx::')}Builder"

      expect(described_class.const_get(builder_name)).to equal(described_class.for(model))
    end
  end

  def error_class
    yield
  rescue StandardError => e
    e.class
  end
end
