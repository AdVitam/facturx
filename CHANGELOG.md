# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### EuEinvoice 1.0.0 foundation

- Extract a central European invoice client/model with independent CII, PDF, French, validation and Rails packages.
- Add immutable versioned specifications, explicit local resolution and validation provenance without global companion activation.
- Add bounded IO/XML/PDF processing, isolated PDF workers and subprocess group cleanup.
- Add French addressing, official Rails integration and independent artifact streams.
- Preserve the Factur-X corpus and extend real-engine, package and framework checks.
- Prepare new package identities without aliases or republishing historical Facturx gems.

## [1.2.0] - 2026-09-14

### Add

- Add optional official Schematron validation through the lightweight `facturx-schematron` companion gem.
- Add Schematron issues and strict errors to the existing validation model for all writing and attachment workflows.
- Add shared bounded subprocess execution for Ghostscript and SaxonC without loading optional rules in the core gem.

### Fix

- Preserve non-UTF-8 invoice text when passing parsed XML to SaxonC.
- Report oversized Schematron output as a resource limit instead of malformed validation output.
- Keep subprocess timeout diagnostics valid UTF-8 while preserving raw successful output bytes.

## [1.1.0] - 2026-09-14

### Add

- Add packaged reference documentation for the public API and operational constraints.
- Add structured XML and document validation reports with a shared issue model.
- Add precise errors for invalid input sources, invalid documents, and unavailable schemas.

### Fix

- Validate generated XML only once before composing and verifying the PDF.
- Limit the supported public surface to facades, domain values, results, profiles, and emitted errors.
- Keep profile metadata independent from the bundled schema layout.
- Expose strict XML failures from `attach` through the shared validation report and issue model.

### Del

- Remove `verify_xml`, `Conformance` reports, `ConformanceError`, and direct access to implementation services.
- Remove `Profile#xsd_path` and the public schema layout constants from `Profiles`.
- Make the internal `Profiles` lookup constants private; use `Profiles.all`, `.fetch`, or `.for_guideline_urn`.

## [1.0.0] - 2026-09-13

### Add

- Add immutable invoice construction through a typed nested DSL.
- Add aggregated document conformance validation for all five built-in profiles.
- Add profile-specific Factur-X XML generation and PDF generation from typed documents.
- Add strict RBI signatures for the public models, builders, reports, errors, and facades.
- Add maintainer verification of term membership and cardinalities against pinned official workbooks.

### Fix

- Fix partial or unrepresentable values so supplied data is rejected instead of silently discarded.
- Fix repeated credit transfers and discriminated references across semantic round trips.
- Fix MINIMUM accounting-currency tax totals without emitting the forbidden tax currency term.
- Fix invalid profile objects to raise the documented typed error.

## [0.2.0] - 2026-09-12

### Add

- Read XML or PDF bytes into an immutable, typed EN16931 document model with structured diagnostics.
- Map the complete EN16931 semantic term set and the MINIMUM, BASIC WL, and BASIC subsets.
- Verify semantic mapping provenance and official examples with the maintainer reference task.

## [0.1.0] - 2026-09-11

### Add

- Validate Factur-X 1.09.2 XML against its profile XSD.
- Compose PDF/A-3b Factur-X documents with Ghostscript.
- Extract embedded Factur-X XML from PDF documents.

[Unreleased]: https://github.com/AdVitam/facturx/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/AdVitam/facturx/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/AdVitam/facturx/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/AdVitam/facturx/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/AdVitam/facturx/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/AdVitam/facturx/releases/tag/v0.1.0
