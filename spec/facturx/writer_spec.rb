# frozen_string_literal: true

require 'spec_helper'
require_relative 'writer/support/document_factory'

RSpec.describe Facturx::Writer do
  subject(:writer) { described_class.new }

  describe '#call' do
    context 'with no document guideline' do
      subject(:xml) { writer.call(document: minimum_document, profile: minimum_profile) }

      let(:minimum_profile) { Facturx::Profiles.fetch(:minimum) }
      let(:minimum_document) do
        reading = Facturx::Reader.new.call(File.binread('spec/fixtures/xml/minimum.xml'))
        address = Facturx::Address.new(country_code: 'FR')
        reading.document.with(guideline_urn: nil, seller: reading.document.seller.with(address: address))
      end

      it 'writes UTF-8 XML' do
        expect(xml).to have_attributes(encoding: Encoding::UTF_8)
      end

      it 'uses the canonical guideline default' do
        expect(xml).to include(minimum_profile.guideline_urn)
      end

      it 'writes schema-valid XML that reads back to the document' do
        expect(Facturx::Reader.new.call(xml).document).to eq(
          minimum_document.with(guideline_urn: minimum_profile.guideline_urn)
        )
      end
    end

    context 'with every modeled EN16931 term' do
      let(:profile) { Facturx::Profiles.fetch(:en16931) }
      let(:document) { WriterDocumentFactory.complete_document(profile) }
      let(:reading) { Facturx::Reader.new.call(writer.call(document: document, profile: profile)) }

      it 'reads every term back' do
        expect(reading.document).to eq(document)
      end

      it 'produces no reader diagnostic' do
        expect(reading.diagnostics).to be_empty
      end
    end

    context 'with documents mapped from official profile fixtures' do
      subject(:xml_documents) do
        profile_ids.map do |profile_id|
          writer.call(document: WriterDocumentFactory.conforming_fixture_document(profile_id),
                      profile: Facturx::Profiles.fetch(profile_id))
        end
      end

      let(:profile_ids) { %i[minimum basic_wl basic en16931 extended] }

      it 'writes every Factur-X profile' do
        expect(xml_documents).to all(start_with('<?xml version="1.0" encoding="UTF-8"?>'))
      end
    end

    context 'with repeated credit transfers' do
      let(:profile) { Facturx::Profiles.fetch(:en16931) }
      let(:document) do
        original = WriterDocumentFactory.complete_document(profile)
        first = original.payment.credit_transfers.first
        second = first.with(
          account_identifier: Facturx::Identifier.new(value: 'FR769999'),
          provider_identifier: Facturx::Identifier.new(value: 'BIC-2')
        )
        original.with(payment: original.payment.with(credit_transfers: [first, second]))
      end
      let(:xml) { writer.call(document: document, profile: profile) }
      let(:payment_nodes) do
        Nokogiri::XML(xml).xpath(
          '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans',
          Facturx::Xml::Namespaces::MAP
        )
      end

      it 'writes separate CII payment means' do
        expect(payment_nodes.size).to eq(2)
      end

      it 'repeats the payment means code' do
        expect(payment_nodes.xpath('./ram:TypeCode', Facturx::Xml::Namespaces::MAP).map(&:text))
          .to eq(%w[58 58])
      end

      it 'writes each payee account' do
        expect(payment_nodes.xpath('.//ram:PayeePartyCreditorFinancialAccount/ram:IBANID',
                                   Facturx::Xml::Namespaces::MAP).map(&:text)).to eq(%w[FR761234 FR769999])
      end

      it 'writes each provider identifier' do
        expect(payment_nodes.xpath('.//ram:BICID', Facturx::Xml::Namespaces::MAP).map(&:text))
          .to eq(%w[BIC BIC-2])
      end

      it 'writes the card only once' do
        expect(payment_nodes.xpath('.//ram:ApplicableTradeSettlementFinancialCard',
                                   Facturx::Xml::Namespaces::MAP).size).to eq(1)
      end

      it 'writes the debtor account only once' do
        expect(payment_nodes.xpath('.//ram:PayerPartyDebtorFinancialAccount',
                                   Facturx::Xml::Namespaces::MAP).size).to eq(1)
      end

      it 'reads each credit transfer back' do
        transfers = Facturx::Reader.new.call(xml).document.payment.credit_transfers

        expect(transfers.map { |transfer| transfer.account_identifier.value }).to eq(%w[FR761234 FR769999])
      end

      it 'produces no reader diagnostic' do
        expect(Facturx::Reader.new.call(xml).diagnostics).to be_empty
      end
    end

    context 'with empty optional objects' do
      let(:profile) { Facturx::Profiles.fetch(:en16931) }
      let(:document) do
        original = WriterDocumentFactory.complete_document(profile)
        seller = original.seller.with(contact: Facturx::Contact.new)
        original.with(seller: seller, project_reference: Facturx::DocumentReference.new)
      end
      let(:parsed) { Nokogiri::XML(writer.call(document: document, profile: profile)) }

      it 'omits the empty contact wrapper' do
        expect(parsed.at_xpath('//ram:SellerTradeParty/ram:DefinedTradeContact',
                               Facturx::Xml::Namespaces::MAP)).to be_nil
      end

      it 'omits the empty project wrapper' do
        expect(parsed.at_xpath('//ram:SpecifiedProcuringProject', Facturx::Xml::Namespaces::MAP)).to be_nil
      end
    end

    context 'with unrepresentable optional values' do
      let(:profile) { Facturx::Profiles.fetch(:en16931) }
      let(:document) { WriterDocumentFactory.complete_document(profile) }

      it 'reports a project reference without an identifier before XSD validation' do
        invalid_document = document.with(project_reference: Facturx::DocumentReference.new(name: 'Project'))

        expect { writer.call(document: invalid_document, profile:) }
          .to raise_error(Facturx::ConformanceError) do |error|
            expect(error.details.fetch(:report).issues).to include(have_attributes(term_id: 'BT-11'))
          end
      end

      it 'reports a gross price without an amount before XSD validation' do
        line = document.lines.first.with(gross_price: Facturx::Price.new(basis_quantity: document.lines.first.quantity))
        invalid_document = document.with(lines: [line])

        expect { writer.call(document: invalid_document, profile:) }
          .to raise_error(Facturx::ConformanceError) do |error|
            expect(error.details.fetch(:report).issues).to include(have_attributes(term_id: 'BT-148'))
          end
      end
    end
  end

  describe '#validate' do
    let(:minimum_profile) { Facturx::Profiles.fetch(:minimum) }
    let(:minimum_document) do
      reading = Facturx::Reader.new.call(File.binread('spec/fixtures/xml/minimum.xml'))
      address = Facturx::Address.new(country_code: 'FR')
      reading.document.with(guideline_urn: nil, seller: reading.document.seller.with(address: address))
    end
    let(:invalid_document) { minimum_document.with(invoice_number: nil) }

    it 'returns the aggregate report without raising' do
      expect(writer.validate(document: invalid_document, profile: minimum_profile)).to have_attributes(
        invalid?: true, issues: include(have_attributes(code: :missing_required_term, term_id: 'BT-1'))
      )
    end

    it 'reports an explicit guideline mismatch' do
      basic_guideline = Facturx::Profiles.fetch(:basic).guideline_urn
      report = writer.validate(document: minimum_document.with(guideline_urn: basic_guideline),
                               profile: minimum_profile)

      expect(report.issues.select { |issue| issue.code == :profile_mismatch })
        .to contain_exactly(have_attributes(term_id: 'BT-24'))
    end

    context 'when the document is invalid' do
      let(:conformance_error) do
        writer.call(document: invalid_document, profile: minimum_profile)
      rescue Facturx::ConformanceError => e
        e
      end

      it 'raises before XSD validation' do
        expect { writer.call(document: invalid_document, profile: minimum_profile) }
          .to raise_error(Facturx::ConformanceError)
      end

      it 'exposes the aggregate report' do
        expect(conformance_error.details.fetch(:report).invalid?).to be(true)
      end
    end
  end

  describe 'stage coverage' do
    it 'covers every modeled term' do
      expect(described_class::MODELED_TERM_IDS).to match_array(Facturx::Terms.all.map(&:id))
    end

    it 'covers all 184 modeled EN16931 terms' do
      expect(described_class::MODELED_TERM_IDS.size).to eq(184)
    end
  end
end
