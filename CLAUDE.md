# CLAUDE.md

## Overview

`facturx` is a Ruby gem for validating Factur-X XML, composing PDF/A-3b Factur-X invoices, and extracting their embedded XML.

## Architecture

- `Facturx.verify_xml` detects the BT-24 profile and validates its XSD.
- `Facturx.attach` validates XML, rejects protected PDFs, composes with Ghostscript, and verifies the result.
- `Facturx.extract_xml` returns the embedded `factur-x.xml` bytes without validating them.
- XML, PDF, and Ghostscript responsibilities remain isolated behind internal objects.

## Rules

- Support Ruby 3.2 and newer.
- Keep public inputs and outputs as byte strings.
- Never distribute Ghostscript's `zugferd.ps` or ICC profiles.
- Do not add HTTP, PDP transport, Schematron, XML generation, Sorbet runtime, or ActiveModel.
- Fix lint failures at their cause. Do not disable cops or bypass hooks.
- Keep comments limited to short explanations of non-obvious constraints.
