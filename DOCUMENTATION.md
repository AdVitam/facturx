# EuEinvoice API guide

## Configuration and resolution

```ruby
pack = EuEinvoice::France::Pack.new(version: '1.09.2')
client = EuEinvoice::Client.new(packs: [pack], policy: pack.policy, validation: :structural)
resolution = client.resolve(document: invoice)
```

The policy selects a pinned specification for a configured seller/buyer country pair. Explicit specifications override the policy but must match the document's guideline and semantic version. No country is inferred from missing data and no customer category flag is required.

A resolution exposes `status`, `specification`, `candidates`, `required_inputs`, `explanation`, `requirements` and `diagnostics`. Statuses are `resolved`, `unsupported`, `missing_information` and `ambiguous`. Writers require a resolved result. A supplied resolution is bound to the client and the entire immutable document; reuse after changing the document fails.

Known recipient requirements can be supplied without directory access or a customer-category flag:

```ruby
requirements = EuEinvoice::RecipientRequirements.new(
  specification_ids: [pack.specification.id],
  electronic_address_schemes: ['0225'],
  required_references: [:buyer_reference],
  provenance: EuEinvoice::RequirementProvenance.new(source: 'Customer onboarding', observed_at: Time.now)
)
resolution = client.resolve(document: invoice, requirements: requirements)
```

Requirements constrain explicit specifications and configured preferences; incompatibility never triggers a silent fallback. Missing addresses or references produce resolution diagnostics. Accepted syntax alone may still leave several profiles ambiguous. Provenance records application-supplied facts, not verification by the library; refresh stale facts in the application.

```ruby
spec = pack.specification(profile: :en16931)
artifact = client.build_xml(document: invoice, specification: spec)
```

Supported profiles are `minimum`, `basic_wl`, `basic`, `en16931` and `extended`. The semantic model represents the existing 184 EN 16931 terms. EXTENDED-specific data outside the model remains preserved in the reading source and diagnosed, not silently round-tripped.

`EuEinvoice::Codes::DocumentType`, `Codes::PaymentMeans` and `Codes::VatCategory` provide named constants for common values. They are conveniences, not exhaustive acceptance lists or tax advice; the chosen specification's actual code lists and rules remain authoritative.

## Methods

| Method | Result |
| --- | --- |
| `resolve(document:, specification: nil, requirements: RecipientRequirements.new)` | Resolution without network access |
| `read(source, specification: nil, on_unknown_profile: :fallback)` | Reading with document, source and diagnostics |
| `validate_xml(xml:, specification: nil)` | Validation::Report |
| `validate_document(document:, specification: nil, resolution: nil)` | Validation::Report |
| `build_xml(document:, specification: nil, resolution: nil)` | XML Artifact |
| `generate(document:, pdf:, specification: nil, resolution: nil)` | Hybrid PDF Artifact |
| `attach(pdf:, xml:, specification: nil)` | PDF Artifact after validating supplied XML |
| `extract_xml(pdf:, specification: nil)` | XML Artifact without a validation claim |

The three document-writing methods also accept `allow_loss: false`. A `Reading` with diagnostics is rejected unless loss is explicitly accepted. Passing only its `document` discards this provenance and is the caller's responsibility.

With several PDF extraction providers installed, pass a specification to `read` or `extract_xml`; the client never silently chooses the first provider.

Artifacts expose immutable `bytes`, `content_type`, `filename`, `byte_size`, optional `report`, and `to_io`. Each `to_io` is independent. The caller owns returned streams. Inputs accept String bytes, artifacts or IO at its current position; the library does not close or rewind caller IO. Strings are never interpreted as paths.

## Validation and errors

Full mode requires `eu-einvoice-validation-fr` and a usable SaxonC engine at construction. Structural mode does not load or use the engine. `read` remains tolerant in both modes.

Reports expose issues, selected specification, requested coverage, executed steps, step states and actual resources. `valid?` checks errors; `complete?` checks whether full stages ran. A complete report may be invalid, and a valid structural report is incomplete.

Issues carry stable codes, severity, layer, term/group, path and optional source position. Do not branch on translated message text. Document errors are reports or `InvalidDocumentError` with `details[:report]` when writing cannot succeed. Configuration, ambiguity, resource and engine failures are structured `EuEinvoice::Error` subclasses.

## French addressing

```ruby
address = EuEinvoice::France::Addressing.build(siret: customer_siret, routing_code: service_route)
buyer = buyer.with(electronic_address: address.electronic_address)
```

Other forms use `siren:`, optionally `suffix:`; a routing code requires a SIRET. SIREN is derived from a supplied SIRET, and conflicting inputs fail. The value object uses the French electronic-address scheme `0225` and preserves the required separators. It does not look up the customer, choose among active addresses or infer B2B/B2C/public status.

References supplied by a customer, such as an order or commitment, belong to the relevant invoice fields. Do not substitute an arbitrary service name or code for a confirmed routing address.

## Rails recipes

Install `eu-einvoice-rails`, configure clients in an initializer, then access `Rails.application.config.eu_einvoice[:name]`. The registry freezes after configuration. Each test application owns its registry.

Create an explicit mapper:

```sh
bin/rails generate eu_einvoice:mapper CustomerInvoice
```

Deliver bytes in a controller:

```ruby
send_data artifact.bytes, type: artifact.content_type, filename: artifact.filename
```

Attach to an email:

```ruby
attachments[artifact.filename] = { mime_type: artifact.content_type, content: artifact.bytes }
```

Persist only when the application asks:

```ruby
record.invoice.attach(EuEinvoice::Rails::ActiveStorage.attachable(artifact))
```

Read an existing blob through an IO:

```ruby
blob.open { |io| client.read(io) }
```

Active Storage may use a temporary file for `open`. Configure service-side limits as well: core bounds its own reads, not a preceding remote download implemented by Active Storage.

Map validation issues to application errors:

```ruby
EuEinvoice::Rails::ErrorAdapter.apply(record, report: report, attributes: { 'BT-1' => :number })
```

Unmapped issues go to `:base`. English/French fallback messages are included. Notifications use `<operation>.eu_einvoice` and include technical metadata without XML, customer values or exception messages.

## System dependencies and limits

Provision Ghostscript 9.54+, `zugferd.ps` and an RGB ICC profile for composition. Configure `EU_EINVOICE_GHOSTSCRIPT`, `EU_EINVOICE_ZUGFERD_PS` and `EU_EINVOICE_RGB_ICC_PROFILE` when discovery is insufficient. Provision SaxonC-HE 12.10+ and use `EU_EINVOICE_SAXONC_TRANSFORM` to select its executable.

Resource limits are immutable client configuration:

```ruby
limits = EuEinvoice::ResourceLimits.new(pdf_bytes: 20 * 1024 * 1024, process_timeout: 30)
client = EuEinvoice::Client.new(packs: [pack], policy: pack.policy, validation: :structural, limits: limits)
```

Defaults and process guarantees are documented in [ADR 004](docs/architecture/adr/004-resources.md). Limits are operational policy, not normative invoice limits. PDF processing requires supported process resource controls; unavailable requested controls fail explicitly. Binary paths and schemas are never downloaded at runtime.

## Development

```sh
bundle install
bundle exec rspec
# Without a provisioned SaxonC engine:
bundle exec rspec --tag '~saxonc'
ruby tooling/lint.rb
bundle exec rake build_all
bundle exec ruby tooling/verify_packages.rb
bundle exec ruby tooling/benchmark.rb current
```

The CI matrix covers compatible Ruby/Rails combinations, real SaxonC, veraPDF and built-package loading. A Rails dummy app uses isolated SQLite memory and private temporary storage; no application database is required.

Production lint is blocking. Test files are formatted with `ruby tooling/lint.rb --autocorrect`; remaining test-style offenses are reported but non-blocking, following the repository test policy. No cop configuration is relaxed.
