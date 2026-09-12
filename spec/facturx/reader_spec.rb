# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Facturx::Reader do
  subject(:reader) { described_class.new }

  let(:en16931_xml) { File.binread('spec/fixtures/xml/en16931.xml') }
  let(:minimum_xml) { File.binread('spec/fixtures/xml/minimum.xml') }
  let(:complete_en16931_xml) { with_tax_amounts(with_addresses(en16931_xml)) }
  let(:extended_with_extra_xml) do
    File.binread('spec/fixtures/xml/extended.xml').sub(
      '</rsm:ExchangedDocument>', '<ram:ExtensionValue>retained</ram:ExtensionValue></rsm:ExchangedDocument>'
    )
  end

  describe 'typed EN16931 values' do
    subject(:reading) { reader.call(complete_en16931_xml) }

    it 'returns reading metadata and the exact source' do
      expect(reading).to have_attributes(
        profile: Facturx::Profiles.fetch(:en16931), source_type: :xml, source: complete_en16931_xml, diagnostics: []
      )
    end

    it 'maps document values' do
      expect(reading.document).to have_attributes(
        invoice_number: 'F-2023-004', issue_date: Date.new(2023, 1, 1), currency: 'EUR'
      )
    end

    it 'maps composite values' do
      expected = Facturx::Quantity.new(value: BigDecimal('1'), unit_code: 'C62')
      expect(reading.document.lines.first.quantity).to eq(expected)
    end

    it 'does not retain Nokogiri nodes' do
      expect(reading.to_h.values.grep(Nokogiri::XML::Node)).to be_empty
    end
  end

  it 'reads every supported profile without implicit XSD validation' do
    readings = Dir['spec/fixtures/xml/*.xml'].map { |path| reader.call(File.binread(path)) }
    expect(readings.map { |reading| [reading.profile.id, reading.document.invoice_number] }).to eq(
      [[:basic, 'F-2023-003'], [:basic_wl, 'F-2023-002'], [:en16931, 'F-2023-004'],
       [:extended, 'F-2023-005'], [:minimum, 'F-2023-001']]
    )
  end

  it 'preserves repeating groups in XML order' do
    notes = '<ram:IncludedNote><ram:Content>First</ram:Content></ram:IncludedNote>' \
            '<ram:IncludedNote><ram:Content>Second</ram:Content></ram:IncludedNote>'
    xml = en16931_xml.sub('<rsm:ExchangedDocument>', "<rsm:ExchangedDocument>#{notes}")
    expect(reader.call(xml).document.notes.map(&:content)).to eq(%w[First Second])
  end

  it 'extracts a PDF before mapping its embedded XML' do
    extractor = instance_double(Facturx::Pdf::Extractor, call: extracted_result)
    reading = described_class.new(extractor:).call("prefix\n%PDF-1.7\n".b)
    expect(reading).to have_attributes(source_type: :pdf, document: have_attributes(invoice_number: 'F-2023-004'))
  end

  it 'falls back to the EN16931 intersection and diagnoses an unknown profile' do
    reading = reader.call(minimum_xml.sub('urn:factur-x.eu:1p0:minimum', 'urn:example:unknown'))
    expect(reading).to have_attributes(
      profile: Facturx::Profiles.fetch(:extended),
      diagnostics: include(have_attributes(code: :unknown_profile, term_id: 'BT-24'))
    )
  end

  it 'distinguishes a missing profile from an unknown profile' do
    xml = minimum_xml.sub(guideline_context_pattern, '')
    expect(reader.call(xml).diagnostics).to include(have_attributes(code: :missing_profile, term_id: 'BT-24'))
  end

  it 'raises the typed profile error when requested' do
    xml = minimum_xml.sub('urn:factur-x.eu:1p0:minimum', 'urn:example:unknown')
    expect { reader.call(xml, on_unknown_profile: :raise) }.to raise_error(Facturx::UnknownProfileError)
  end

  describe 'recoverable semantic defects' do
    subject(:diagnostics) { reader.call(defective_xml).diagnostics }

    it 'reports every defect class' do
      expect(diagnostics.map(&:code)).to include(
        :multiple_values, :invalid_value, :empty_value, :missing_required_term, :unmapped_element
      )
    end

    it 'bounds diagnostic values' do
      diagnostic = diagnostics.find { |entry| entry.code == :unmapped_element }
      expect(diagnostic.details.fetch(:value).bytesize).to eq(200)
    end
  end

  it 'diagnoses fields outside the mapped EN16931 intersection for EXTENDED' do
    expect(reader.call(extended_with_extra_xml)).to have_attributes(
      source: include('<ram:ExtensionValue>retained</ram:ExtensionValue>'),
      diagnostics: include(have_attributes(code: :unmapped_element))
    )
  end

  it 'keeps the absent net price discount nil' do
    expect(reader.call(complete_en16931_xml).document.lines.first.net_price.discount).to be_nil
  end

  it 'diagnoses a missing net price amount without creating a price model' do
    reading = reader.call(xml_without_net_price)
    expect([reading.document.lines.first.net_price, diagnostic_codes(reading, 'BT-146')])
      .to eq([nil, [:missing_required_term]])
  end

  it 'maps product classification codes as scalar values' do
    classification = reader.call(xml_with_product_classification).document.lines.first.product.classifications.first
    expect(classification).to have_attributes(code: '1234', list_id: 'STI', list_version_id: '1')
  end

  it 'does not mix local and global delivery identifiers' do
    identifiers = %w[local global].map do |kind|
      reader.call(xml_with_delivery_id(kind)).document.delivery.location_identifier
    end
    expect(identifiers).to eq([Facturx::Identifier.new(value: 'LOCAL'),
                               Facturx::Identifier.new(value: 'GLOBAL', scheme_id: '0088')])
  end

  it 'prefers a local delivery identifier while marking its global alternative' do
    reading = reader.call(xml_with_local_and_global_delivery_ids)
    expect([reading.document.delivery.location_identifier, unmapped_diagnostics?(reading)])
      .to eq([Facturx::Identifier.new(value: 'LOCAL'), false])
  end

  it 'reads BT-7 and BT-8 from the first tax breakdown without scalar diagnostics' do
    reading = reader.call(xml_with_two_tax_breakdowns)
    expect([reading.document.vat_point_date, reading.document.vat_point_date_code,
            vat_point_diagnostics?(reading.diagnostics)])
      .to eq([Date.new(2023, 1, 1), '35', false])
  end

  it 'keeps the first present BT-7 across tax breakdowns without unmapped diagnostics' do
    readings = [xml_with_two_tax_breakdowns(dates: %w[20230101 20230202]),
                xml_with_two_tax_breakdowns(dates: [nil, '20230202'])].map { |xml| reader.call(xml) }
    expect(readings.map { |reading| [reading.document.vat_point_date, unmapped_diagnostics?(reading)] }).to eq(
      [[Date.new(2023, 1, 1), false], [Date.new(2023, 2, 2), false]]
    )
  end

  it 'keeps the first present BT-8 after an empty first tax breakdown value' do
    reading = reader.call(xml_with_empty_tax_code)
    expect([reading.document.vat_point_date_code, tax_diagnostic_counts(reading), unmapped_diagnostics?(reading)])
      .to eq(['35', [0, 1, 0], false])
  end

  it 'emits each tax diagnostic once when the first breakdown is absent or malformed' do
    readings = [xml_without_header_tax, xml_with_empty_tax_code, xml_with_invalid_tax_date].map do |xml|
      reader.call(xml)
    end
    expect(readings.map { |reading| tax_diagnostic_counts(reading) }).to eq([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
  end

  it 'reports non-projected duplicate payment instructions without mapping the second type code' do
    diagnostics = reader.call(xml_with_two_payment_instructions).diagnostics

    expect([
             diagnostics.count { |diagnostic| diagnostic.code == :multiple_values && diagnostic.term_id == 'BG-16' },
             diagnostics.any? { |diagnostic| diagnostic.code == :unmapped_element && diagnostic.path.end_with?('/ram:TypeCode') }
           ]).to eq([1, true])
  end

  it 'reads a BASIC credit transfer without the EN16931-only provider identifier' do
    credit_transfer = reader.call(xml_with_basic_credit_transfer).document.payment.credit_transfers.first
    expect(credit_transfer).to have_attributes(
      account_identifier: Facturx::Identifier.new(value: 'FR761234'), provider_identifier: nil
    )
  end

  it 'maps a payment provider once for zero, one, or two credit transfers' do
    readings = [0, 1, 2].map { |count| reader.call(xml_with_credit_transfers(count)) }
    expect(readings.map { |reading| credit_transfer_attributes(reading) }).to eq(
      [[[], false], [[Facturx::Identifier.new(value: 'BIC')], false],
       [[Facturx::Identifier.new(value: 'BIC'), Facturx::Identifier.new(value: 'BIC')], false]]
    )
  end

  it 'maps settlement payment fields without a payment means for BASIC WL and EN16931' do
    readings = [File.binread('spec/fixtures/xml/basic_wl.xml'), en16931_xml].map do |xml|
      reader.call(xml_with_settlement_payment_details(xml))
    end
    expect(readings.map { |reading| payment_without_means_attributes(reading) }).to eq(payment_without_means_expected)
  end

  it 'keeps BG-24 reference types exclusive' do
    document = reader.call(xml_with_references).document
    expect([document.tender_or_lot_reference.id, document.invoiced_object_identifier.value,
            document.supporting_documents.map(&:reference)]).to eq(['TENDER', 'OBJECT', ['SUPPORT']])
  end

  it 'does not require binary metadata for an external supporting document' do
    reading = reader.call(xml_with_references)
    expect(reading.diagnostics).not_to include(have_attributes(code: :missing_required_term, term_id: 'BT-125-1'))
  end

  it 'partitions header allowances and charges through their boolean indicator' do
    document = reader.call(xml_with_adjustments).document
    tax = Facturx::TaxBreakdown.new(category_code: 'S', rate: BigDecimal('20'))
    expect([[document.allowances.map(&:amount), document.charges.map(&:amount)],
            [document.allowances.first.tax, document.charges.first.tax]])
      .to eq([[[BigDecimal('5')], [BigDecimal('7')]], [tax, tax]])
  end

  it 'keeps line allowances and charges mapped when tax terms are absent from the registry' do
    document = reader.call(xml_with_line_adjustments).document

    expect([document.lines.first.allowances.first.amount, document.lines.first.charges.first.amount])
      .to eq([BigDecimal('5'), BigDecimal('7')])
  end

  it 'diagnoses an invalid allowance indicator without misclassifying it' do
    reading = reader.call(xml_with_adjustments(indicators: %w[yes]))
    expect(reading).to have_attributes(
      diagnostics: include(have_attributes(code: :invalid_value)),
      document: have_attributes(allowances: [], charges: [])
    )
  end

  it 'reports a missing adjustment indicator with its absolute group path' do
    expect(adjustment_indicator_diagnostic.path).to eq(missing_adjustment_indicator_path)
  end

  it 'maps gross price discounts only for an allowance indicator' do
    prices = [false, true, nil].map do |indicator|
      reader.call(xml_with_gross_price(indicator)).document.lines.first.gross_price
    end
    expect(prices.map(&:discount)).to eq([BigDecimal('5'), nil, nil])
  end

  it 'diagnoses a charge indicator inside a gross price discount' do
    reading = reader.call(xml_with_gross_price('true'))
    expect(reading.diagnostics).to include(have_attributes(code: :invalid_value, term_id: 'BT-147-02'))
  end

  it 'marks gross price allowance amounts before evaluating true or absent indicators' do
    readings = [true, nil].map { |indicator| reader.call(xml_with_gross_price(indicator)) }
    expect(readings.map { |reading| gross_price_discount_diagnostics(reading) }).to eq([[false, true], [false, false]])
  end

  it 'diagnoses a non-102 date format' do
    reading = reader.call(en16931_xml.sub('format="102"', 'format="610"'))
    expect(reading).to have_attributes(
      diagnostics: include(have_attributes(code: :invalid_value, term_id: 'BT-2')),
      document: have_attributes(issue_date: nil)
    )
  end

  it 'prioritizes an invalid format over an empty date value without leaving the format unmapped' do
    reading = reader.call(xml_with_empty_invalid_issue_date)
    expect(diagnostic_summary(reading, 'BT-2')).to eq([[:invalid_value], false])
  end

  it 'marks a quantity unit when its empty amount cannot be mapped' do
    reading = reader.call(xml_with_empty_quantity)
    expect([diagnostic_codes(reading, 'BT-129'), diagnostic_codes(reading, 'BT-130'), unmapped_diagnostics?(reading)])
      .to eq([[:empty_value], [], false])
  end

  it 'marks a reference scheme and type code when its identifier is empty' do
    reading = reader.call(xml_with_empty_invoiced_object_reference)
    expect(diagnostic_summary(reading, 'BT-18')).to eq([[:empty_value], false])
  end

  it 'sniffs byte strings independently from their declared encoding' do
    bytes = +'plain XML bytes'
    bytes.force_encoding(Encoding::UTF_16LE)
    expect(Facturx::SourceReader.new.call(bytes).source_type).to eq(:xml)
  end

  it 'sniffs PDF byte strings before normalizing their encoding' do
    source = (+'%PDF-1.7\\n').force_encoding(Encoding::UTF_16LE)
    extractor = instance_double(Facturx::Pdf::Extractor, call: extracted_result)

    expect(Facturx::SourceReader.new(extractor:).call(source).source_type).to eq(:pdf)
  end

  it 'rejects unsupported policies' do
    expect { reader.call(minimum_xml, on_unknown_profile: :ignore) }.to raise_error(ArgumentError)
  end

  it 'rejects non-CII XML' do
    expect { reader.call('<invoice/>'.b) }.to raise_error(Facturx::InvalidXmlError)
  end

  it 'rejects non-string sources' do
    expect { reader.call(StringIO.new(minimum_xml)) }.to raise_error(Facturx::InvalidXmlError)
  end

  def extracted_result
    Facturx::Pdf::Extractor::Result.new(
      xml: complete_en16931_xml, filename: nil, relationship: nil, metadata: nil, page_count: 1
    )
  end

  def vat_point_diagnostics?(diagnostics)
    diagnostics.any? { |item| item.code == :multiple_values && item.term_id.match?(/\ABT-[78]\z/) }
  end

  def tax_diagnostic_counts(reading)
    [%w[missing_required_term BG-23], %w[empty_value BT-8], %w[invalid_value BT-7]].map do |code, term_id|
      reading.diagnostics.count { |item| item.code == code.to_sym && item.term_id == term_id }
    end
  end

  def adjustment_indicator_diagnostic
    reader.call(xml_with_adjustment_without_indicator).diagnostics.find { |item| item.term_id == 'BG-20-1' }
  end

  def missing_adjustment_indicator_path
    '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement' \
      '/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator'
  end

  def payment_without_means_attributes(reading)
    payment = reading.document.payment
    [payment.remittance_information, payment.direct_debit, payment.means_code,
     reading.diagnostics.any? { |item| item.code == :unmapped_element && item.path.include?('Payment') }]
  end

  def payment_without_means_expected
    direct_debit = Facturx::DirectDebit.new(
      mandate_identifier: Facturx::Identifier.new(value: 'MANDATE'),
      creditor_identifier: Facturx::Identifier.new(value: 'CREDITOR')
    )
    [['REFERENCE', direct_debit, nil, false], ['REFERENCE', direct_debit, nil, false]]
  end

  def credit_transfer_attributes(reading)
    transfers = reading.document.payment.credit_transfers
    [transfers.map(&:provider_identifier), reading.diagnostics.any? { |item| item.term_id == 'BT-86' }]
  end

  def unmapped_diagnostics?(reading)
    reading.diagnostics.any? { |item| item.code == :unmapped_element }
  end

  def gross_price_discount_diagnostics(reading)
    diagnostics = reading.diagnostics
    [diagnostics.any? { |item| item.code == :unmapped_element && item.path.end_with?('/ram:ActualAmount') },
     diagnostics.any? { |item| item.code == :invalid_value && item.term_id == 'BT-147-02' }]
  end

  def diagnostic_summary(reading, term_id)
    [diagnostic_codes(reading, term_id), unmapped_diagnostics?(reading)]
  end

  def diagnostic_codes(reading, term_id)
    reading.diagnostics.filter_map { |item| item.code if item.term_id == term_id }
  end

  def defective_xml
    minimum_xml
      .sub('<ram:ID>F-2023-001</ram:ID>', '<ram:ID>F-2023-001</ram:ID><ram:ID>duplicate</ram:ID>')
      .sub('20230101', 'invalid-date')
      .sub('<ram:Name>Seller Company SAS</ram:Name>', '<ram:Name> </ram:Name>')
      .sub('<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>', "<ram:Unknown>#{'x' * 300}</ram:Unknown>")
  end

  def guideline_context_pattern
    %r{<ram:GuidelineSpecifiedDocumentContextParameter>.*?</ram:GuidelineSpecifiedDocumentContextParameter>}m
  end

  def with_addresses(xml)
    address = '<ram:PostalTradeAddress><ram:CountryID>FR</ram:CountryID></ram:PostalTradeAddress>'
    xml
      .sub('<ram:Name>Seller Company SAS</ram:Name>', "<ram:Name>Seller Company SAS</ram:Name>#{address}")
      .sub('<ram:Name>Buyer Company Ltd</ram:Name>', "<ram:Name>Buyer Company Ltd</ram:Name>#{address}")
  end

  def with_tax_amounts(xml)
    marker = '<ram:CategoryCode>S</ram:CategoryCode>'
    amounts = '<ram:BasisAmount>100.00</ram:BasisAmount><ram:CalculatedAmount>20.00</ram:CalculatedAmount>'
    xml.insert(xml.rindex(marker) + marker.bytesize, amounts)
  end

  def xml_with_product_classification
    classification = '<ram:DesignatedProductClassification>' \
                     '<ram:ClassCode listID="STI" listVersionID="1">1234</ram:ClassCode>' \
                     '</ram:DesignatedProductClassification>'
    en16931_xml.sub('<ram:Name>Product A</ram:Name>', "<ram:Name>Product A</ram:Name>#{classification}")
  end

  def xml_with_delivery_id(kind)
    identifier = kind == 'local' ? '<ram:ID>LOCAL</ram:ID>' : '<ram:GlobalID schemeID="0088">GLOBAL</ram:GlobalID>'
    delivery = "<ram:ApplicableHeaderTradeDelivery><ram:ShipToTradeParty>#{identifier}</ram:ShipToTradeParty>" \
               '</ram:ApplicableHeaderTradeDelivery>'
    complete_en16931_xml.sub('<ram:ApplicableHeaderTradeDelivery/>', delivery)
  end

  def xml_with_local_and_global_delivery_ids
    identifiers = '<ram:ID>LOCAL</ram:ID><ram:GlobalID schemeID="0088">GLOBAL</ram:GlobalID>'
    delivery = "<ram:ApplicableHeaderTradeDelivery><ram:ShipToTradeParty>#{identifiers}</ram:ShipToTradeParty>" \
               '</ram:ApplicableHeaderTradeDelivery>'
    complete_en16931_xml.sub('<ram:ApplicableHeaderTradeDelivery/>', delivery)
  end

  def xml_with_two_tax_breakdowns(dates: %w[20230101 20230101])
    tax = lambda do |category, date|
      tax_point = "<ram:TaxPointDate><udt:DateString format=\"102\">#{date}</udt:DateString></ram:TaxPointDate>" if date
      '<ram:ApplicableTradeTax><ram:TypeCode>VAT</ram:TypeCode>' \
        "<ram:CategoryCode>#{category}</ram:CategoryCode>" \
        "#{tax_point}" \
        '<ram:DueDateTypeCode>35</ram:DueDateTypeCode></ram:ApplicableTradeTax>'
    end
    marker = "<ram:ApplicableTradeTax>\n                <ram:TypeCode>VAT</ram:TypeCode>\n                " \
             "<ram:CategoryCode>S</ram:CategoryCode>\n            </ram:ApplicableTradeTax>"
    en16931_xml.sub(marker, "#{tax.call('S', dates[0])}#{tax.call('Z', dates[1])}")
  end

  def xml_without_header_tax
    en16931_xml.sub(header_tax_xml, '')
  end

  def xml_with_empty_tax_code
    xml_with_two_tax_breakdowns.sub('<ram:DueDateTypeCode>35</ram:DueDateTypeCode>', '<ram:DueDateTypeCode/>')
  end

  def xml_with_invalid_tax_date
    xml_with_two_tax_breakdowns.sub('<udt:DateString format="102">20230101',
                                    '<udt:DateString format="102">invalid-date')
  end

  def xml_with_empty_invalid_issue_date
    en16931_xml.sub('<udt:DateTimeString format="102">20230101</udt:DateTimeString>',
                    '<udt:DateTimeString format="610"></udt:DateTimeString>')
  end

  def xml_with_empty_quantity
    en16931_xml.sub('<ram:BilledQuantity unitCode="C62">1</ram:BilledQuantity>',
                    '<ram:BilledQuantity unitCode="C62"></ram:BilledQuantity>')
  end

  def xml_without_net_price
    en16931_xml.sub(%r{\s*<ram:NetPriceProductTradePrice>.*?</ram:NetPriceProductTradePrice>}m, '')
  end

  def header_tax_xml
    "<ram:ApplicableTradeTax>\n                <ram:TypeCode>VAT</ram:TypeCode>\n                " \
      "<ram:CategoryCode>S</ram:CategoryCode>\n            </ram:ApplicableTradeTax>"
  end

  def xml_with_two_payment_instructions
    payment = '<ram:SpecifiedTradeSettlementPaymentMeans><ram:TypeCode>58</ram:TypeCode>' \
              '</ram:SpecifiedTradeSettlementPaymentMeans>'
    marker = '<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>'
    complete_en16931_xml.sub(marker, "#{marker}#{payment}#{payment}")
  end

  def xml_with_settlement_payment_details(xml)
    payment = '<ram:PaymentReference>REFERENCE</ram:PaymentReference>' \
              '<ram:CreditorReferenceID>CREDITOR</ram:CreditorReferenceID>' \
              '<ram:SpecifiedTradePaymentTerms><ram:DirectDebitMandateID>MANDATE</ram:DirectDebitMandateID>' \
              '</ram:SpecifiedTradePaymentTerms>'
    marker = '<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>'
    xml.sub(marker, "#{marker}#{payment}")
  end

  def xml_with_credit_transfers(count)
    accounts = (1..count).map do |number|
      "<ram:PayeePartyCreditorFinancialAccount><ram:IBANID>ACCOUNT#{number}</ram:IBANID>" \
        '</ram:PayeePartyCreditorFinancialAccount>'
    end.join
    payment = '<ram:SpecifiedTradeSettlementPaymentMeans><ram:TypeCode>58</ram:TypeCode>' \
              '<ram:PayeeSpecifiedCreditorFinancialInstitution><ram:BICID>BIC</ram:BICID>' \
              "</ram:PayeeSpecifiedCreditorFinancialInstitution>#{accounts}</ram:SpecifiedTradeSettlementPaymentMeans>"
    marker = '<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>'
    en16931_xml.sub(marker, "#{marker}#{payment}")
  end

  def xml_with_references
    references = reference_xml('TENDER',
                               '50') + reference_xml('OBJECT', '130',
                                                     '<ram:ReferenceTypeCode>AA</ram:ReferenceTypeCode>') +
                 reference_xml('SUPPORT', '916', '<ram:URIID>https://example.test/invoice</ram:URIID>')
    complete_en16931_xml.sub('<ram:SellerTradeParty>', "#{references}<ram:SellerTradeParty>")
  end

  def xml_with_empty_invoiced_object_reference
    xml_with_references.sub('<ram:IssuerAssignedID>OBJECT</ram:IssuerAssignedID>', '<ram:IssuerAssignedID/>')
  end

  def xml_with_basic_credit_transfer
    payment = '<ram:SpecifiedTradeSettlementPaymentMeans><ram:TypeCode>58</ram:TypeCode>' \
              '<ram:PayeePartyCreditorFinancialAccount><ram:IBANID>FR761234</ram:IBANID>' \
              '</ram:PayeePartyCreditorFinancialAccount></ram:SpecifiedTradeSettlementPaymentMeans>'
    basic_xml = File.binread('spec/fixtures/xml/basic.xml')
    basic_xml.sub('<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>',
                  "<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>#{payment}")
  end

  def reference_xml(id, type_code, extra = '')
    '<ram:AdditionalReferencedDocument>' \
      "<ram:IssuerAssignedID>#{id}</ram:IssuerAssignedID>#{extra}<ram:TypeCode>#{type_code}</ram:TypeCode>" \
      '</ram:AdditionalReferencedDocument>'
  end

  def xml_with_adjustments(indicators: %w[false true])
    adjustments = indicators.zip(%w[5 7]).map { |indicator, amount| adjustment_xml(indicator, amount) }.join
    marker = '<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>'
    complete_en16931_xml.sub(marker, "#{marker}#{adjustments}")
  end

  def xml_with_adjustment_without_indicator
    adjustment = '<ram:SpecifiedTradeAllowanceCharge><ram:ActualAmount>5</ram:ActualAmount>' \
                 '</ram:SpecifiedTradeAllowanceCharge>'
    marker = '<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>'
    complete_en16931_xml.sub(marker, "#{marker}#{adjustment}")
  end

  def xml_with_line_adjustments
    adjustments = %w[false true].zip(%w[5 7]).map { |indicator, amount| line_adjustment_xml(indicator, amount) }.join
    marker = '<ram:SpecifiedTradeSettlementLineMonetarySummation>'
    en16931_xml.sub(marker, "#{adjustments}#{marker}")
  end

  def adjustment_xml(indicator, amount)
    '<ram:SpecifiedTradeAllowanceCharge>' \
      "<ram:ChargeIndicator><udt:Indicator>#{indicator}</udt:Indicator></ram:ChargeIndicator>" \
      "<ram:ActualAmount>#{amount}</ram:ActualAmount>" \
      '<ram:CategoryTradeTax><ram:TypeCode>VAT</ram:TypeCode><ram:CategoryCode>S</ram:CategoryCode>' \
      '<ram:RateApplicablePercent>20</ram:RateApplicablePercent></ram:CategoryTradeTax>' \
      '</ram:SpecifiedTradeAllowanceCharge>'
  end

  def line_adjustment_xml(indicator, amount)
    '<ram:SpecifiedTradeAllowanceCharge>' \
      "<ram:ChargeIndicator><udt:Indicator>#{indicator}</udt:Indicator></ram:ChargeIndicator>" \
      "<ram:ActualAmount>#{amount}</ram:ActualAmount>" \
      '<ram:CategoryTradeTax><ram:CategoryCode>S</ram:CategoryCode>' \
      '<ram:RateApplicablePercent>20</ram:RateApplicablePercent></ram:CategoryTradeTax>' \
      '</ram:SpecifiedTradeAllowanceCharge>'
  end

  def xml_with_gross_price(indicator)
    unless indicator.nil?
      charge_indicator = "<ram:ChargeIndicator><udt:Indicator>#{indicator}</udt:Indicator></ram:ChargeIndicator>"
    end
    gross_price = '<ram:GrossPriceProductTradePrice><ram:ChargeAmount>100</ram:ChargeAmount>' \
                  '<ram:AppliedTradeAllowanceCharge>' \
                  "#{charge_indicator}" \
                  '<ram:ActualAmount>5</ram:ActualAmount></ram:AppliedTradeAllowanceCharge>' \
                  '</ram:GrossPriceProductTradePrice>'
    en16931_xml.sub('<ram:NetPriceProductTradePrice>', "#{gross_price}<ram:NetPriceProductTradePrice>")
  end
end
