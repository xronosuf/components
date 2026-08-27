# Legacy Xronos Parity Roadmap

This file tracks behavior that was important in production Xronos beyond the minimum authoring semantics of `ximeraLatex`.

The objective is behavioral parity where the behavior remains valuable, **not implementation parity**.

## State and persistence contracts

Preserve distinctions such as:

- state found;
- no state yet;
- state lookup failed;
- invalid request;
- unauthorized.

A backend/network failure must never silently become “new blank learner.”

Required eventual properties include:

- durable low-latency persistence;
- reconnect behavior;
- idempotent mutation outcomes;
- observable save failures;
- well-defined stale/conflict handling;
- safe behavior when publication changes invalidate state.

Exact ownership should be coordinated with Modulus rather than duplicated in `components`.

## Runtime readiness and degraded state

Legacy Xronos ultimately needed explicit startup coordination because independent subsystems could fail or race.

The new architecture does not need the same coordinator implementation, but should preserve the useful contract:

- required dependency readiness is bounded and observable;
- optional subsystem failures degrade locally;
- components know whether they mounted successfully;
- users receive meaningful failure behavior;
- developers/support can determine which stage failed;
- recovery/retry is possible where safe.

See `XRONOS_RELIABILITY_AND_DIAGNOSTICS.md`.

## MathJax resilience

Preserve lessons from production:

- a local math parse error should not disable the entire page;
- MathJax startup must be bounded;
- harmless/generated preamble errors should not disable unrelated interaction;
- completed-answer parsing must handle nested braces correctly;
- failures should identify the affected component/expression where practical.

MathJax 4 changes the mechanism; preserve the reliability outcome.

## Answer/validator behavior

Important legacy capabilities to evaluate or restore:

- targeted feedback;
- custom validators;
- grouped validators / atomic submission;
- correct handling of async/stale validator results;
- multiple-answer interactions;
- no post-correct submissions in pedagogical statistics.

Do not assume every legacy validator mechanism belongs in the browser. Choose the owner based on security, portability, and the new package architecture.

## Sage / runtime randomization

This is a major parity workstream and likely largely UF/Xronos-owned.

Required eventual concepts:

- runtime Sage component;
- trusted gateway between browser and SageCell;
- authorization;
- request/content identity;
- cache;
- in-flight deduplication;
- fallback/error behavior;
- structured logs/diagnostics;
- randomized instance identity;
- Try Another;
- reproducible seed semantics;
- future code/request manifest or hash authorization.

Do not expose SageCell as an unrestricted browser-trusted execution endpoint.

Distinguish clearly between:

- publication revision;
- randomized instance;
- Try Another episode.

## Grade semantics

Coordinate with Modulus/LMS ownership.

Desired legacy contracts include:

- correct denominator/weight handling;
- monotonicity where appropriate;
- explicit handling of instructor/manual LMS overrides;
- ability to intentionally resume/force synchronization after an override if supported;
- Canvas late policy honored by passback where possible;
- Canvas blank/dash before first launch;
- actual zero after launch when appropriate;
- durable, idempotent, observable passback;
- no false success on LMS rejection.

Investigate how Modulus models xourse/activity contribution and grade high-water behavior before adding anything in `components`.

## Statistics and event semantics

Important production Xronos behavior to preserve includes:

- answer-box attempted count;
- eventual correctness;
- attempt distribution;
- never-correct count;
- mean attempts to first correct;
- mean attempts overall;
- Try Another treated as a new episode;
- submissions after the learner's first correct submission for the same answer box and same problem version excluded from pedagogical frequency/common-submission pools and averages.

Potential ownership should be reconsidered rather than copied from the legacy LRS design:

- browser emits semantically meaningful events;
- Modulus stores activity events/state where appropriate;
- statistics UI/service derives reports.

Do not rebuild an LRS merely because old Xronos had one if Modulus can provide the needed event substrate.

## Instructor answer-box statistics

Desired eventual capability:

- instructor can inspect answer-box statistics in the current LMS/context;
- completed answer boxes still expose an authorized stats control;
- statistics are aggregate and privacy-conscious;
- report semantics honor first-correct filtering and Try Another episode identity.

## Coordinator aggregate statistics

Legacy roadmap requirement:

- coordinator-only aggregate access across LMS/LTI contexts for an activity;
- explicit authentication/authorization;
- aggregate-only data;
- selectable custom date range;
- on-demand report generation is acceptable because these reports are infrequent.

This is beyond baseline learner usability.

## Free response

Current new behavior—submitted but not automatically “correct”—is a good interim model.

Longer term:

- learner should not be penalized merely because no automated grading path exists;
- instructor review/grading workflow may be needed;
- grade contribution should remain explicit.

## Support and diagnostics

Legacy production proved the need for:

- user-facing error/support affordance;
- enough state/runtime context for support;
- correlation with backend errors;
- errors localized to subsystem/component;
- visible save/state failures.

Treat this as parity-critical rather than optional polish.

## Mobile and responsive behavior

Retain production lessons:

- mobile must display content rather than trapping the learner in navigation;
- two-pane layouts should only activate when appropriate;
- navigation and content should scroll correctly;
- responsive chrome should not alter activity semantics.

This may belong primarily in upstream/institutional chrome.

## Author JavaScript compatibility

Legacy content uses author JavaScript in multiple ways.

Need to distinguish:

- supported historical authoring construct;
- unsafe arbitrary code;
- static script needed only for display;
- code interacting with Ximera state/runtime;
- code that should migrate to a proper package/component.

Compatibility should be deliberate and security-aware.

## Static/repository behavior

Even in a static architecture preserve equivalent outcomes:

- stable xourse/activity paths;
- missing assets produce meaningful 404 behavior;
- supported old/new compiler markup remains usable where promised;
- navigation links remain deterministic;
- content deployment is atomic enough to avoid mixed-revision pages/assets.

## Authentication / identity failures

Legacy runtime experience showed that identity failure is qualitatively different from “no saved state.”

The replacement should expose explicit behavior for:

- anonymous/open use where allowed;
- authenticated Modulus use;
- expired/invalid credentials;
- unavailable identity service;
- unauthorized activity/state access.

These states must not be collapsed into first-visit behavior.

## Exit criterion

Legacy parity is sufficient when the replacement system can serve real UF/Xronos courses without losing the important learner, grading, statistics, randomization, diagnostic, and instructor contracts that production operation has shown to matter.
