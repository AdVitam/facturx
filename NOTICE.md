# Third-party notices

## Factur-X validation schemas

The French package includes Factur-X 1.09.2 / ZUGFeRD 2.5.2 XSD validation artefacts. Their Apache License 2.0 text, provenance, RubyGems packaging adaptation, and file checksums are packaged under `gems/eu-einvoice-fr/lib/eu_einvoice/schema/`.

The semantic term registry is derived from the official Factur-X 1.09.2 profile workbooks. Reference workbook paths and SHA-256 checksums are recorded in `EuEinvoice::Terms::REFERENCE_FILES` for maintainer verification. Bundled XML examples carry their own provenance notices.

## Ghostscript

PDF composition invokes a Ghostscript installation supplied by the user. Ghostscript, `zugferd.ps`, and ICC profiles are not part of this gem and remain governed by their respective licences.
