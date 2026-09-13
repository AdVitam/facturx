# facturx

`facturx` builds, reads, and validates Factur-X XML, creates PDF/A-3b Factur-X invoices from existing PDFs, and extracts their embedded XML.

The first release supports Factur-X 1.09.2 / ZUGFeRD 2.5.2 with the MINIMUM, BASIC WL, BASIC, EN 16931, and EXTENDED profiles.

## Installation

Add the gem to your bundle:

```ruby
gem 'facturx'
```

Then run `bundle install`.

Composition requires Ghostscript 9.54 or newer with `zugferd.ps` and an RGB ICC profile installed on the system. Package contents vary by operating system and distribution: after installing Ghostscript, verify that both resources are present and configure their paths as described below when automatic discovery cannot find them.

## Usage

All inputs and outputs are byte strings. The gem does not interpret strings as file paths.

```ruby
require 'facturx'

xml = File.binread('invoice.xml')
pdf = File.binread('invoice.pdf')

Facturx.verify_xml(xml: xml)

reading = Facturx.read(xml)
reading.document.invoice_number
reading.document.totals.grand_total
reading.diagnostics

facturx_pdf = Facturx.attach(pdf: pdf, xml: xml)
File.binwrite('invoice-facturx.pdf', facturx_pdf)

embedded_xml = Facturx.extract_xml(pdf: facturx_pdf)
pdf_reading = Facturx.read(facturx_pdf)
```

Build a typed document with the nested DSL, validate it without generating XML, or generate XML and attach it to an existing PDF:

```ruby
document = Facturx::Document.build(
  invoice_number: 'INV-2026-0042',
  type_code: '380',
  issue_date: Date.new(2026, 9, 12),
  currency: 'EUR'
) do |invoice|
  invoice.seller do |seller|
    seller.name = 'Seller SAS'
    seller.address(country_code: 'FR')
  end
  invoice.buyer(name: 'Buyer SAS')
  invoice.totals(
    tax_basis_total: BigDecimal('100.00'),
    grand_total: BigDecimal('120.00'),
    due_payable: BigDecimal('120.00')
  )
end

report = Facturx.validate_document(document:, profile: :minimum)
report.valid?

xml = Facturx.build_xml(document:, profile: :minimum)
facturx_pdf = Facturx.generate(pdf:, document:, profile: :minimum)
```

`profile:` accepts one of `:minimum`, `:basic_wl`, `:basic`, `:en16931`, or `:extended`, as well as the corresponding canonical `Facturx::Profile`. When BT-24 is absent, the writer inserts the selected profile's guideline URN. A conflicting BT-24 is reported as a profile mismatch.

`validate_document` returns an immutable report containing every conformance issue found. `build_xml` and `generate` raise `Facturx::ConformanceError` with that report when the document is invalid. Values are serialized from their declared semantic type; monetary values with more than two decimal places are rejected instead of being rounded implicitly. Generated XML is always checked against the selected profile's XSD.

`verify_xml` infers the profile from BT-24 and validates the document against that profile's XSD. It returns `true` on success and raises a typed `Facturx::Error` on failure.

`attach` always validates the XML first. It converts the input PDF to PDF/A-3b, embeds the original XML bytes as `factur-x.xml`, and verifies the resulting attachment and metadata. Signed and encrypted PDFs are rejected because rewriting them would invalidate their protection.

`extract_xml` returns the embedded bytes without validating them. This allows callers to inspect non-conforming invoices received from third parties and explicitly call `verify_xml` when appropriate.

`read` accepts either XML or PDF bytes and returns an immutable `Facturx::Reading`. Its `document` contains typed immutable values: dates are `Date`, decimals are `BigDecimal`, identifiers retain their schemes, and repeating groups are frozen arrays in XML order. `source` always contains the exact embedded XML bytes and `source_type` is either `:xml` or `:pdf`.

Reading is intentionally tolerant and never performs implicit XSD validation. Missing, duplicate, empty, invalid, or unmapped values are reported through immutable diagnostics while usable fields remain accessible. Call `verify_xml` separately when strict structural validation is required.

Unknown or missing BT-24 values fall back to the EN16931 intersection supported for EXTENDED documents and add a diagnostic. Pass `on_unknown_profile: :raise` to reject them instead:

```ruby
Facturx.read(xml, on_unknown_profile: :raise)
```

The semantic registry covers all 184 EN16931 business terms and the MINIMUM, BASIC WL, and BASIC subsets. EXTENDED-only fields remain available in `Reading#source` and are reported as unmapped until their model is added.

Reading is not a fidelity round-trip. To reissue an incoming invoice, retain and reuse `Reading#source`; the writer cannot reproduce fields outside the semantic model.

The byte-string API materializes PDF streams in memory. Process untrusted PDFs in a resource-limited worker; limiting only the input file size does not prevent amplification by a compressed embedded stream.

## Ghostscript discovery

The composer searches common installation paths. Override discovery when necessary:

```bash
export GHOSTSCRIPT_BIN=/opt/ghostscript/bin/gs
export FACTURX_ZUGFERD_PS=/opt/ghostscript/share/ghostscript/lib/zugferd.ps
export FACTURX_ICC_PROFILE=/opt/ghostscript/share/ghostscript/iccprofiles/default_rgb.icc
```

The gem invokes Ghostscript as an external process. It does not distribute Ghostscript, `zugferd.ps`, or ICC profiles.

## Validation scope

The gem validates generated documents against its EN16931 semantic registry and the official profile XSDs. It does not yet run the Factur-X Schematron business rules, calculate totals, or evaluate accounting consistency. These checks must not be presented as complete regulatory validation.

The gem does not generate the visual invoice PDF, communicate with a PDP, or implement e-reporting. EXTENDED-only fields are not generated until they are represented in the typed model.

## Development

```bash
mise install
bundle install
bundle exec rubocop
bundle exec rspec
bundle exec rake build
```

Maintainers can verify the registry hashes, D22B element names, semantic diagnostics, official XML examples, and paired PDF attachments against an extracted upstream package:

```bash
FACTURX_REFERENCE_ROOT=/path/to/ZUGFeRD_2.5.2_EN bundle exec rake reference:verify
```

## License

The gem code is available under the MIT License. Bundled standard artefacts retain their respective upstream notices; see `NOTICE.md`.
