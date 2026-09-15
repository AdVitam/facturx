# typed: strict
# frozen_string_literal: true

# Static input only; runtime behavior is covered by the application integration specs.
invoice = EuEinvoice::Document.build(invoice_number: 'INV-123',
                                     type_code: EuEinvoice::Codes::DocumentType::INVOICE) do |builder|
  builder.buyer do |buyer|
    buyer.name = 'Customer'
    buyer.address(country_code: 'FR')
    buyer.electronic_address(value: '200034528', scheme_id: '0225')
  end
end
pack = EuEinvoice::France::Pack.new
specification = pack.specification
manifest = specification.manifest.merge(container: nil, licensing: { 'pack' => { 'LICENSE' => 'sha256' } })
specification.with(manifest:)
EuEinvoice::Validation::Context.new(source: '<invoice/>', representation: Object.new, syntax: :example)
client = EuEinvoice::Client.new(packs: [pack], policy: pack.policy, validation: :structural)
artifact = client.build_xml(document: invoice)
artifact.to_io.read
configuration = EuEinvoice::Rails::Configuration.new
configuration.register(:default, packs: [pack], validation: :structural)
provenance = EuEinvoice::RequirementProvenance.new(source: 'customer', observed_at: Time.utc(2026, 9, 15), version: '1')
requirements = EuEinvoice::RecipientRequirements.new(electronic_address_schemes: ['0225'], provenance:)
resolution = configuration[:default].resolve(document: invoice, requirements:)
resolution.diagnostics.map(&:code)
EuEinvoice::Rails::ActiveStorage.attachable(artifact)
EuEinvoice::France::Addressing.build(siret: '20003452800014').electronic_address
