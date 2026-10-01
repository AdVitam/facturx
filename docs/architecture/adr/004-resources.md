# ADR 004 — Bounded processing and measurable performance

Status: accepted.

Public inputs are byte strings or explicit IOs. Strings are never filenames. Reads start at the caller's position and do not close or rewind caller-owned IOs. Artifacts retain immutable bytes and create independent read streams.

XML limits apply before DOM allocation. DTD and external entity expansion are rejected and network access is disabled. Safety preflight is a separate bounded pass; one subsequent Ruby DOM is shared within the operation.

PDF object traversal and inflation run in an isolated Ruby process. Logical limits are applied to pages, objects, attachment trees and extracted data. Because pdf-reader inflates a selected stream before returning its bytes, process address-space limits are required to bound that allocation. Linux RLIMIT_AS is tested; it is not a full operating-system security sandbox.

Default budgets: 10 MiB XML, depth 128, 250,000 XML nodes; 50 MiB source PDF, 500 pages, 100,000 PDF objects, 32 attachments, tree depth 64; 100 MiB generated PDF; 60-second process budget and 1 GiB process address space. Override through an immutable ResourceLimits object. Unsupported requested process protections fail explicitly.

The execution deadline includes stdin writes, process execution and stdout/stderr reads. On timeout or cancellation, bounded teardown follows: one termination grace before KILL, at most one grace for the process wait, and at most one grace for each of three IO threads. Thus the explicit waits total at most `process_timeout + 5 * termination_grace` (65 seconds with the default one-second grace), excluding process spawning and OS scheduling. Cleanup is idempotent. Descendant process groups are terminated even when their original leader has exited. These bounds do not turn OS process creation or an uninterruptible kernel task into a hard real-time operation.

Ghostscript uses private temporary files and an OS output-file-size limit in addition to checking size before reading the result. SaxonC remains a per-operation process. Avoiding application-managed files does not mean zero internal filesystem access.

`ResourceLimits` accepts positive integer byte/count/depth budgets and a positive finite `process_timeout`. Instances are immutable, and `to_h` returns the effective budgets. PDF workers use the configured address-space limit; Ghostscript additionally uses the generated-PDF limit as `RLIMIT_FSIZE`. These process protections are mandatory for those adapters: missing platform support raises a structured resource error. The 1 GiB default is a virtual address-space cap, not an RSS measurement or a claim that every host will need that much memory.

Performance optimizations preserve data, immutability and validation coverage. No global document cache or persistent engine pool is introduced. Latency, allocations and child memory costs must be reported separately rather than hidden behind a single throughput figure.
