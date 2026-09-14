# frozen_string_literal: true

require 'open3'
require 'rbconfig'

RSpec.describe Facturx do
  let(:public_constants) do
    %w[
      Address AllowanceCharge ComposerUnavailableError CompositionError Contact CreditTransfer Delivery
      Diagnostic DirectDebit Document DocumentReference Error ExtractionError Identifier InvalidDocumentError
      InvalidPdfError InvalidSourceError InvalidXmlError Line Note Party PaymentCard PaymentInstructions Period
      Price Product ProductAttribute ProductClassification Profile Profiles ProtectedPdfError Quantity Reading
      SchemaLoadError SupportingDocument TaxBreakdown Totals UnknownProfileError UnsupportedProfileError Validation
      ValidationError VerificationError VERSION XsdValidationError
    ].sort
  end
  let(:public_methods) { %w[attach build_xml extract_xml generate read validate_document validate_xml] }

  it 'exports only the supported constants' do
    exported = ruby_eval("require 'facturx'; print Facturx.constants(false).sort.join(',')")

    expect(exported.split(',')).to eq(public_constants)
  end

  it 'exports only the supported facade methods' do
    exported = ruby_eval("require 'facturx'; print Facturx.singleton_methods(false).sort.join(',')")

    expect(exported.split(',')).to eq(public_methods)
  end

  it 'keeps profile registry constants private' do
    exported = ruby_eval("require 'facturx'; print Facturx::Profiles.constants(false).sort.join(',')")

    expect(exported).to be_empty
  end

  it 'exports only validation result types from the validation namespace' do
    exported = ruby_eval("require 'facturx'; print Facturx::Validation.constants(false).sort.join(',')")

    expect(exported.split(',')).to eq(%w[Issue Report])
  end

  def ruby_eval(source)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-I#{File.expand_path('../lib', __dir__)}",
                                            '-e', source)
    raise stderr unless status.success?

    stdout
  end
end
