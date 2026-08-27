# Baseline Ximera Usability Roadmap

This file tracks work required to make the replacement stack broadly usable for ordinary Ximera / `ximeraLatex` authored content.

This is intentionally narrower than full legacy Xronos parity. A feature belongs here when normal Ximera content reasonably expects it to work, even if old Xronos never added special behavior around it.

## Goal

A normal Ximera author should be able to take a representative modern `ximeraLatex` course, build it with the new package system, deploy it statically, and have ordinary learner interactions function reliably with Modulus persistence.

## 1. Build a systematic `ximeraLatex` feature inventory

Create a table of historical `.dtx` and interactive modules and classify each as:

- core document semantics;
- independently composable package;
- browser-interactive capability;
- build-only capability;
- obsolete/deprecated behavior;
- intentionally unsupported behavior.

Do not mechanically map one `.dtx` file to one npm package.

Use active `ximera.cls` expertise to settle ambiguous boundaries.

## 2. Identify package gaps

Priority candidates for investigation include historical interactive modules such as:

- JavaScript;
- Sagemath;
- GeoGebra;
- Desmos;
- Doenet;
- other embedded/included interactives.

For each, determine:

1. whether the feature already works through core/static HTML without a package;
2. whether an upstream package already exists under another name;
3. whether it requires browser runtime state;
4. whether it requires an external service;
5. whether current production content actually depends on it.

## 3. Use real course corpora as integration tests

Primary known corpus:

- `mooculus/interactiveLinearAlgebra`
  - xourse: `LinearAlgebraInteractiveIntro.tex`;
  - matches Jim's live `linear-algebra.ximera.cloud` demo.

Add other representative public courses once identified.

The objective is not merely “compiles successfully.” Verify:

- generated navigation;
- MathJax;
- answers;
- choices;
- hints/foldables;
- nested problems;
- feedback;
- images/TikZ;
- video/external interactives;
- persistence/reload;
- progress;
- accessibility-critical interaction.

## 4. Establish stable component identity expectations

Verify all stateful interactive components receive deterministic IDs through the normal LaTeX/tex4ht path.

Current examples include:

- foldable -> `foldableN`;
- expandable/hint -> `accordion-itemN`.

Document two separate guarantees:

- same publication must restore reliably;
- cross-publication state migration may be best-effort or reset-based.

Audit answers, choices, select-all, word-choice, free-response, nested problems, and other stateful components similarly.

## 5. Verify answer semantics against real Ximera expectations

`@ximera/answer` is already substantial, but historical/common options should be audited:

- expression equality;
- numeric tolerance;
- string;
- integer/float;
- input parsing;
- syntax/error feedback;
- option combinations used in production courses;
- interaction with MathJax 4;
- completed-answer reload.

Avoid porting legacy parser quirks unless authors/content actually depend on them.

## 6. Verify choice-family behavior

For multiple choice, select-all, and word-choice, test:

- randomization/shuffle semantics;
- persistence;
- restored selection;
- wrong-attempt behavior;
- correct locking;
- nested problem propagation;
- accessibility;
- compiled correctness metadata.

## 7. Verify feedback semantics

Historical `feedback.dtx` and production Xronos include important pedagogical behavior.

Determine what the new stack currently supports for:

- correct feedback;
- incorrect feedback;
- targeted feedback tied to particular wrong responses;
- feedback depending on multiple answerables;
- reveal timing;
- persisted/reloaded feedback state.

The result may justify either core improvements or a separate component, depending on the authoring semantics.

## 8. Verify nested problems and gating against real content

The new core has explicit nested-problem propagation and blocking logic.

Test at least:

- simple problem;
- nested problem;
- wrapper environments around problems;
- multiple answerables;
- multiple child problems;
- nonblocking problems;
- hidden/uncovered descendants;
- restored completed states;
- problem containers with no direct answerables.

## 9. Verify progress ownership and semantics

Current core progress is based on `.problem-environment` completion rather than every arbitrary environment, which is already conceptually cleaner than legacy Xronos.

For baseline usability, determine:

- what counts as a progress-bearing problem;
- how nested problems are weighted;
- whether videos or other components need progress hooks;
- how xourse/activity weighting interacts with Modulus/LMS grades;
- whether no-problem pages count complete;
- whether progress may decrease locally after reset and how Modulus/LMS treats that.

Do not implement optional-progress exclusion yet; that is tracked as a future feature.

## 10. Verify update/republication behavior

Jim has indicated that the legacy learner-triggered “update” mechanism is not a priority; new publication changes should generally become live directly.

Investigate and document:

- how Modulus identifies an activity;
- what happens when the generated DOM/state shape changes;
- whether invalid/incompatible page state is rejected, reset, partially restored, or ignored;
- how failure is exposed to the learner/runtime;
- whether any content revision identifier exists.

A predictable reset is preferable to silent semantic misalignment.

## 11. Establish baseline error behavior

Even before the full diagnostics roadmap is implemented, ordinary Ximera content must not fail catastrophically because one optional subsystem failed.

Baseline requirements include:

- bounded MathJax wait;
- component mount errors caught and surfaced;
- persistence failures do not masquerade as clean empty state;
- unrelated components continue where safe;
- actionable console/structured diagnostic information;
- visible learner error when state cannot safely be saved/restored.

## 12. Keep browser/runtime APIs portable

New baseline features should not assume:

- a UF-specific host;
- nginx;
- a checked-out repository on the runtime server;
- a monolithic Xronos web process;
- institution-specific routes.

External capabilities should be reached through explicit configuration/contracts so the static/browser-first deployment model remains viable.

## Exit criterion

Baseline usability is achieved when a representative set of real `ximeraLatex` courses can be built and used through the new stack with reliable persistence, core interaction behavior, predictable progress, and comprehensible failure behavior, without depending on legacy Xronos server code.
