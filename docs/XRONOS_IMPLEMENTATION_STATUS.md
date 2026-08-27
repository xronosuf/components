# Xronos Replacement Implementation Status

This file tracks what is already present in the new `components` architecture, what appears partial, and what still requires verification elsewhere (especially in Modulus).

Status labels:

- **Implemented** — substantial implementation exists in reviewed code.
- **Partial** — important implementation exists, but known behavior or integration remains incomplete.
- **Investigate** — may already exist elsewhere; do not call it missing until the owning subsystem is checked.
- **Missing / planned** — no implementation has yet been identified and new work is expected.

This file should be updated as source-level review continues.

## Build and packaging

| Capability | Status | Notes |
|---|---|---|
| `tex4npm` LaTeX-to-static build | Implemented | TeX/tex4ht pipeline, bundling, package hooks, artifact collection. |
| npm package model for Ximera components | Implemented | `@ximera/*` packages with `latex` metadata and browser entry points. |
| Static deployment | Implemented | S3 deployment support exists; architecture should permit other static hosts. |
| Build-time SageTeX | Implemented | Separate from runtime SageCell/randomization. |
| Xourse materialization/chrome | Implemented | Presentation policy has been moved out of `tex4npm` into package/chrome hooks. |
| Documentation consistency | Partial | Several docs still reflect older directory/package names or earlier architecture. |

## Core browser runtime

| Capability | Status | Notes |
|---|---|---|
| Component registration | Implemented | Public kernel API. |
| Reducer registration | Implemented | Namespaced messages with duplicate/core-type protection. |
| Render registration | Implemented | Component-owned render behavior. |
| Dispatch/model updates | Implemented | Immutable model replacement followed by render and persistence. |
| Modulus agent injection | Implemented | Production core boots with `@modulus-learning/agent`; kernel is test-injectable. |
| Initial state restoration | Implemented | Restores nonempty page state supplied by the agent. |
| Reset | Implemented | Returns work to first-visit model semantics. |
| Nested problem gating | Implemented | Blocking/nonblocking nested problem logic exists. |
| Correctness propagation | Implemented | Direct answerables and child-problem completion propagate. |
| Page progress | Implemented | Currently computed from the problem-environment tree. |
| State schema/version migration | Investigate | Model is a flat JSON map; explicit migration/version handling has not been identified. |
| Cross-publication saved-state reconciliation | Investigate | Likely intentionally limited/best-effort; verify Modulus/runtime behavior. |
| Runtime lifecycle diagnostics | Partial | Local catches/warnings exist; cohesive degraded-state subsystem has not been identified. |

## Interaction components

| Capability | Status | Notes |
|---|---|---|
| Math answer input | Implemented | `@ximera/answer`; symbolic equality via `math-expressions`. |
| Integer/float/string/expression answers | Implemented | Tolerance support included. |
| MathJax-aware answer attachment | Implemented | Bounded polling and asynchronous mount handling. |
| Multiple choice | Implemented | Seeded deterministic shuffle and wrong-attempt history. |
| Select all | Implemented | Package exists; deeper compatibility audit still useful. |
| Word choice | Implemented | Package exists; deeper compatibility audit still useful. |
| Free response | Implemented | Submission marks completion without claiming correctness. |
| Hints | Implemented | Persisted reveal state; accessible interaction. |
| Foldables / expandable behavior | Implemented | Persisted state; normal compiled output receives deterministic IDs. |
| Dialogue | Implemented | Package exists; deeper behavior audit pending. |
| Proof / verbatim / video / xkcd | Implemented/structural | Packages exist; exact parity should be checked against real content. |
| Rich targeted wrong-answer feedback | Partial / Investigate | Core has feedback behavior and historical `feedback.dtx` exists; full legacy semantics not yet established. |
| Grouped validators / atomic answer groups | Missing / planned | No equivalent identified yet. |
| Arbitrary/custom validators | Missing / planned | Legacy Xronos supported richer validator behavior; needs design review. |
| Try Another | Missing / planned | Belongs to Sage/randomization workstream. |
| Runtime Sage/randomization | Missing / planned | Major UF/Xronos responsibility. |

## LaTeX / authoring compatibility

| Capability | Status | Notes |
|---|---|---|
| Core `ximera` / `xourse` class support | Implemented | Large portion of historical class sources retained under core latex. |
| Extracted interaction packages | Partial overall | Many major `.dtx` capabilities have package counterparts. |
| Full `.dtx` inventory classification | Investigate | Need systematic core-vs-package-vs-obsolete audit. |
| Existing production content compile | Partial | Jim's `interactiveLinearAlgebra` demo proves substantial real content works. |
| Historical corpus compatibility | Investigate | Need broader course corpus and automated regression coverage. |
| Author JavaScript compatibility | Investigate / planned | Important compatibility area; current package status unclear. |
| Desmos / GeoGebra / Doenet integrations | Investigate / planned | Historical `.dtx` modules exist; new package counterparts not yet identified. |
| Runtime Sagemath integration | Missing / planned | Historical authoring semantics exist; new runtime service/component needed. |

## Modulus-owned functionality

The following should not be reimplemented in `components` unless an explicit interface gap is found.

| Capability | Status | Notes |
|---|---|---|
| LTI 1.3 | Implemented in Modulus | OIDC, launch, deep linking, AGS. |
| Page-state persistence | Implemented in Modulus | Exact conflict/version semantics still need source audit. |
| Progress ingestion | Implemented in Modulus | Normalized 0-1 progress. |
| LMS grade passback | Implemented in Modulus | Queued worker architecture documented. |
| Backend typed errors/logging | Implemented in Modulus | Command `Result` errors and logging context. |
| Analytics/activity database | Implemented in Modulus | Suitability for Xronos statistics requirements still needs audit. |
| Learner identity/privacy boundary | Implemented in Modulus | Open activity receives intentionally limited identity/context. |

## Operational / instructor functionality

| Capability | Status | Notes |
|---|---|---|
| Learner-facing open activity delivery | Implemented | Static/open page model. |
| Institutional theming via replaceable chrome | Implemented as architecture | `ximera-chrome` is intentionally swappable. |
| Xronos-specific chrome | Missing / future | Build only after upstream chrome contract stabilizes enough to justify it. |
| Instructor answer-box statistics | Missing / investigate | May be partly supportable from Modulus analytics; UI/semantics not identified. |
| Coordinator aggregate statistics | Missing / future | Legacy requested feature. |
| Manual free-response grading queue | Missing / future | Current free response is intentionally ungraded. |
| Runtime support/error-report UI | Missing / planned | High-value reliability contribution. |
| Certificates | Missing / future | Legacy/non-core feature. |

## Important distinctions

### Implemented does not mean production-complete

A package may have substantial implementation while still needing compatibility, failure-mode, accessibility, or integration testing.

### Investigate does not mean missing

Modulus and other independently developed subsystems may already own behavior that should not be duplicated in `components`.

### Runtime Sage is not build-time SageTeX

The existing `tex4npm` SageTeX pass does not provide learner-time randomization, Try Another, or SageCell execution.
