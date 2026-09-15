# Performance protocol

Baseline: `cbd3619`, Ruby 4.0.6 on Linux. The initial suite passed 374 examples with one local pending check, plus 40 companion examples. Initial XML measurements are retained in `benchmarks/baseline-initial.json`.

`bundle exec ruby tooling/benchmark.rb current` measures first XSD validation, warm validation, reading and writing for 1, 100 and 500 repeated lines. It emits timings, allocations, input size, Ruby version and fixture checksum. Repeated-line samples exercise structural processing; they do not claim business-total conformance.

For comparison, run the same script with the unchanged baseline checkout's `lib` on the load path and the `baseline` argument. Both runs below use the new workspace's resolved dependency versions, avoiding a dependency-version confound and any write to the baseline checkout. Run both serially on the same machine. Record JSON rather than adding tight wall-clock CI thresholds.

Schematron and PDF require their real engines. Measure them separately with pinned binary versions and artifact checksums, including parent and child maximum RSS. A subprocess startup or resource check is part of the cost, not subtracted from results. Record cold and warm behavior independently.

Report comparisons in the PR. Do not claim an overall speedup when only allocations improve or when the new resource guarantees add latency. Any persistent engine or alternative PDF implementation requires a separate measured decision.

## Before/after structural comparison

Evidence: [baseline](benchmarks/baseline-comparison.json) at `cbd3619da18f1aefe3c88ee33978d408e98d1e1d` and [current](benchmarks/current-comparison.json), same official source checksum, dependencies, Ruby 4.0.6 and machine. Serialized sizes match exactly for each count. Each cell gives baseline → current milliseconds per call (ten iterations):

| Lines | Write + XSD | Read | Public XML validation, warm XSD |
| --- | --- | --- | --- |
| 1 | 1.17 → 1.64 | 1.56 → 2.31 | 0.09 → 0.51 |
| 100 | 26.09 → 34.11 | 39.82 → 37.20 | 1.03 → 4.01 |
| 500 | 111.98 → 155.15 | 214.33 → 225.39 | 7.01 → 19.27 |

At 500 lines, write allocations change from 265,770 to 321,711; read allocations from 463,356 to 467,462. These results **do not establish an overall speedup**. The public validation path now includes a bounded XML Reader preflight before the DOM; writing adds exact specification resolution and a cryptographic document fingerprint. The separate pipeline results below distinguish raw warm XSD from those surrounding costs. Small timings are sensitive to scheduler/GC noise and the matrix is not a statistically powered benchmark.

Implemented cost reductions include bounded shared binding indexes, checksum-keyed schema caching, one parsing context per syntax/operation, direct compile-to-compose without repeated invoice validation, incremental fingerprint hashing and no second hash for a freshly generated resolution. Caller-supplied resolutions are still verified against the whole document. Do not remove resource protections or silently skip business validation to recover baseline timings.

Reproduce from this workspace, adjusting the baseline path:

```sh
bundle exec ruby -I/path/to/unchanged/facturx/lib tooling/benchmark.rb baseline
bundle exec ruby tooling/benchmark.rb current
```

## Real engine pipeline

`bundle exec ruby tooling/benchmark_pipeline.rb` measures the current implementation with real SaxonC and Ghostscript. Configure `EU_EINVOICE_SAXONC_TRANSFORM`, its shared-library search path when necessary, and the documented Ghostscript resource variables. Missing engines, invalid invoices or different extracted XML bytes abort the run instead of emitting a successful result.

The source is the official one-line EN16931 example in `spec/validation_fr/fixtures/xml/en16931.xml`. Samples repeat its line with unique IDs and multiply every monetary total and VAT breakdown by 1, 100 or 500. Country information is retained and the specification is explicit. Each sample must pass real XSD and Schematron checks. The rendered input PDF is the same minimal one-page fixture for every sample: this measures the container, not invoice layout rendering.

Stages are separate: XML parsing with safety preflight; public XML writing including XSD; warm XSD on an existing DOM; Schematron on an existing DOM; PDF composition including input inspection and output verification; extraction from the resulting PDF. XML stages use three iterations; expensive engine stages use one. The shared `InvoiceBenchmark.measure` helper measures elapsed time and parent Ruby allocations. Engine startup and internal worker processing remain part of the measured stage.

A separate sampler process reads Linux `/proc` every 5 ms and is excluded from descendant accounting. It reports absolute parent RSS, the largest individual descendant RSS, the peak sum of descendant RSS and executable-name observations. Those peaks are sampled, can miss short-lived processes and are not simultaneous across fields. Summed RSS double-counts shared pages; it is not PSS or an exact process-tree high-water mark. The sampler allocates outside the measured Ruby process, although sampling still has scheduling overhead. Parent RSS follows the sequential stages and retains allocator history; these measurements should not be compared directly to unsampled timing runs.

The JSON includes fixture/generated-XML checksums, engine versions and binary/resource checksums. Successful samples explicitly record XSD, Schematron and byte-exact extraction checks. This pipeline run supplies current cost and memory evidence; it does not establish a before/after improvement by itself.

### Recorded current run

Raw evidence: [current-pipeline.json](benchmarks/current-pipeline.json). Ruby 4.0.6 on Linux, SaxonC 12.10, Ghostscript 10.06.0. All three samples passed XSD, real Schematron and exact XML extraction. Times below are milliseconds per operation, with the iteration counts described above.

| Lines | XML bytes | Parse | Write + XSD | Warm XSD | Schematron | PDF compose + verify | PDF extract |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 6,276 | 0.19 | 1.33 | 0.15 | 188.6 | 510.7 | 222.0 |
| 100 | 180,919 | 3.45 | 34.54 | 0.37 | 280.3 | 491.6 | 274.5 |
| 500 | 886,924 | 17.72 | 175.52 | 1.56 | 640.3 | 522.9 | 226.4 |

Sampled absolute RSS peaks below are MiB. The parent column is the maximum across stages for that sample; child columns come from their respective stages, and are not simultaneous values to add together.

| Lines | Parent | SaxonC child | Composition Ruby worker | Ghostscript child | Extraction Ruby worker |
|---:|---:|---:|---:|---:|---:|
| 1 | 45.4 | 129.2 | 37.7 | 25.3 | 45.3 |
| 100 | 51.7 | 147.0 | 38.5 | 26.3 | 38.7 |
| 500 | 73.9 | 182.0 | 43.1 | 27.3 | 41.5 |

At 500 lines, writing with XSD allocated approximately 355,412 parent Ruby objects; the separate Schematron call allocated 1,845 and composition 1,492. These counts exclude native-library allocations and allocations inside child processes, which is why RSS evidence is also recorded. The nearly constant PDF times reflect a fixed one-page input and process startup costs in this small sample. One expensive-stage observation per size does not establish a trend or improvement.
