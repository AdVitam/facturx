# ADR 002 — Identity, destination and processing references

Status: accepted.

Use the existing invoice seller/buyer model. Legal identification, electronic address and buyer/order references are separate data. There is no duplicate recipient record and no required B2B/B2C/public flag.

An identifier consists of its scheme and value. The core does not interpret French SIREN/SIRET or German Leitweg-ID. The French package validates and constructs its four addressing forms and emits a core electronic-address identifier.

French addressing forms are SIREN, SIREN_SIRET, SIREN_SIRET_CodeRoutage and SIREN_Suffixe. A Chorus service code and a legal commitment reference are not automatically treated as the same routing field. A syntactically valid address is not evidence that it is active or that a platform accepts it.

Resolution uses an explicit specification or application-configured preferences. Missing identifiers never imply a consumer; an identifier does not prove public/private status. Unknown context remains unknown. Unsupported and ambiguous requests return explicit results.

Network discovery is separate and not implemented in the foundation. A future connector may provide a dated, sourced destination snapshot. It must distinguish not-found, inactive, ambiguous and unavailable; none implies B2C. Multiple addresses cannot be collapsed to the first result.

Sources:

- [French addressing FAQ](https://portail.chorus-pro.gouv.fr/aife_documentation?id=kb_article_view&sysparm_article=KB0012174)
- [French electronic-address scheme](https://portail.chorus-pro.gouv.fr/aife_documentation?id=kb_article_view&sysparm_article=KB0013456)
- [Official specifications, version 3.2](https://www.impots.gouv.fr/specifications-externes-b2b)
- [Peppol buyer electronic address](https://docs.peppol.eu/poacc/billing/3.0/syntax/ubl-invoice/cac-AccountingCustomerParty/cac-Party/cbc-EndpointID/)
- [German routing identifiers](https://e-rechnung-bund.de/faq/leitweg-id/)
