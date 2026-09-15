# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EuEinvoice::Codes do
  let(:codedb) do
    path = 'gems/eu-einvoice-validation-fr/lib/eu_einvoice/schematron/rules/1.09.2/en16931/FACTUR-X_EN16931_codedb.xml'
    Nokogiri::XML(File.binread(path))
  end

  { DocumentType: 2, PaymentMeans: 25, VatCategory: 10 }.each do |type, list_id|
    it "exposes #{type} values contained in the official bundled code list" do
      helpers = described_class.const_get(type)
      values = helpers.constants.map { |name| helpers.const_get(name) }
      official = codedb.xpath("/codedb/cl[@id='#{list_id}']/enumeration/@value").map(&:value)
      expect(values - official).to be_empty
    end
  end
end
