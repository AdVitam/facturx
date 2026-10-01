# eu-einvoice-container-pdf

Bounded PDF inspection, extraction and composition using Ghostscript. Require `eu_einvoice/container/pdf`. Embedding metadata is supplied by the document pack.

The application supplies its visual PDF. Ghostscript, zugferd.ps and an RGB ICC profile are external system dependencies. Private temporary files and isolated PDF workers are used; caller-owned IO is not closed or rewound.
