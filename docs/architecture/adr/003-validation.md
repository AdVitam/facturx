# ADR 003 — Explicit versions and truthful coverage

Status: accepted.

Every operation uses a resolved immutable specification. Its manifest identifies the semantic standard, syntax, profile, resources, code lists and provenance. Resource fingerprints isolate compiled-schema caches. A package release never means selecting a new normative version automatically.

Guideline URNs do not uniquely identify every artifact release. Multiple matching versions require an explicit choice; there is no latest-version fallback. Unknown-profile reading preserves source bytes and diagnostics without assigning the EXTENDED profile.

Full validation is the client default and requires the optional validation companion and its engine at client construction. Structural validation is explicit and excludes Schematron. Requiring the companion cannot alter a previously configured client.

`valid?` means no error was found in requested checks. `complete?` means all required full-validation stages ran; it does not mean the document was valid. Reports contain executed stages and resource identities. Configuration/tool failures raise structured exceptions; document violations are reports.

Schematron artifacts remain upstream bytes. Aggregated rules are not split to manufacture independent layers. In-process model invariants, lexical constraints, XSD and official business rules have distinct owners.

The 2017 semantic baseline remains implemented. A 2026 model requires official artifacts, an explicit semantic delta and new tests. Synthetic version-isolation fixtures do not prove 2026 conformance.
