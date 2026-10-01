# frozen_string_literal: true

require 'eu_einvoice/pdf/embedding'

module EuEinvoice
  module France
    EMBEDDING = Pdf::Embedding.new(
      filename: 'factur-x.xml', relationship: :Alternative, document_type: 'INVOICE', version: '1.0',
      accepted_relationships: %i[Alternative Data],
      xmp_namespace: 'urn:factur-x:pdfa:CrossIndustryDocument:invoice:1p0#'
    )
  end
end
