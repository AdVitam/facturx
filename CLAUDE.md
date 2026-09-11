# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`facturx` is a Ruby gem that validates Factur-X XML, composes PDF/A-3b Factur-X invoices from existing PDFs, and extracts their embedded XML. It targets Factur-X 1.09.2 / ZUGFeRD 2.5.2 with the MINIMUM, BASIC WL, BASIC, EN 16931, and EXTENDED profiles.

## Commands

```bash
mise install && bundle install

bundle exec rspec                                       # full suite
bundle exec rspec spec/facturx/xml/verifier_spec.rb     # one file
bundle exec rspec spec/facturx/xml/verifier_spec.rb:42  # one example
bundle exec rubocop                                     # -A to autofix
bundle exec rake build                                  # gem into pkg/

bundle exec ruby spec/support/generate_verapdf_fixture.rb out.pdf  # PDF/A-3b sample for veraPDF
```

Specs requiring Ghostscript skip themselves when the composer resources are missing, so a green local run does not prove composition works. CI installs `ghostscript` plus a pinned `zugferd.ps` (`.github/actions/setup-ghostscript`) and validates a generated invoice with veraPDF `--flavour 3b`.

lefthook's pre-commit hook runs `rubocop -A` on staged Ruby files and the whole RSpec suite.

## Architecture

`lib/facturx.rb` exposes three entry points; everything else is internal.

- `verify_xml(xml:)` → `Xml::Verifier`: `Parser` → `ProfileDetector` (BT-24 guideline URN → `Profiles`) → `SchemaValidator` (profile XSD under `lib/facturx/schema/1.09.2/`). Returns `true`, raises a typed error otherwise.
- `attach(pdf:, xml:)` → `Attach#call` pipeline: verify XML (yields the profile) → `Pdf::Inspector` (page count, rejects signed/encrypted PDFs) → `Composers::Ghostscript` (PDF/A-3b conversion + embedding) → `Pdf::Extractor` → `Pdf::Verifier`. The last step is a self-check of the gem's own output: identical XML bytes, filename, relationship, page count, and XMP (`pdfaid:part/conformance`, `fx:*` fields including the profile conformance level).
- `extract_xml(pdf:)` → `Pdf::Extractor`: associated-file array first, then the name tree; no validation, so third-party invoices stay inspectable.

Collaborators are constructor-injected with defaults, and specs pass fakes instead of stubbing globals.

`FACTURX_EMBEDDING` (`lib/facturx/embedding.rb`) is the single source for filename, relationship, document type, version, and XMP namespace, shared by composer, extractor, and verifier. `Profiles` (`lib/facturx/profiles.rb`) is the single source for guideline URNs, XSD paths, and conformance levels.

Ghostscript runs as an external process: `Locator` resolves the binary, `zugferd.ps`, and the ICC profile (overrides `GHOSTSCRIPT_BIN`, `FACTURX_ZUGFERD_PS`, `FACTURX_ICC_PROFILE`, then platform candidates), `VersionProbe` enforces 9.54 or newer, `Composers::Ghostscript#call` stages the inputs in a `mktmpdir` and restricts `--permit-file-read` to the four known paths, and `Runner` executes the command with a timeout and bounded output capture.

## Rules

- Support Ruby 3.2 and newer; CI runs 3.2 through 4.0.
- Keep public inputs and outputs as byte strings, never file paths.
- Raise a `Facturx::Error` subclass with structured `**details` rather than a bare message.
- Never distribute Ghostscript's `zugferd.ps` or ICC profiles.
- `lib/facturx/schema/**` holds vendored upstream artefacts: do not edit them, and update `SHA256SUMS` for any change there (checked by CI and by `spec/gem/specification_packaging_spec.rb`).
- Do not add HTTP, PDP transport, Schematron, XML generation, Sorbet runtime, or ActiveModel.
- Fix lint failures at their cause. Do not disable cops or bypass hooks.
- Keep comments limited to short explanations of non-obvious constraints.
- Releases: bump `lib/facturx/version.rb` and CHANGELOG together, then push tag `v<version>`; the workflow publishes to RubyGems and cuts a GitHub release from the matching CHANGELOG section.
