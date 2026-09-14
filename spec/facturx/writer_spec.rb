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

    %i[minimum basic_wl basic en16931 extended].each do |profile_id|
      context "with every modeled #{profile_id} term" do
        let(:profile) { Facturx::Profiles.fetch(profile_id) }
        let(:document) { WriterDocumentFactory.maximal_document(profile) }
        let(:xml) { writer.call(document:, profile:) }
        let(:reading) { Facturx::Reader.new.call(xml) }

        it 'emits every modeled term representation' do
          expect(missing_term_ids(xml, profile)).to be_empty
        end

        it 'passes profile XSD validation' do
          expect(Facturx.validate_xml(xml:)).to be_valid
        end

        it 'reads every represented value back' do
          expect(reading.document).to eq(document)
        end

        it 'produces no reader diagnostic' do
          expect(reading.diagnostics).to be_empty
        end
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

    context 'with MINIMUM accounting currency tax' do
      let(:profile) { Facturx::Profiles.fetch(:minimum) }
      let(:document) { WriterDocumentFactory.maximal_document(profile) }
      let(:xml) { writer.call(document:, profile:) }

      it 'carries BT-111 currency without emitting forbidden BT-6' do
        expect(minimum_tax_currency_projection(xml)).to eq([nil, %w[EUR USD]])
      end

      it 'rejects isolated tax currency metadata as forbidden BT-6' do
        totals = document.totals.with(tax_total_in_tax_currency: nil)

        expect { writer.call(document: document.with(totals:), profile:) }
          .to raise_invalid_document_for('BT-6', code: :forbidden_term)
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

    context 'with global seller identifiers' do
      let(:profile) { Facturx::Profiles.fetch(:en16931) }
      let(:identifiers) do
        [
          Facturx::Identifier.new(value: 'SELLER-ONE', scheme_id: '0088'),
          Facturx::Identifier.new(value: 'SELLER-TWO', scheme_id: '0060')
        ]
      end
      let(:document) do
        original = WriterDocumentFactory.complete_document(profile)
        original.with(seller: original.seller.with(identifiers:))
      end

      it 'keeps each global identifier scheme on round trip' do
        reading = Facturx::Reader.new.call(writer.call(document:, profile:))

        expect(reading.document.seller.identifiers).to eq(identifiers)
      end

      it 'reports a scheme-only global identifier' do
        identifier = Facturx::Identifier.new(scheme_id: '0088')
        invalid = document.with(seller: document.seller.with(identifiers: [identifier]))

        expect { writer.call(document: invalid, profile:) }
          .to raise_invalid_document_for('BT-29', code: :invalid_value)
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

        expect { writer.call(document: invalid_document, profile:) }.to raise_invalid_document_for('BT-11')
      end

      it 'reports a gross price without an amount before XSD validation' do
        expect { writer.call(document: unrepresentable_gross_price_document, profile:) }
          .to raise_invalid_document_for('BT-148')
      end

      it 'reports an attachment qualifier without content' do
        expect { writer.call(document: document_with_attachment_qualifier, profile:) }
          .to raise_invalid_document_for('BT-125-1', code: :invalid_value)
      end

      it 'reports a classification qualifier without a code' do
        expect { writer.call(document: document_with_classification_qualifier, profile:) }
          .to raise_invalid_document_for('BT-158-1', code: :invalid_value)
      end

      it 'reports a quantity unit without a value' do
        expect { writer.call(document: document_with_quantity_unit, profile:) }
          .to raise_invalid_document_for('BT-130', code: :invalid_value)
      end

      it 'reports an identifier scheme without a value' do
        expect { writer.call(document: document_with_payee_identifier_scheme, profile:) }
          .to raise_invalid_document_for('BT-61-1', code: :invalid_value)
      end

      it 'reports a delivery identifier scheme without a value' do
        expect { writer.call(document: document_with_delivery_identifier_scheme, profile:) }
          .to raise_invalid_document_for('BT-71-1', code: :invalid_value)
      end

      it 'reports a header invoiced object scheme without a value' do
        expect { writer.call(document: document_with_header_invoiced_object_scheme, profile:) }
          .to raise_invalid_document_for('BT-18-1', code: :invalid_value)
      end

      it 'reports a line invoiced object scheme without a value' do
        expect { writer.call(document: document_with_line_invoiced_object_scheme, profile:) }
          .to raise_invalid_document_for('BT-128-1', code: :invalid_value)
      end

      it 'reports a credit transfer account scheme' do
        expect { writer.call(document: document_with_credit_transfer_scheme, profile:) }
          .to raise_invalid_document_for('BT-84', code: :invalid_value)
      end

      it 'reports a noncanonical tax registration scheme' do
        expect { writer.call(document: document_with_tax_registration_scheme, profile:) }
          .to raise_invalid_document_for('BT-31', code: :invalid_value)
      end

      it 'uses the identifier as a project name when the supplied name is blank' do
        id_only_document = document.with(
          project_reference: Facturx::DocumentReference.new(id: 'PROJECT', name: ' ')
        )

        expect(project_reference_for(id_only_document)).to have_attributes(id: 'PROJECT', name: 'PROJECT')
      end

      it 'uses VAT for blank tax type codes' do
        expect(tax_type_codes(writer.call(document: blank_tax_type_document, profile:))).to match_array(
          Array.new(4, 'VAT')
        )
      end

      it 'omits references without their identifiers' do
        expect(orphan_references(writer.call(document: document_without_reference_values, profile:))).to be_empty
      end

      it 'reports a tax total without a tax currency' do
        invalid_document = document.with(tax_currency: nil)

        expect { writer.call(document: invalid_document, profile:) }
          .to raise_invalid_document_for('BT-111', code: :invalid_value)
      end

      it 'reports a tax total in the invoice currency' do
        expect { writer.call(document: same_currency_tax_total_document, profile:) }
          .to raise_invalid_document_for('BT-111', code: :invalid_value)
      end

      it 'reports a payee VAT identifier unsupported by its group' do
        expect { writer.call(document: payee_with_vat_document, profile:) }
          .to raise_unrepresentable_attribute('BG-10', :party, :vat_identifier)
      end

      it 'reports a ship-to VAT identifier unsupported by its group' do
        expect { writer.call(document: ship_to_with_vat_document, profile:) }
          .to raise_unrepresentable_attribute('BG-13', :party, :vat_identifier)
      end

      it 'accepts a ship-to location without a party' do
        expect { writer.call(document: document_with_ship_to_location, profile:) }.not_to raise_error
      end

      it 'keeps supported seller attributes valid' do
        expect { writer.call(document:, profile:) }.not_to raise_error
      end

      it 'reports unrepresentable direct reference attributes' do
        expect { writer.call(document: document_with_reference_name, profile:) }
          .to raise_invalid_document_for('BT-14', code: :invalid_value)
      end

      it 'reports an identifier on a line buyer order reference' do
        expect { writer.call(document: document_with_line_buyer_order_identifier, profile:) }
          .to raise_invalid_document_for('BT-132', code: :invalid_value)
      end

      it 'reports unrepresentable project reference attributes' do
        expect { writer.call(document: document_with_project_reference_attributes, profile:) }
          .to raise_invalid_document_for('BT-11', code: :invalid_value)
      end

      it 'reports a net price discount' do
        expect { writer.call(document: document_with_net_discount, profile:) }
          .to raise_unrepresentable_attribute('BG-29', :price, :discount)
      end

      it 'reports an adjustment tax amount' do
        expect { writer.call(document: document_with_adjustment_tax_amount, profile:) }
          .to raise_unrepresentable_attribute('BG-20', :tax_breakdown, :tax_amount)
      end

      it 'reports a line tax amount' do
        expect { writer.call(document: document_with_line_tax_amount, profile:) }
          .to raise_unrepresentable_attribute('BG-30', :tax_breakdown, :tax_amount)
      end

      it 'reports a line allowance tax' do
        expect { writer.call(document: document_with_line_allowance_tax, profile:) }
          .to raise_unrepresentable_attribute('BG-27', :tax_breakdown, :category_code)
      end

      it 'reports a VAT point date without a tax breakdown' do
        expect { writer.call(document: document_without_tax_breakdowns, profile:) }
          .to raise_unrepresentable_attribute('BG-23', :document, :vat_point_date)
      end

      it 'reports a VAT point date code without a tax breakdown' do
        expect { writer.call(document: document_without_tax_breakdowns, profile:) }
          .to raise_unrepresentable_attribute('BG-23', :document, :vat_point_date_code)
      end

      it 'reports a VAT point date code conflicting with a tax breakdown' do
        expect { writer.call(document: document_with_conflicting_vat_point_code, profile:) }
          .to raise_unrepresentable_attribute('BG-23', :document, :vat_point_date_code)
      end

      it 'preserves distinct due date type codes after the first tax breakdown' do
        tax_codes = round_trip(document_with_distinct_tax_due_date_codes)
                    .tax_breakdowns.map(&:due_date_type_code)

        expect(tax_codes).to eq(%w[5 72])
      end

      it 'classifies a header charge moved to allowances as an allowance' do
        expect(header_allowance_after_round_trip).to have_attributes(indicator: false)
      end

      it 'classifies a line charge moved to allowances as an allowance' do
        expect(line_allowance_after_round_trip).to have_attributes(indicator: false)
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
      let(:validation_error) do
        writer.call(document: invalid_document, profile: minimum_profile)
      rescue Facturx::InvalidDocumentError => e
        e
      end

      it 'raises before XSD validation', :aggregate_failures do
        schema_validator = instance_spy(Facturx::Xml::SchemaValidator)
        local_writer = described_class.new(schema_validator:)

        expect { local_writer.call(document: invalid_document, profile: minimum_profile) }
          .to raise_error(Facturx::InvalidDocumentError)
        expect(schema_validator).not_to have_received(:call)
      end

      it 'exposes the aggregate report' do
        expect(validation_error.details.fetch(:report).invalid?).to be(true)
      end
    end

    context 'when the generated XML violates the XSD' do
      let(:schema_validator) { instance_double(Facturx::Xml::SchemaValidator) }
      let(:writer) { described_class.new(schema_validator:) }

      before do
        allow(schema_validator).to receive(:call).and_raise(xsd_error)
      end

      it 'returns the structural issue from validation', :aggregate_failures do
        report = writer.validate(document: minimum_document, profile: minimum_profile)

        expect(report).to have_attributes(profile: minimum_profile, invalid?: true)
        expect(report.issues).to contain_exactly(
          have_attributes(code: :xsd_violation, layer: :xsd, line: 12, column: 4)
        )
      end

      it 'raises the document error with the same report when writing', :aggregate_failures do
        report = writer.validate(document: minimum_document, profile: minimum_profile)

        expect { writer.call(document: minimum_document, profile: minimum_profile) }
          .to raise_error(Facturx::InvalidDocumentError) do |error|
            expect(error.details[:report]).to eq(report)
          end
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

  def raise_invalid_document_for(term_id, code: nil)
    raise_error(Facturx::InvalidDocumentError) do |error|
      issue = code ? have_attributes(code:, term_id:) : have_attributes(term_id:)
      expect(error.details.fetch(:report).issues).to include(issue)
    end
  end

  def xsd_error
    Facturx::XsdValidationError.new(
      'Invalid XSD', profile: :minimum,
                     errors: [{ message: 'Missing node', line: 12, column: 4, level: 2 }]
    )
  end

  def project_reference_for(document)
    xml = writer.call(document:, profile:)
    Facturx::Reader.new.call(xml).document.project_reference
  end

  def missing_term_ids(xml, profile)
    parsed = Nokogiri::XML(xml)
    Facturx::Terms.for_profile(profile).filter_map do |term|
      term.id if parsed.xpath(representative_xpath(term),
                              Facturx::Xml::Namespaces::MAP).empty?
    end
  end

  def minimum_tax_currency_projection(xml)
    settlement = Nokogiri::XML(xml).at_xpath(
      '//ram:ApplicableHeaderTradeSettlement', Facturx::Xml::Namespaces::MAP
    )
    namespaces = Facturx::Xml::Namespaces::MAP
    tax_currency = settlement.at_xpath('./ram:TaxCurrencyCode', namespaces)&.text
    currencies = settlement.xpath('.//ram:TaxTotalAmount/@currencyID', namespaces).map(&:value)
    [tax_currency, currencies]
  end

  def representative_xpath(term)
    return term.xpath.sub(%r{/ram:ID\z}, '/ram:GlobalID') if %w[BT-46 BT-60 BT-71].include?(term.id)

    term.xpath
  end

  def raise_unrepresentable_attribute(group_id, model, attribute)
    raise_error(Facturx::InvalidDocumentError) do |error|
      expect(error.details.fetch(:report).issues).to include(
        have_attributes(
          code: :unrepresentable_attribute,
          group_id:,
          details: { model:, attribute: }
        )
      )
    end
  end

  def unrepresentable_gross_price_document
    line = document.lines.first.with(
      gross_price: Facturx::Price.new(basis_quantity: document.lines.first.quantity)
    )
    document.with(lines: [line])
  end

  def document_with_attachment_qualifier
    attachment = document.supporting_documents.first.with(content: nil)
    document.with(supporting_documents: [attachment])
  end

  def document_with_classification_qualifier
    classification = Facturx::ProductClassification.new(list_id: 'STI')
    product = document.lines.first.product.with(classifications: [classification])
    line = document.lines.first.with(product:)
    document.with(lines: [line])
  end

  def document_with_quantity_unit
    line = document.lines.first.with(quantity: Facturx::Quantity.new(unit_code: 'C62'))
    document.with(lines: [line])
  end

  def document_with_payee_identifier_scheme
    identifier = Facturx::Identifier.new(scheme_id: '0002')
    document.with(payee: document.payee.with(legal_registration: identifier))
  end

  def document_with_delivery_identifier_scheme
    identifier = Facturx::Identifier.new(scheme_id: '0088')
    delivery = document.delivery.with(location_identifier: identifier, party: nil)
    document.with(delivery:)
  end

  def document_with_header_invoiced_object_scheme
    document.with(invoiced_object_identifier: Facturx::Identifier.new(scheme_id: 'OBJ'))
  end

  def document_with_line_invoiced_object_scheme
    line = document.lines.first.with(invoiced_object_identifier: Facturx::Identifier.new(scheme_id: 'OBJ'))
    document.with(lines: [line])
  end

  def document_with_credit_transfer_scheme
    transfer = document.payment.credit_transfers.first
    account = transfer.account_identifier.with(scheme_id: '0088')
    payment = document.payment.with(credit_transfers: [transfer.with(account_identifier: account)])
    document.with(payment:)
  end

  def document_with_tax_registration_scheme
    vat_identifier = document.seller.vat_identifier.with(scheme_id: 'XX')
    document.with(seller: document.seller.with(vat_identifier:))
  end

  def blank_tax_type_document
    document.with(
      tax_breakdowns: blank_tax_types(document.tax_breakdowns),
      allowances: blank_adjustment_tax_types(document.allowances),
      charges: blank_adjustment_tax_types(document.charges),
      lines: blank_line_tax_types
    )
  end

  def same_currency_tax_total_document
    document.with(
      tax_currency: document.currency,
      totals: document.totals.with(tax_total: BigDecimal('40'), tax_total_in_tax_currency: BigDecimal('44'))
    )
  end

  def payee_with_vat_document
    document.with(payee: document.payee.with(vat_identifier: Facturx::Identifier.new(value: 'FR123')))
  end

  def ship_to_with_vat_document
    party = document.delivery.party.with(vat_identifier: Facturx::Identifier.new(value: 'FR123'))
    document.with(delivery: document.delivery.with(party:))
  end

  def document_with_ship_to_location
    document.with(delivery: document.delivery.with(party: nil))
  end

  def document_with_reference_name
    document.with(sales_order_reference: document.sales_order_reference.with(name: 'Order'))
  end

  def document_with_line_buyer_order_identifier
    reference = document.lines.first.buyer_order_reference.with(id: 'ORDER')
    line = document.lines.first.with(buyer_order_reference: reference)
    document.with(lines: [line])
  end

  def document_with_project_reference_attributes
    reference = document.project_reference.with(line_id: '1', issue_date: Date.new(2026, 9, 1))
    document.with(project_reference: reference)
  end

  def document_with_net_discount
    line = document.lines.first.with(net_price: document.lines.first.net_price.with(discount: BigDecimal('5')))
    document.with(lines: [line])
  end

  def document_with_adjustment_tax_amount
    tax = document.allowances.first.tax.with(tax_amount: BigDecimal('5'))
    allowance = document.allowances.first.with(tax:)
    document.with(allowances: [allowance])
  end

  def document_with_line_tax_amount
    tax = document.lines.first.tax.with(tax_amount: BigDecimal('5'))
    line = document.lines.first.with(tax:)
    document.with(lines: [line])
  end

  def document_with_line_allowance_tax
    tax = Facturx::TaxBreakdown.new(category_code: 'S', rate: BigDecimal('20'))
    allowance = document.lines.first.allowances.first.with(tax:)
    line = document.lines.first.with(allowances: [allowance])
    document.with(lines: [line])
  end

  def document_without_tax_breakdowns
    document.with(tax_breakdowns: [])
  end

  def document_with_conflicting_vat_point_code
    tax = document.tax_breakdowns.first.with(due_date_type_code: 'XX')
    document.with(tax_breakdowns: [tax])
  end

  def document_with_distinct_tax_due_date_codes
    first = document.tax_breakdowns.first.with(due_date_type_code: '5')
    second = first.with(category_code: 'AA', due_date_type_code: '72')
    document.with(vat_point_date_code: '5', tax_breakdowns: [first, second])
  end

  def header_allowance_after_round_trip
    charge = document.charges.first
    adjusted = document.with(allowances: [charge], charges: [])
    round_trip(adjusted).allowances.first
  end

  def line_allowance_after_round_trip
    round_trip(document_with_line_charge_as_allowance).lines.first.allowances.first
  end

  def document_with_line_charge_as_allowance
    line = document.lines.first
    document.with(lines: [line.with(allowances: [line.charges.first], charges: [])])
  end

  def round_trip(document)
    Facturx::Reader.new.call(writer.call(document:, profile:)).document
  end

  def document_without_reference_values
    line = document.lines.first.with(invoiced_object_identifier: Facturx::Identifier.new)
    document.with(
      tender_or_lot_reference: Facturx::DocumentReference.new,
      invoiced_object_identifier: Facturx::Identifier.new,
      lines: [line]
    )
  end

  def blank_line_tax_types
    document.lines.map { |line| line.with(tax: blank_tax_type(line.tax)) }
  end

  def blank_adjustment_tax_types(adjustments)
    adjustments.map { |adjustment| adjustment.with(tax: blank_tax_type(adjustment.tax)) }
  end

  def blank_tax_types(taxes)
    taxes.map { |tax| blank_tax_type(tax) }
  end

  def blank_tax_type(tax)
    tax.with(type_code: ' ')
  end

  def tax_type_codes(xml)
    Nokogiri::XML(xml).xpath(
      '//ram:ApplicableTradeTax/ram:TypeCode | //ram:CategoryTradeTax/ram:TypeCode',
      Facturx::Xml::Namespaces::MAP
    ).map(&:text)
  end

  def orphan_references(xml)
    Nokogiri::XML(xml).xpath(
      '//ram:AdditionalReferencedDocument[ram:TypeCode="50" or ram:TypeCode="130"]',
      Facturx::Xml::Namespaces::MAP
    )
  end
end
