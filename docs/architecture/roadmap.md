# Roadmap

## Foundation — this PR

Deliver six installable packages, the existing five Factur-X profiles, immutable composition, resource limits, local addressing, client resolution and Rails helpers. Exit requires corpus, Schematron, veraPDF, packaging and framework tests, plus recorded performance comparisons.

## UBL and semantic evolution

Add UBL 2.1 Invoice/CreditNote using the existing core. Publish an UBL binding only when both directions and schema validation work. Implement EN 16931:2026 after an explicit term/cardinality delta, official artifacts and migration cases exist. Keep both semantic versions independently selectable. No automatic CII/UBL conversion.

## Documentary networks and countries

Add Peppol BIS Billing/PINT-EU with pinned rules and code lists. Extract the common Schematron engine only with this second consumer. Add French CTC and German XRechnung requirements from authoritative artifacts and real use cases. A country package contains actual rules or mapping; using Peppol alone does not require an empty country package.

## Discovery

Add a connector when an accessible, authorized provider/API is selected. Define typed destination facts, provenance, effective dates, multiple-address handling and required references from real responses. Apply finite caching and distinguish unavailable from not-found. No scraping of public portals as an implicit runtime fallback.

## Transport and workflow

Implement submission and receipt/status operations separately from generation. First deliver a real provider connector with idempotence, bounded retries and sandbox fixtures. Extract common transport contracts after two working connectors. Audit source bytes, effective specification and receipts without adding delivery state to Document.

## Additional companions

Calculations require an explicit rounding policy and comparison against source values. Conversion requires mandatory loss reports. CLI and testkit extraction require a concrete operator or third-party pack consumer. No placeholder implementations reserve these APIs.
