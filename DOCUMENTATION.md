# Facturx documentation

## Contents

- [Public API](#public-api)
- [Build an invoice](#build-an-invoice)
- [Use an existing XML invoice](#use-an-existing-xml-invoice)
- [Read a received invoice](#read-a-received-invoice)
- [Profiles](#profiles)
- [Validation](#validation)
- [PDF composition](#pdf-composition)
- [Round-trip guarantees](#round-trip-guarantees)
- [Security and resource usage](#security-and-resource-usage)
- [Development](#development)

## Public API

All PDF and XML inputs and outputs are byte strings. Facturx never interprets a string as a file path.

The three primary workflows are:

| Operation | API | Result |
|---|---|---|
| Build and embed XML | `Facturx.generate(pdf:, document:, profile:)` | PDF/A-3b bytes |
| Read XML or PDF | `Facturx.read(source)` | `Facturx::Reading` |
| Embed existing XML | `Facturx.attach(pdf:, xml:)` | PDF/A-3b bytes |

Focused operations are available when the complete workflow is not needed:

| Operation | API | Result |
|---|---|---|
| Validate XML | `Facturx.validate_xml(xml:)` | `Facturx::Validation::Report` |
| Validate typed data | `Facturx.validate_document(document:, profile:)` | `Facturx::Validation::Report` |
| Build XML | `Facturx.build_xml(document:, profile:)` | XML bytes |
| Extract embedded XML | `Facturx.extract_xml(pdf:)` | Exact embedded XML bytes |

## Build an invoice

`Facturx::Document.build` provides a nested DSL for the immutable Factur-X model. Singular associations accept either keyword attributes or a block; repeating associations use singular helpers such as `line`, `note`, and `tax_breakdown`.

```ruby
document = Facturx::Document.build(
  invoice_number: 'INV-2026-0042',
  type_code: '380',
  issue_date: Date.new(2026, 9, 13),
  currency: 'EUR'
) do |invoice|
  invoice.seller do |seller|
    seller.name = 'Seller SAS'
    seller.address(
      line_one: '10 Example Street',
      postcode: '75001',
      city: 'Paris',
      country_code: 'FR'
    )
    seller.vat_identifier(value: 'FR00123456789')
  end

  invoice.buyer do |buyer|
    buyer.name = 'Buyer SAS'
    buyer.address(country_code: 'FR')
  end

  invoice.line do |line|
    line.id = '1'
    line.product(name: 'Consulting services')
    line.quantity(value: BigDecimal('1'), unit_code: 'C62')
    line.net_price(amount: BigDecimal('100.00'))
    line.tax(category_code: 'S', rate: BigDecimal('20.00'))
    line.net_amount = BigDecimal('100.00')
  end

  invoice.tax_breakdown(
    category_code: 'S',
    rate: BigDecimal('20.00'),
    basis_amount: BigDecimal('100.00'),
    tax_amount: BigDecimal('20.00')
  )

  invoice.totals(
    line_total: BigDecimal('100.00'),
    tax_basis_total: BigDecimal('100.00'),
    tax_total: BigDecimal('20.00'),
    grand_total: BigDecimal('120.00'),
    due_payable: BigDecimal('120.00')
  )
end
```

Choose one of `:minimum`, `:basic_wl`, `:basic`, `:en16931`, or `:extended` when validating or generating a document:

```ruby
source_pdf = File.binread('invoice.pdf')
facturx_pdf = Facturx.generate(pdf: source_pdf, document:, profile: :en16931)
```

`generate` performs document and XSD validation before composing the PDF. Use `validate_document` to collect every semantic issue without raising, or `build_xml` when only the XML is needed:

```ruby
report = Facturx.validate_document(document:, profile: :en16931)

report.issues.each { |issue| warn issue.message } if report.invalid?
```

Alternatively, call `build_xml` directly and rescue `Facturx::InvalidDocumentError` when the report is only needed on failure.

`build_xml` and `generate` raise `Facturx::InvalidDocumentError` with the same report in `error.details[:report]` when the document is invalid.

The writer inserts the selected profile's canonical BT-24 guideline URN when it is absent. It reports a profile mismatch when the document contains a conflicting value. Values are serialized from their declared semantic type; monetary values with more than two decimal places are rejected rather than rounded implicitly.

## Use an existing XML invoice

Validate XML against the XSD selected by its BT-24 guideline URN:

```ruby
xml = File.binread('invoice.xml')
report = Facturx.validate_xml(xml:)
report.valid?
```

`validate_xml` reports malformed XML, a missing or unknown BT-24 profile, and every XSD violation without raising. Internal failures such as an unavailable bundled schema still raise a typed `Facturx::Error`.

Document validation reports all semantic issues in one pass. XSD validation runs only after that semantic layer succeeds, avoiding structural noise from XML already known to be incomplete.

Attach valid XML to an existing visual invoice PDF:

```ruby
pdf = File.binread('invoice.pdf')
facturx_pdf = Facturx.attach(pdf:, xml:)

File.binwrite('invoice-facturx.pdf', facturx_pdf)
```

`attach` validates the XML, converts the input to PDF/A-3b, embeds the original bytes as `factur-x.xml`, and verifies the attachment and Factur-X metadata. It rejects signed or encrypted PDFs because rewriting them would invalidate their protection.

Extracting XML is deliberately independent from validation:

```ruby
embedded_xml = Facturx.extract_xml(pdf: facturx_pdf)
Facturx.validate_xml(xml: embedded_xml)
```

This separation keeps malformed third-party invoices inspectable.

## Read a received invoice

`read` accepts either XML or PDF bytes and returns an immutable `Facturx::Reading`:

```ruby
reading = Facturx.read(File.binread('received-invoice.pdf'))

reading.document.invoice_number
reading.document.totals.grand_total
reading.profile.id
reading.diagnostics
reading.source
reading.source_type
```

Dates are `Date`, decimals are `BigDecimal`, identifiers retain their schemes, and repeating groups are frozen arrays in XML order. `source` contains the exact XML bytes and `source_type` is either `:xml` or `:pdf`.

Reading is tolerant and does not run implicit XSD validation. Missing, duplicate, empty, invalid, or unmapped values produce immutable diagnostics while usable fields remain accessible. Call `validate_xml` when structural validation is required.

Unknown or missing BT-24 values fall back to the EN 16931 intersection represented by the EXTENDED profile and add a diagnostic. Reject them instead with:

```ruby
Facturx.read(xml, on_unknown_profile: :raise)
```

## Profiles

The five canonical profiles are available through `Facturx::Profiles`:

```ruby
profile = Facturx::Profiles.fetch(:en16931)

profile.id
profile.guideline_urn
profile.conformance_level
```

Public writer methods accept either a profile symbol or its canonical `Facturx::Profile`. A separate profile object with matching attributes is rejected to keep profile resolution tied to the bundled XSD and metadata definitions.

The semantic registry covers all 184 EN 16931 business terms and the MINIMUM, BASIC WL, and BASIC subsets. EXTENDED-only fields remain available in `Reading#source` and produce diagnostics until represented in the typed model.

## Validation

`validate_xml` and `validate_document` return the same immutable report. Each issue identifies its validation layer, severity, message, and available XML or business-term location. A report can therefore be inspected without rescuing expected validation failures:

```ruby
report.issues.each do |issue|
  warn "#{issue.layer}: #{issue.term_id || issue.path} #{issue.message}"
end
```

Generated documents pass through two layers:

1. semantic conformance checks against the selected profile's business-term cardinalities and supported model mappings;
2. structural validation against the bundled official profile XSD.

Incoming XML passed to `validate_xml` is parsed, resolved to a profile from BT-24, and checked against that profile's XSD.

Domain failures use a `Facturx::Error` subclass with structured context in `details`. Common errors include:

| Error | Meaning |
|---|---|
| `Facturx::ValidationError` | Base class for strict validation failures |
| `Facturx::InvalidXmlError` | XML cannot be parsed |
| `Facturx::UnknownProfileError` | BT-24 is absent or unsupported during strict XML validation |
| `Facturx::XsdValidationError` | XML does not satisfy the selected profile XSD |
| `Facturx::UnsupportedProfileError` | A writer profile is unsupported |
| `Facturx::InvalidDocumentError` | A typed document violates the selected profile |
| `Facturx::InvalidSourceError` | A reader source is not a byte `String` |
| `Facturx::SchemaLoadError` | A bundled validation schema cannot be loaded |
| `Facturx::ProtectedPdfError` | The source PDF is signed or encrypted |
| `Facturx::ComposerUnavailableError` | Required Ghostscript resources are unavailable |
| `Facturx::CompositionError` | Ghostscript composition failed |
| `Facturx::ExtractionError` | The embedded Factur-X XML cannot be selected or decoded |
| `Facturx::VerificationError` | The composed PDF does not match the requested invoice |

XSD validation is not complete regulatory validation. Facturx does not yet run the official Schematron business rules, calculate totals, or evaluate accounting consistency.

## PDF composition

PDF composition through `attach` or `generate` requires:

- Ghostscript 9.54 or newer;
- Ghostscript's `zugferd.ps` script;
- an RGB ICC profile.

These resources are not distributed with the gem. Facturx searches common installation paths and accepts explicit overrides when automatic discovery is not suitable:

```bash
export GHOSTSCRIPT_BIN=/opt/ghostscript/bin/gs
export FACTURX_ZUGFERD_PS=/opt/ghostscript/share/ghostscript/lib/zugferd.ps
export FACTURX_ICC_PROFILE=/opt/ghostscript/share/ghostscript/iccprofiles/default_rgb.icc
```

The composer invokes Ghostscript as an external process with a timeout, bounded output capture, and file access restricted to its staged inputs and outputs.

Facturx does not create the visual invoice. The supplied PDF remains the visual source that is converted to PDF/A-3b and enriched with Factur-X XML and metadata.

## Round-trip guarantees

The reader preserves the exact incoming XML in `Reading#source`, but reading and rebuilding is not a fidelity round-trip. The writer cannot reproduce values outside the typed semantic model.

Retain and reuse `Reading#source` when reissuing an incoming invoice without intentional semantic changes.

## Security and resource usage

The byte-string API materializes PDF streams in memory. Process untrusted PDFs in a resource-limited worker: limiting only the input file size does not prevent amplification by a compressed embedded stream.

Facturx does not communicate with a PDP or implement e-invoicing transport. Network submission, authentication, retries, storage, invoice calculations, and business approval workflows remain application responsibilities.

## Development

```bash
mise install
bundle install
bundle exec rubocop
bundle exec rspec
bundle exec rake build
```

Maintainers can compare the semantic registry, D22B mappings, diagnostics, official XML examples, and paired PDF attachments with an extracted upstream package:

```bash
FACTURX_REFERENCE_ROOT=/path/to/ZUGFeRD_2.5.2_EN bundle exec rake reference:verify
```
