# Future Work

This file records valuable work that should **not** distract from baseline usability and legacy parity.

Items here are intentionally lower priority unless production needs change.

## Optional progress contributors

Provide a way for normally progress-bearing content to remain fully interactive while opting out of progress calculation.

Primary use case:

- optional practice problem that behaves exactly like a problem;
- answer marking, feedback, persistence, randomization, and Try Another all continue to work;
- success/failure has no effect on course/activity progress.

A generalized declarative mechanism is preferable to special-casing individual component types.

Possible conceptual forms include an author option or generated attribute such as `data-progress="ignore"`, but syntax should be decided only after reviewing upstream conventions.

This is a genuinely new feature and should not block baseline usability.

## Richer progress model

Once baseline progress is understood, consider supporting explicit progress contributors beyond problem environments, for example:

- watched video percentage/completion;
- selected interactive simulations;
- manually declared milestone components.

Avoid returning to legacy behavior where every arbitrary environment implicitly contributed.

## Instructor free-response workflow

Current free response correctly distinguishes “submitted” from “correct.”

Future work may include:

- instructor review queue;
- rubric/comments;
- grade contribution;
- resubmission policy;
- LMS synchronization.

## Coordinator aggregate statistics

Implement the previously desired coordinator-only reporting mode:

- aggregate across LMS contexts;
- dedicated authorization;
- custom date ranges;
- answer-box report generation;
- aggregate-only privacy boundary.

## Statistics persistence/retention strategy

If raw event history is eventually pruned:

- preserve useful derived aggregates where practical;
- define retention periods;
- separate operational diagnostics retention from pedagogical analytics retention.

## Xronos-specific chrome

Once upstream chrome contracts stabilize, build an institutional chrome package rather than forking core behavior.

Potential UF/Xronos responsibilities include:

- branding;
- support links;
- richer diagnostics/support UI;
- instructor controls;
- accessibility additions;
- institutional navigation conventions.

The underlying activity packages should remain usable without Xronos chrome.

## Better publication-state identity

If cross-publication state preservation becomes important, investigate stable semantic component identities rather than positional generated IDs.

Possible ingredients:

- authored labels/keys;
- generated source-location fingerprints;
- content/build version;
- per-component state schema version;
- explicit migration hooks.

Do not add this complexity unless real author/learner workflows justify it.

## Component state schema migrations

As packages evolve, consider optional component-specific state migrations:

```text
old component state
    -> validate version
    -> migrate if supported
    -> reset locally if unsupported
```

Prefer local component reset over corrupting unrelated page state.

## Runtime Sage hardening

After basic Sage functionality works:

- bind authorization to trusted deployments/origins;
- bind execution to exact approved request/code hashes;
- consider build-time Sage manifests;
- prevent arbitrary browser-supplied code execution;
- rate-limit and resource-bound requests;
- expose operational metrics.

This extends the existing Xronos/SageCell security direction into the new architecture.

## Offline/local persistence

If Jim's server-light vision expands, investigate whether pages can temporarily preserve work locally when Modulus is unreachable and safely reconcile later.

This requires careful conflict semantics and should not be attempted until Modulus behavior is fully understood.

## Content deployment atomicity

For static deployment, investigate versioned/atomic deployment strategies that prevent:

- new HTML loading old bundles;
- old xourse navigation linking to incomplete new activities;
- mixed revisions during publication.

## Automated compatibility corpus

Build CI capable of compiling and testing representative public Ximera courses.

Potential layers:

- compile smoke tests;
- generated HTML snapshots where stable;
- browser interaction tests;
- persistence round trips with mock Modulus;
- accessibility checks;
- package dependency coverage.

`mooculus/interactiveLinearAlgebra` is an obvious initial real-world corpus.

## Broader xAPI/statistics architecture

Once Modulus event and analytics capabilities are fully understood, decide whether additional Xronos-specific event infrastructure is still required.

Prefer deriving needed statistics from an existing canonical event/activity store over creating a parallel LRS unless a concrete gap requires one.

## Documentation refresh

Once architecture settles:

- update stale upstream docs referencing old directory/package names;
- document package authoring conventions;
- document how to decide core vs component;
- document the end-to-end build/deploy path;
- document Modulus integration assumptions;
- document diagnostics/reliability contracts.

## Certificates and other legacy extras

Re-evaluate non-core legacy features only after the replacement is stable.

Examples include:

- certificates;
- specialized admin tools;
- uncommon repository-management utilities.

Some may be obsolete in the new static/Modulus architecture and should not be recreated automatically.

## Container/service decomposition after parity

Once the system is functionally complete and ownership boundaries are proven in practice, evaluate which responsibilities should become independently deployed/containerized services for UF operations.

Potential candidates:

- Modulus deployment;
- runtime Sage gateway;
- SageCell workers;
- specialized analytics/report workers;
- static hosting/deployment pipeline.

Keep interfaces explicit now so this later decomposition is evolutionary rather than a rewrite.

## Review rule

An item should move out of this file only when one of the following becomes true:

1. production usability now depends on it;
2. it is required for baseline Ximera semantics;
3. it is required to preserve an important legacy Xronos contract;
4. upstream architecture changes make it cheap/necessary to implement immediately.
