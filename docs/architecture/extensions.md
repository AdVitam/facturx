# Implementing an extension

The operational API belongs to `eu-einvoice`. Applications install extensions and explicitly pass pack instances to `EuEinvoice::Client`; requiring a gem never registers a global plugin or changes existing clients.

## Country and specification packs

A pack includes `EuEinvoice::Pack` and supplies immutable `specifications` plus `adapter(validation:, limits:)`. Each specification identifies its semantic version, syntax, guideline/profile, document types, resource checksums, execution entrypoints and required inputs. Use a new identity/version when normative artifacts change. There is no mutable "latest" pointer.

The adapter supports these operations:

| Method | Contract |
| --- | --- |
| `prepare(xml:)` | Bounded, operation-local `Validation::Context` |
| `detect(xml:, context:)` | All matching installed specifications; never silently pick a version |
| `can_read?(xml:, context:)` | Whether tolerant reading of that syntax is possible |
| `read(source, specification:, on_unknown_profile:, context:)` | Immutable `Reading`, preserving source and losses |
| `validate_xml(xml:, specification:, context:)` | Provenanced validation report |
| `validate_document(document:, specification:)` | Semantic/conformance report |
| `compile(document:, specification:)` | Validated XML and report, or structured failure |

Adapters for the same syntax set share a prepared context within one operation. They must consume the same syntax representation contract (currently a Nokogiri document for CII); profile and artifact-version differences belong in validation bindings, not parsing. A new syntax needs its own representation contract and bidirectional fixtures, not a country-specific copy of the invoice model.

PDF-capable packs additionally implement `extract_xml(pdf:, limits:)` and `compose(pdf:, xml:, specification:, limits:)`. The shared PDF package takes explicit embedding metadata. With multiple providers, an explicit specification selects the provider; otherwise extraction fails as ambiguous. Do not attempt alternative providers after arbitrary errors or return the first successful result.

## State and errors

Create clients at boot and reuse them. Keep document data, parsed representations and reports operation-local. Shared caches may hold only bounded, immutable compiled resources or binding indexes; synchronize mutation. Honor supplied resource limits throughout subprocesses as well as in-process parsers. Missing engines and unsupported process controls fail explicitly.

Use `EuEinvoice::Error` subclasses with structured details. Validation issues use stable codes and semantic paths, not application-specific translations. Requested and executed coverage are separate: no adapter may claim full coverage when a stage was unavailable or skipped.

## Minimum extension tests

Test standalone loading and package dependencies, both serialization directions, source/loss preservation, invalid input, exact-version coexistence using genuinely different resources, provenance, immutable configuration, concurrency and byte/complexity budgets. Run relevant official artifact corpora and independent validators. A synthetic fixture establishes isolation, not conformance to an unpublished standard.

Remote discovery and delivery are deliberately outside these contracts. Future connectors return dated destination facts for `RecipientRequirements`; they do not add network I/O to parsing, resolution or document generation.
