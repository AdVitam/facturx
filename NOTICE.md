# Third-party notices

## Factur-X validation schemas

The gem includes Factur-X 1.09.2 / ZUGFeRD 2.5.2 XSD validation artefacts. Their Apache License 2.0 text, provenance, RubyGems packaging adaptation, and file checksums are packaged under `lib/facturx/schema/`.

The semantic term registry is derived from the official Factur-X 1.09.2 profile workbooks. The workbooks and examples are not redistributed; their expected paths and SHA-256 checksums are recorded in `Facturx::Terms::REFERENCE_FILES` for maintainer verification.

## Ghostscript

PDF composition invokes a Ghostscript installation supplied by the user. Ghostscript, `zugferd.ps`, and ICC profiles are not part of this gem and remain governed by their respective licences.
