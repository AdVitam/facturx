# EuEinvoice

Ruby invoice objects and a single client for explicit European document specifications. The first implementation builds, reads and validates **Factur-X 1.09.2 / ZUGFeRD 2.5.2**, including PDF/A-3 composition from an existing PDF.

Country packs, XML syntaxes, PDF containers, validation engines and Rails integration are separate packages. UBL, Peppol and network transports are roadmap items, not implemented capabilities.

## Install

```ruby
gem 'eu-einvoice', require: 'eu_einvoice'
# Country extension:
gem 'eu-einvoice-fr', require: 'eu_einvoice/fr'
# Optional full validation:
gem 'eu-einvoice-validation-fr', require: 'eu_einvoice/validation/fr'
# Optional:
gem 'eu-einvoice-rails', require: 'eu_einvoice/rails'
```

`eu-einvoice` is the central library and owns the public `EuEinvoice::Client` API. `eu-einvoice-fr` is a country extension depending on that core; it supplies French specifications and assembles the shared CII/PDF adapters. It is not a separate standalone invoicing library. Neither package depends on Rails or the validation companion. Ruby 3.2–4.0 is supported; Rails integration targets 7.2, 8.0 and 8.1 on compatible Ruby versions.

Full validation requires SaxonC-HE 12.10+ (`Transform`). PDF composition requires Ghostscript 9.54+, `zugferd.ps` and an RGB ICC profile. Schemas and rules are bundled; engines are provisioned by the application. No runtime artifact downloads occur.

## Configure once

```ruby
require 'eu_einvoice'
require 'eu_einvoice/fr'

pack = EuEinvoice::France::Pack.new(version: '1.09.2')
client = EuEinvoice::Client.new(
  packs: [pack],
  policy: pack.policy(profile: :en16931),
  validation: :full
)
```

This policy explicitly selects the pinned Factur-X EN 16931 specification for a France-to-France document. It does not classify the customer or determine fiscal obligations. Other country pairs need an explicit configured preference or specification.

`validation: :full` is the default. Use `:structural` explicitly to run without the Schematron companion; reports then identify the reduced coverage. Loading the companion never changes existing clients.

## Build and generate

```ruby
document = EuEinvoice::Document.build do |invoice|
  invoice.invoice_number = 'INV-2026-001'
  invoice.issue_date = Date.new(2026, 9, 15)
  invoice.type_code = EuEinvoice::Codes::DocumentType::INVOICE
  invoice.currency = 'EUR'

  invoice.seller do |seller|
    seller.name = 'Seller'
    seller.legal_registration = EuEinvoice::Identifier.new(value: '552100554', scheme_id: '0002')
    seller.address { |address| address.country_code = 'FR' }
  end

  invoice.buyer { |buyer| buyer.name = 'Buyer' }

  invoice.totals do |totals|
    totals.tax_basis_total = BigDecimal('100.00')
    totals.tax_total = BigDecimal('20.00')
    totals.grand_total = BigDecimal('120.00')
    totals.due_payable = BigDecimal('120.00')
  end
end

# MINIMUM is selected explicitly for this deliberately small example.
specification = pack.specification(profile: :minimum)
xml = client.build_xml(document: document, specification: specification)
pdf = client.generate(document: document, specification: specification, pdf: rendered_pdf_bytes)

xml.bytes      # immutable XML bytes
pdf.to_io      # independent readable StringIO
pdf.report     # validation coverage and specification provenance
```

The application supplies the visual PDF. The library does not render HTML or calculate totals. EN 16931 invoices require the additional business data for that profile.

## Read and validate

```ruby
reading = client.read(xml_or_pdf_bytes)
reading.document
reading.source       # exact extracted/original XML bytes
reading.diagnostics  # values not represented, unknown profiles, coercion issues

report = client.validate_xml(xml: xml_bytes)
report.valid?        # no errors in requested checks
report.complete?     # full validation stages executed, independently of validity
report.resources
```

Reading is tolerant and never certifies an invoice. Multiple matching artifact versions are an explicit ambiguity. Unknown profiles are not relabeled as EXTENDED. Passing a `Reading` with diagnostics back to a writer requires an explicit `allow_loss: true` decision.

## Rails

```ruby
# config/initializers/eu_einvoice.rb
pack = EuEinvoice::France::Pack.new
Rails.application.config.eu_einvoice.register(
  :invoices, packs: [pack], policy: pack.policy, validation: :full
)

# Application service/controller:
client = Rails.application.config.eu_einvoice[:invoices]
artifact = client.generate(document: mapped_invoice, pdf: rendered_pdf_bytes)
record.invoice.attach(EuEinvoice::Rails::ActiveStorage.attachable(artifact))
```

Mapping stays in an explicit application service. No automatic model callbacks or persistence are installed. Both format and framework APIs work with bytes and IO; private temporary files may be used internally by external engines.

## Application responsibility

Customer facts, transaction classification, visual rendering, totals, storage, remote directory lookup, platform submission and reporting remain application responsibilities. SIREN/SIRET helpers check local structure; they do not establish an active receiving address.

See [API and Rails recipes](DOCUMENTATION.md), [architecture and ADRs](docs/architecture/README.md), [roadmap](docs/architecture/roadmap.md) and [release procedure](docs/architecture/release.md). Historical changes remain in [CHANGELOG.md](CHANGELOG.md).
