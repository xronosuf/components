# Reliability and Diagnostics Roadmap

Robust diagnostics are a required subsystem for the replacement architecture.

This priority comes directly from production experience with legacy Xronos: organically initialized asynchronous subsystems made failures difficult to isolate, reproduce, recover from, and explain. The old page runtime coordinator was created to solve those operational problems.

The replacement architecture should preserve or improve those outcomes **without automatically recreating the old coordinator**.

## Design objective

A learner page should be able to answer:

- Which subsystems are required?
- Which have initialized?
- Which have failed?
- Which failures are local versus page-fatal?
- Is learner work currently being persisted?
- Can a failed subsystem recover?
- What diagnostic context can be provided to support staff?

A developer/support trace should be able to correlate relevant browser and backend events without exposing sensitive learner data.

## Why the new architecture may support a better mechanism

The new runtime already has explicit package/component boundaries:

- core;
- Modulus agent;
- answer;
- choice-family components;
- hints/foldables;
- MathJax dependency;
- future Sage;
- chrome.

This suggests a distributed lifecycle/health model rather than one monolithic startup chain.

Conceptually, a component/subsystem might expose states such as:

```text
registered
mounting
ready
degraded
failed
recovering
```

The exact API should follow upstream conventions and should not be designed prematurely.

## Required behavioral outcomes

### Failure locality

One broken optional component should not unnecessarily disable unrelated page interaction.

Examples:

- one malformed math expression should not kill every answer box;
- a video integration failure should not disable ordinary math answers;
- Sage failure should affect Sage-dependent content, not static content;
- chrome enhancement failure should not destroy the underlying activity.

### Bounded readiness

Any subsystem that waits for an external condition must have a bounded startup strategy.

Existing good example:

- `@ximera/answer` waits for MathJax with a bounded timeout/polling strategy.

Avoid indefinite polling or silent permanent “loading.”

### State honesty

Distinguish:

- no saved state;
- saved state loaded;
- load failed;
- save pending;
- save failed;
- unauthorized;
- incompatible state.

Never convert a transport/server failure into blank first-visit state silently.

### Recovery

Where possible:

- retry transient persistence failures;
- retry/reinitialize optional subsystems;
- allow MathJax/component recovery without full page reload;
- avoid duplicate effects after retries.

### Structured diagnostics

Prefer structured diagnostic records over ad-hoc `console.log`.

Useful fields may include:

- activity identity;
- publication/build identity where available;
- component/package name and version;
- component DOM/state ID;
- lifecycle stage;
- error category;
- browser/runtime version;
- Modulus request/trace identifier if available;
- Sage request/instance identifier when applicable;
- timestamp;
- retry/recovery outcome.

Do not include unnecessary learner PII.

### User-facing messaging

Learners should receive concise, actionable messages for failures that affect their work.

Examples:

- work cannot currently be saved;
- interactive computation is unavailable;
- part of this page failed to initialize;
- saved work could not be restored safely and was reset.

Avoid exposing raw stack traces to learners.

### Support affordance

Eventually provide a support/error-report mechanism capable of packaging non-sensitive diagnostic context.

Potential data:

- page URL/activity;
- component health summary;
- recent runtime error IDs;
- build/package versions;
- browser information;
- Modulus correlation ID;
- optional learner description.

## Modulus boundary

Modulus already documents useful backend practices:

- commands return typed `Result` values;
- expected failures are values rather than uncaught exceptions;
- request/command logging context exists;
- request IDs and actor context are tracked;
- queued grade work is separated from immediate request handling.

Do not duplicate those mechanisms inside `components`.

Instead, investigate how the browser agent can expose/carry a correlation identifier so a browser support report can be matched to Modulus logs.

## MathJax

Audit MathJax 4 behavior for:

- startup timeout;
- local parse errors;
- malformed generated preamble content;
- asynchronous typesetting after component mount;
- completed-answer rendering;
- accessibility/explorer interactions.

Errors should be localized to affected content where safe.

## Component mount contract

The current conformance kit tests mount/dispatch/persistence behavior but not a complete failure lifecycle.

Future conformance expectations should consider:

- mount throws synchronously;
- mount rejects asynchronously;
- dependency never becomes ready;
- render throws;
- reducer receives malformed input;
- restored data has invalid shape;
- persistence call fails/rejects;
- external state update arrives during a local update.

This can become a high-value upstream contribution because every component package can benefit from the same reliability contract.

## Persistence / Modulus failure testing

Simulate:

- agent never ready;
- state fetch failure;
- empty state;
- malformed state;
- network disconnect;
- reconnect;
- failed save;
- repeated state echo;
- delayed/out-of-order external update;
- unauthorized token;
- expired session/token.

Expected outcomes should be explicit and testable.

## Sage diagnostics

Future runtime Sage should have first-class diagnostics from the start:

- request ID;
- randomized instance/version ID;
- authorization result;
- cache hit/miss;
- dedupe hit;
- execution duration;
- SageCell failure category;
- response parsing failure;
- retry/fallback behavior.

This should not repeat the old pattern where computation failures are difficult to distinguish from page/runtime failures.

## Chrome diagnostics UI

The underlying diagnostic model should belong to runtime/core interfaces where appropriate, while a visible status/support UI may be provided by chrome.

This preserves Jim's replaceable chrome model:

- upstream Ximera chrome can choose a minimal presentation;
- Xronos chrome can expose richer support tools;
- activity/component packages do not depend on UF-specific UI.

## Documentation requirement for reliability PRs

Because reliability mechanisms may add architecture that upstream did not explicitly request, PRs should explain:

1. the concrete failure mode being addressed;
2. why local `try/catch` is insufficient;
3. the behavioral contract introduced;
4. how the design fits package boundaries;
5. how components opt in/use it;
6. how failure behavior is tested;
7. whether the change affects normal successful startup;
8. whether any new public API is introduced.

## Initial priority

Before implementing a large framework:

1. audit existing error paths in core and major components;
2. audit Modulus agent error/reconnect behavior;
3. enumerate current silent/ambiguous failure modes;
4. add tests for those failures;
5. introduce the smallest common lifecycle/diagnostic abstraction justified by evidence.

The goal is robust outcomes, not architecture for architecture's sake.
