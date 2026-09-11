# facturx

`facturx` validates Factur-X XML, creates PDF/A-3b Factur-X invoices from existing PDFs, and extracts their embedded XML.

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

Facturx.verify_xml(xml: xml) # => true

facturx_pdf = Facturx.attach(pdf: pdf, xml: xml)
File.binwrite('invoice-facturx.pdf', facturx_pdf)

embedded_xml = Facturx.extract_xml(pdf: facturx_pdf)
```

`verify_xml` infers the profile from BT-24 and validates the document against that profile's XSD. It returns `true` on success and raises a typed `Facturx::Error` on failure.

`attach` always validates the XML first. It converts the input PDF to PDF/A-3b, embeds the original XML bytes as `factur-x.xml`, and verifies the resulting attachment and metadata. Signed and encrypted PDFs are rejected because rewriting them would invalidate their protection.

`extract_xml` returns the embedded bytes without validating them. This allows callers to inspect non-conforming invoices received from third parties and explicitly call `verify_xml` when appropriate.

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

Version 0.1 validates XML structure with the official XSDs. It does not yet run the Factur-X Schematron business rules. XSD validation alone must not be presented as complete semantic or regulatory validation.

The gem does not generate invoice XML or the visual invoice PDF, communicate with a PDP, or implement e-reporting.

## Development

```bash
mise install
bundle install
bundle exec rubocop
bundle exec rspec
bundle exec rake build
```

## License

The gem code is available under the MIT License. Bundled standard artefacts retain their respective upstream notices; see `NOTICE.md`.
