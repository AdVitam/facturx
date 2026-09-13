# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

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

[Unreleased]: https://github.com/AdVitam/facturx/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/AdVitam/facturx/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/AdVitam/facturx/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/AdVitam/facturx/releases/tag/v0.1.0
