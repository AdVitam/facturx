# Factur-X schema provenance

The XSD files in `1.09.2/` are Factur-X 1.09.2 / ZUGFeRD 2.5.2 technical
artifacts. FeRD publishes these technical artifacts under the Apache License
2.0; its text is included in `LICENSE-APACHE-2.0.txt`.

RubyGems packages use a tar format that limits each filename component to 100
bytes. The five upstream
`*_ReusableAggregateBusinessInformationEntity_100.xsd` files exceed that
limit, so they are locally named
`ReusableAggregateBusinessInformationEntity_100.xsd`. Their contents remain
byte-for-byte identical to upstream. Only the corresponding `schemaLocation`
in each of the five profile entry schemas was changed to reference the shorter
local filename.

The complete five-profile set was imported from `atgp/factur-x` tag `v3.5.0`,
commit `b448a57074973ab57048aac8f2d208a516d685d9`. Except for the packaging
adaptation documented above, the repository mirrors the official release
files.

The BASIC WL, EN 16931, and EXTENDED files were independently checked against
the FNFE `France_RFE` tag `v1.4.0.03`, commit
`a63e6b538bdaff460f17c38dc1bc5455cf1ba35a`: all twelve source blobs matched
before the local `schemaLocation` adaptation. That FNFE repository does not
contain the MINIMUM and BASIC profiles. Those eight source files were also
checked against `ZUGFeRD/mustangproject` tag `core-2.25.0`, which contains
matching component blobs but renames schema files for its Java resource layout.

The official FeRD download page confirms that release 2.5.2 contains all five
profile schema sets, but access to the archive requires submitting a form and
accepting its terms. No form data was submitted during this import. File-level
SHA-256 digests are recorded in `SHA256SUMS`.

Sources:

- https://www.ferd-net.de/en/downloads/publications/details/zugferd-252-english
- https://www.ferd-net.de/en/ueber-uns/ressourcen-1/veroeffentlichungen/disclaimer-and-rights-of-use-zugferd
- https://github.com/fnfempe/France_RFE/tree/v1.4.0.03/FNFE_RFE_INVOICE/Factur-X
- https://github.com/atgp/factur-x/tree/v3.5.0/xsd/factur-x
- https://github.com/ZUGFeRD/mustangproject/tree/core-2.25.0/validator/src/main/resources/schema/ZF_250
