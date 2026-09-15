# ADR 001 — One European core and explicit extensions

Status: accepted.

The central `eu-einvoice` package owns both semantic types and the public `Client`. A second core package would add release coordination without an independent consumer. Internally, semantic data, resolution and orchestration have separate responsibilities.

CII and PDF are independent packages immediately: future German or UBL consumers must not depend on a French implementation. The French package assembles implementations and supplies profile artifacts. A package is created only when it contains a usable implementation.

The public namespace is `EuEinvoice`. Country-specific construction is confined to application configuration and optional helpers. Operational calls use a client rather than global country-specific facades. Historical `Facturx` aliases and wrapper releases are not provided.

Ruby 3.2–4.0 remains the format-library compatibility target. RBI files describe public APIs without a Sorbet runtime dependency. Load-boundary and installed-package tests enforce the dependency graph.

The cost is six packages and shared release tooling. Version 1.0.0 is coordinated across them initially; package versions remain distinct from normative versions.
