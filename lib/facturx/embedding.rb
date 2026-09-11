# frozen_string_literal: true

module Facturx
  Embedding = Data.define(:filename, :relationship, :document_type, :version, :xmp_namespace)

  FACTURX_EMBEDDING = Embedding.new(
    filename: 'factur-x.xml',
    relationship: :Alternative,
    document_type: 'INVOICE',
    version: '1.0',
    xmp_namespace: 'urn:factur-x:pdfa:CrossIndustryDocument:invoice:1p0#'
  )

  private_constant :Embedding, :FACTURX_EMBEDDING
end
