# Third-party notices

## Factur-X Schematron validation artifacts

This gem includes the compiled XSLT 2.0 stylesheets and adjacent code databases
for the MINIMUM, BASIC WL, BASIC, EN 16931, and EXTENDED profiles from the
official Factur-X 1.09.2 / ZUGFeRD 2.5.2 English package.

FeRD publishes these technical artifacts under the Apache License 2.0. Its text
is included in `lib/facturx/schematron/rules/LICENSE-APACHE-2.0.txt`. The ten
files under `rules/1.09.2/` are byte-for-byte copies of their upstream
counterparts; their SHA-256 digests are recorded in `rules/SHA256SUMS`.

Sources:

- https://www.ferd-net.de/en/downloads/publications/details/zugferd-252-english
- https://www.ferd-net.de/en/ueber-uns/ressourcen-1/veroeffentlichungen/disclaimer-and-rights-of-use-zugferd
