# EuEinvoice architecture

Status: implementation of foundation lots 1–3. The installed document format is Factur-X 1.09.2 / ZUGFeRD 2.5.2. Additional European formats are roadmap items, not advertised capabilities.

## Package boundaries

| Package | Owns | Depends on |
| --- | --- | --- |
| eu-einvoice | Semantic data, immutable specifications, resolution, client, artifacts, resource contracts | Ruby types |
| eu-einvoice-syntax-cii | CII bindings, lexical conversion, reader/writer, XSD execution | Core, Nokogiri |
| eu-einvoice-container-pdf | PDF inspection, composition, extraction, embedding verification | Core, PDF reader, Nokogiri |
| eu-einvoice-fr | Factur-X manifests/XSD, profile restrictions, French addressing and assembly | Core, CII, PDF |
| eu-einvoice-validation-fr | Official Schematron artifacts and SaxonC adapter | French pack |
| eu-einvoice-rails | Rails configuration, presentation and IO integration | Core, Rails components |

The core entry point loads no XML, PDF or Rails library. Extensions depend on the core; the core invokes supplied collaborators without loading country packages. The same `Client` serves every installed pack.

## Operations

Configuration creates a client from explicit packs, an optional country-pair policy and a validation mode. It is reusable across requests. Each operation owns its source, parsed representation and report. No mutable global validator is installed by `require`.

Resolution selects an installed specification using an explicit override, a configured preference or declared recipient requirements, and checks the document guideline and semantic version. Recipient requirements retain provenance and can constrain formats, address schemes and references. Incompatible or missing information produces an unresolved result. It does not perform tax classification or network discovery. A resolution is bound to its client and document fingerprint, preventing accidental reuse after mutation.

Input inspection and size limits precede XML processing. XML complexity is checked before a DOM is constructed. The DOM is shared by detection, reading and validation within the operation. An external Schematron process necessarily parses its own input.

Generation compiles and validates XML once, composes the PDF, then verifies the attachment and metadata. A successful extraction alone makes no claim of schema or business-rule validity.

## Decisions

- [ADR 001: packages and public API](adr/001-packages.md)
- [ADR 002: identity and addressing](adr/002-addressing.md)
- [ADR 003: versions and validation](adr/003-validation.md)
- [ADR 004: resources and performance](adr/004-resources.md)
- [ADR 005: Rails integration](adr/005-rails.md)
- [Roadmap](roadmap.md)
- [Release procedure](release.md)
- [Performance protocol](performance.md)
- [Extension author contracts](extensions.md)
