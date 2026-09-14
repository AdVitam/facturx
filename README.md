# Facturx

[![Gem Version](https://badge.fury.io/rb/facturx.svg)](https://rubygems.org/gems/facturx)
[![Test](https://github.com/AdVitam/facturx/actions/workflows/test.yml/badge.svg)](https://github.com/AdVitam/facturx/actions/workflows/test.yml)
[![Ruby](https://img.shields.io/badge/Ruby-3.2%2B-CC342D.svg)](https://www.ruby-lang.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.txt)

Build, read, validate, and compose Factur-X / ZUGFeRD invoices in Ruby.

Use typed Ruby objects to generate XSD-valid XML, embed it into an existing PDF, or inspect invoices received from third parties.

## Features

### Main workflows

| | What you need | API |
|:---:|---|---|
| ✅ | Generate a Factur-X invoice from typed data | `Facturx::Document.build` + `Facturx.generate` |
| ✅ | Read an XML or PDF invoice | `Facturx.read` |
| ✅ | Embed existing Factur-X XML into a PDF | `Facturx.attach` |

### Focused tools

| | Capability | API |
|:---:|---|---|
| ✅ | Generate Factur-X XML | `Facturx.build_xml` |
| ✅ | Validate typed documents | `Facturx.validate_document` |
| ✅ | Validate XML against official XSDs | `Facturx.validate_xml` |
| 🔌 | Add official Schematron business-rule validation | `facturx-schematron` |
| ✅ | Extract the original embedded XML | `Facturx.extract_xml` |

### Boundaries

| | Capability | Responsibility |
|:---:|---|---|
| ➖ | Invoice calculations | Application |
| ➖ | Visual PDF generation | Application |
| ➖ | PDP transport and e-invoicing | Application |

✅ Included · 🔌 Optional companion · ➖ Intentionally handled outside the gem

## Supported profiles

Facturx supports Factur-X 1.09.2 / ZUGFeRD 2.5.2.

| Profile | Read | Build | XSD | Schematron** |
|---|:---:|:---:|:---:|:---:|
| MINIMUM | ✅ | ✅ | ✅ | ✅ |
| BASIC WL | ✅ | ✅ | ✅ | ✅ |
| BASIC | ✅ | ✅ | ✅ | ✅ |
| EN 16931 | ✅ | ✅ | ✅ | ✅ |
| EXTENDED | ✅* | ✅* | ✅ | ✅ |

\* EXTENDED-only fields that are not represented by the typed model remain available in the original XML and are reported through diagnostics.

\** Available through the optional `facturx-schematron` gem.

## Requirements

- Ruby 3.2 or newer
- Ghostscript 9.54 or newer, `zugferd.ps`, and an RGB ICC profile for PDF composition only
- SaxonC-HE 12.10 or newer only when `facturx-schematron` is enabled

Core XML building, reading, extraction, and XSD validation require no external executable.

## Quick start

Turn an existing invoice PDF and typed business data into a PDF/A-3b Factur-X invoice with XSD-validated XML:

```ruby
require 'facturx'

document = Facturx::Document.build(
  invoice_number: 'INV-2026-0042',
  type_code: '380',
  issue_date: Date.new(2026, 9, 13),
  currency: 'EUR'
) do |invoice|
  invoice.seller do |seller|
    seller.name = 'Seller SAS'
    seller.address(country_code: 'FR')
  end

  invoice.buyer(name: 'Buyer SAS')

  invoice.totals(
    tax_basis_total: BigDecimal('100.00'),
    tax_total: BigDecimal('20.00'),
    grand_total: BigDecimal('120.00'),
    due_payable: BigDecimal('120.00')
  )
end

source_pdf = File.binread('invoice.pdf')
facturx_pdf = Facturx.generate(pdf: source_pdf, document:, profile: :minimum)

File.binwrite('invoice-facturx.pdf', facturx_pdf)
```

`generate` validates the document and generated XML, embeds `factur-x.xml`, and verifies the resulting PDF metadata and attachment.

## Documentation

See [DOCUMENTATION.md](DOCUMENTATION.md) to:

- build richer typed invoices;
- validate or attach existing XML;
- read invoices and handle diagnostics;
- understand profiles, validation boundaries, and typed errors;
- enable official Schematron business-rule validation;
- configure Ghostscript for PDF/A-3b composition.

## License

The gem code is available under the [MIT License](LICENSE.txt). Bundled standard artefacts retain their respective upstream notices; see [NOTICE.md](NOTICE.md).
