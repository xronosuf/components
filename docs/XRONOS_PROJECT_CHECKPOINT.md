# Xronos / Ximera Replacement Project Checkpoint

This document records the current architectural understanding for development on the `xronosuf/components` fork. It is intended as a durable checkpoint so later work can resume without reconstructing the design discussion from chat history.

It does **not** supersede upstream design decisions from Jim Fowler or the Modulus team. Where upstream behavior is still evolving, this file records current evidence and open questions rather than treating provisional behavior as fixed.

## Guiding principle

**Preserve the contract. Reconsider the mechanism.**

Legacy Xronos is most valuable as a behavioral and compatibility oracle. The replacement stack should preserve important learner, instructor, author, grading, and operational contracts without mechanically porting the old server implementation.

## Project ownership and design authority

- Jim Fowler is the primary architectural authority for the new replacement Ximera runtime and package model.
- Contributions from the UF/Xronos side should align with Jim's modularity and portability goals rather than rebuilding a monolithic Xronos server around the new code.
- The UF/Xronos side has particularly strong authority and practical experience in:
  - `ximera.cls` / `ximeraLatex` semantics and the distinction between core class behavior and optional capabilities;
  - legacy Xronos compatibility requirements;
  - runtime SageCell/randomization/Try Another behavior;
  - diagnostics, supportability, and operational failure handling learned from production Xronos.

## High-level replacement architecture

The emerging system is not a conventional replacement Xronos server. It is a set of separable systems:

```text
author LaTeX
    |
    v
tex4npm build
    |
    +--> static HTML / JavaScript / CSS
    |
    v
learner browser
    @ximera/core + @ximera/* components + chrome
    |
    v
@modulus-learning/agent
    |
    v
Modulus
    |
    v
institutional LMS (e.g. Canvas via LTI 1.3)
```

Runtime Sage/randomization is expected to become an additional service boundary rather than being folded back into a monolithic web server.

A plausible future institutional deployment therefore separates responsibilities such as:

1. author/build environment (`tex4npm`, TeX Live, optional build-time SageTeX);
2. static content hosting (S3/CDN/nginx/etc.);
3. browser runtime (`@ximera/core` and component packages);
4. Modulus for activity state, identity, analytics, LTI, and grades;
5. future runtime Sage gateway;
6. SageCell compute service;
7. optional future analytics/diagnostic services where justified.

This decomposition is naturally container-friendly, but containerization should follow meaningful service boundaries rather than creating containers merely for appearance.

## Jim Fowler's stated package vision

Jim explicitly described the repository as containing `tex4npm` and the `ximera-*` components split apart, with the intent that the Ximera packages be published through npm so the system can run anywhere.

He also explicitly described page chrome as replaceable: the idea is that an installation could swap `ximera-chrome` for something like `xronos-chrome` without replacing the underlying activity/runtime packages.

The current code also uses Modulus and MathJax 4.

## Relationship to `ximeraLatex`

The current package split appears to follow this rule of thumb:

> **Composable Ximera capabilities become independent packages; fundamental document semantics/infrastructure required by the Ximera class remain in core.**

This is a useful architectural rule, but it is not a mechanical one-to-one mapping from historical `.dtx` files to npm packages.

Examples of capabilities already extracted into packages include answers, choices, multiple-choice/select-all/word-choice, hints, foldables, free response, dialogue, video, proof, verbatim, and related components.

Core retains foundational LaTeX/document semantics and a substantial portion of the historical `ximeraLatex` source.

When deciding whether an unported `.dtx` feature belongs in core or a separate package, use all of the following evidence:

1. Jim's existing package split;
2. historical `ximeraLatex` semantics;
3. whether the feature is genuinely optional/composable;
4. whether it requires independent browser state/runtime behavior;
5. active `ximera.cls` developer expertise.

Do **not** create packages mechanically just because a `.dtx` file exists.

## Real integration corpus

Jim's live Linear Algebra demo was traced to the public repository:

`mooculus/interactiveLinearAlgebra`

The master xourse source is:

`LinearAlgebraInteractiveIntro.tex`

Its abstract, parts, and `\activity{...}` sequence match the live deployed xourse. For example, `VEC-0030/main.tex` contains `\title{Vector Arithmetic}`, matching the live tile.

This repository should be treated as an important integration corpus because it contains real production-style Ximera content and a broad range of environments/interactives.

## `tex4npm`

`tex4npm` is the new build system that turns authored LaTeX into static deployable artifacts.

Current evidence shows a pipeline roughly consisting of:

1. discover installed packages with a `latex` field;
2. stage TeX assets into a private TEXMF tree;
3. synthesize browser bundle entry points;
4. run TeX passes;
5. run optional **build-time SageTeX** when required;
6. run tex4ht/t4ht;
7. collect artifacts;
8. run package-specific post-processing hooks;
9. materialize xourse navigation/chrome;
10. deploy static artifacts, including S3 support.

Build-time SageTeX must not be confused with runtime SageCell/randomization.

## Browser runtime

`@ximera/core` is the browser runtime kernel. Production startup injects a real `@modulus-learning/agent`, while the kernel remains injectable/testable.

Important existing concepts include:

- component registration;
- reducer registration;
- render registration;
- dispatch;
- model persistence;
- activity progress calculation;
- nested problem gating and correctness propagation;
- reset;
- conformance tests and mock-agent support.

The runtime is structurally much cleaner than legacy Xronos, but structural cleanliness must **not** be mistaken for robust operational diagnostics. Runtime lifecycle, failure isolation, recovery, and user/developer-visible diagnosis remain areas for careful review.

## Modulus

The relevant public repository is:

`Modulus-Learning/app.modulus-learning.org`

Its documented three-tier architecture is:

```text
Institutional LMS  <->  Modulus  <->  instrumented Ximera activity
```

Modulus owns concerns including:

- LTI 1.3/OIDC integration;
- activity launch and registration;
- page-state persistence;
- normalized progress reporting;
- learner activity analytics;
- grade processing/passback;
- Postgres persistence;
- queued score submission;
- privacy boundaries between LMS identity and open Ximera content.

Modulus already has useful backend discipline: typed command boundaries, typed `Result` errors, logging context, dependency injection, and actor-domain separation.

This suggests future Xronos reliability work should focus especially on the **browser/runtime boundary and cross-system correlation**, rather than duplicating backend logging systems Modulus already provides.

## State identity and publication changes

The browser runtime stores state keyed by component/DOM IDs. Normal compiled content generally receives deterministic IDs through LaTeX/tex4ht.

For example, foldable/expandable output uses a compile-time identification counter, producing IDs such as `foldableN` and `accordion-itemN`.

This supports **reload stability for the same publication**, but positional IDs may shift when content is inserted or rearranged.

Therefore distinguish two different guarantees:

### Reload stability

Same published activity -> same generated IDs -> state restores reliably.

This is required.

### Cross-publication state migration

Author changes the page structure -> old state may no longer map semantically onto the new structure.

This may be intentionally unsupported or best-effort. Jim has indicated that the old learner-triggered update mechanism is largely undesirable and that new publications should generally become live directly.

The exact Modulus/runtime behavior for incompatible saved state still needs source-level verification.

## Randomization is a separate identity problem

Do not conflate publication revision with Sage/randomization.

At least three distinct concepts are needed:

1. **publication version** — author changed the activity;
2. **randomized instance/version** — same publication, different Sage-generated instance;
3. **Try Another episode** — learner intentionally requests another randomized instance.

Runtime Sage and Try Another are expected to be a major UF/Xronos implementation responsibility.

## Chrome / institutional theming

The replaceable chrome package is a deliberate extension point.

A future UF deployment should be able to reuse upstream behavior while substituting institutional presentation/support behavior, conceptually:

```text
@ximera/core
@ximera/answer
@ximera/hint
...
@xronos/chrome
```

Institution-specific presentation should remain isolated from core learner behavior wherever practical.

## Containerization principle

UF IT has requested decomposed/containerized infrastructure where practical.

The architectural rule should be:

**Design explicit contracts and separable responsibilities first; containerize meaningful service boundaries second.**

Avoid hidden shared filesystem state, implicit process globals, or assumptions that all capabilities live on one host. At the same time, do not split simple in-process modules into network services unless there is an operational reason.

## Reliability principle

A critical lesson from legacy Xronos is that runtime diagnostics and failure coordination are not optional conveniences.

The old runtime coordinator existed because organically initialized subsystems made failures difficult to isolate, recover from, and explain. The new component architecture may permit a better mechanism, but it must deliver comparable or improved outcomes:

- know which subsystem failed;
- avoid one local failure unnecessarily disabling unrelated interaction;
- present useful degraded-state behavior;
- make failures observable to developers/support staff;
- preserve enough structured context to reproduce a problem;
- support bounded startup and recovery instead of indefinite hangs;
- correlate browser/runtime errors with backend requests when practical.

See `XRONOS_RELIABILITY_AND_DIAGNOSTICS.md`.

## Companion documents

- `XRONOS_IMPLEMENTATION_STATUS.md` — implemented, partial, investigate, and missing capabilities.
- `XRONOS_BASELINE_USABILITY.md` — work required for ordinary Ximera/ximeraLatex usability.
- `XRONOS_LEGACY_PARITY_ROADMAP.md` — production Xronos behaviors worth preserving beyond baseline Ximera semantics.
- `XRONOS_RELIABILITY_AND_DIAGNOSTICS.md` — runtime failure handling, degraded state, observability, and supportability.
- `XRONOS_FUTURE_WORK.md` — intentionally deferred post-parity features and architectural improvements.

## Working priority order

1. understand upstream architecture and subsystem ownership;
2. attain baseline usability for normal Ximera/ximeraLatex content;
3. attain important legacy Xronos behavioral parity;
4. add strong diagnostics/reliability where missing;
5. implement runtime Sage/randomization/Try Another;
6. stabilize deployment and institutional integration;
7. pursue genuinely new features after the replacement stack is functional.
