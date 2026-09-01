---
name: implementing-dart-features
description: Use when designing or implementing new features, capabilities, user flows, APIs, integrations, or behavior in any Dart or Flutter project that requires requirement clarification, an approved plan, delegated implementation, tests, and independent review.
---

# Implementing Dart Features

## Core Rule

Turn the request into an approved, observable feature contract before editing code. Use bounded
discovery to produce a concise, source-linked Repository Evidence Brief instead of making every
role rediscover the same project facts. Give the approved contract, plan, and evidence brief to
one fresh implementation subagent, then require acceptance by a different review subagent that
was not given the implementation strategy.

Follow all four stages in order. A small feature, an apparently complete specification, time
pressure, or green existing tests never removes discovery, contract formation, explicit approval,
implementation, or independent acceptance. Ask as many user questions as needed to resolve
material ambiguity, and ask none when no material ambiguity remains.

## Roles

| Role | Responsibility |
| --- | --- |
| Primary agent | Investigates requirements with bounded repository discovery, owns the contract, plan, evidence brief, approval, and rework routing |
| Feature implementer | Verifies relevant repository evidence, implements the approved plan, adds tests, and validates an exact candidate |
| Feature reviewer | Independently derives expected behavior, verifies relevant evidence and the candidate without editing, and returns an acceptance verdict |

Use a general-purpose subagent for both delegated roles. Start a fresh implementer and a fresh
reviewer for the first candidate produced from an approved architecture. Resume those contexts
for localized rework under the rules below. Start fresh contexts again when the contract or
architecture changes, ownership is replaced, or review independence is compromised.

An **architectural candidate** is a sequence of implementation revisions that share the same
approved contract, architecture, implementation strategy, state ownership, public contracts,
dependencies, persistence, security policy, and causal neighborhood. Local fixes do not create a
new architectural candidate. Structural strategy changes do.

Reviewer independence means independent derivation and judgment, not wasteful rediscovery of
neutral repository facts. A reviewer may receive source-linked facts, but never the selected
implementation strategy, implementer reasoning, or a proposed patch.

The primary agent owns product decisions, scope, planning, and rework routing. It must not patch
the feature itself, even for a small review finding. Read-only explorer agents may perform bounded
repository searches, but they do not decide requirements, architecture, or acceptance.

Only one agent may edit the worktree for this feature at a time. Reviewers never edit source,
tests, generated files, or configuration.

## Stage 1: Discovery And Feature Contract

Do not edit production code, tests, generated files, or dependencies during this stage. Do not
run an analyzer or complete test suite merely to prepare the plan.

1. Read repository instructions and discover the actual Dart or Flutter commands, workspace
   layout, supported platforms, architectural rules, generated-code rules, available project
   skills, and current worktree state. Preserve unrelated and pre-existing changes.
2. Record a read-only implementation baseline containing the current revision, worktree status,
   relevant untracked paths, and pre-existing changes. For a pre-dirty file inside the causal
   neighborhood, retain enough source-linked baseline evidence to attribute later edits. Do not
   copy unrelated whole-repository diffs into handoffs.
3. Inspect only the feature's bounded causal neighborhood: existing behavior, direct integration
   points, direct callers and dependencies, state ownership, persistence, relevant platform
   implementations, existing tests, and one or two canonical analogous features.
4. Search for existing utilities, extensions, constructors, factories, widgets, design-system
   components, test fixtures, and architectural patterns that may be reused. Expand beyond the
   causal neighborhood only for a named ambiguity, contradiction, or material risk. Do not
   conduct an unrelated whole-repository audit or reconstruct line-level implementation details.
5. Rewrite the request as observable behavior: actors, triggers, inputs, outputs, state
   transitions, errors, empty states, permissions, persistence, and platform-specific behavior.
6. Identify ambiguities that can materially alter user-visible behavior, architecture, scope,
   compatibility, security, migration, or acceptance. Ask the user focused questions, preferably
   grouped by topic.
7. Repeat investigation and questioning until no material ambiguity remains. There is no
   arbitrary question limit. Do not ask the user for facts that can be established from the
   repository, and do not prolong discovery with preference questions that cannot affect the
   implementation.
8. Record non-blocking assumptions explicitly. Never silently invent a product decision.

Stop discovery when repository evidence is sufficient to state observable acceptance criteria,
affected architectural responsibilities, primary integration points, material risks, validation
commands, and unresolved product questions. The primary agent needs enough evidence to constrain
the work, not enough detail to implement it itself.

Produce a **Feature Dossier** containing:

- the original goal and confirmed product requirements;
- current behavior relevant to the feature;
- user and system scenarios;
- observable acceptance criteria;
- input boundaries, loading, empty, success, partial-success, and failure behavior;
- state ownership, persistence, lifecycle, and concurrency expectations when relevant;
- supported platforms, responsive behavior, accessibility, and localization when relevant;
- security, privacy, authorization, and trust-boundary requirements when relevant;
- compatibility, migration, rollout, and dependency constraints;
- explicit non-goals and allowed scope;
- unresolved assumptions, if any, with their proposed defaults;
- runtime acceptance scenarios for user-facing UI.

Acceptance criteria describe outcomes, not implementation. They must be specific enough for a
reviewer to determine whether the feature is complete without seeing the implementation plan.

Also produce a concise **Repository Evidence Brief** in the orchestration context and delegated
prompts. It is a handoff, not a new repository file. Include only:

- the implementation baseline and relevant pre-existing changes;
- relevant paths, public symbols, integration points, and state owners;
- direct callers and dependencies that bound the causal neighborhood;
- one or two canonical sibling implementations and existing test patterns;
- applicable repository constraints, generators, and validation commands;
- source locations for every material factual claim;
- evidence gaps, contradictions, and freshness assumptions.

Prefer paths, symbols, and short conclusions over copied source. Facts in the brief are reusable;
source code remains authoritative. Later roles verify facts at the points they change or rely on
and widen discovery only when the brief is stale, incomplete, contradicted, or insufficient for a
demonstrated risk.

If a material requirement remains unknown, do not plan around a guess. Return to the user with
the question.

## Stage 2: Approved Implementation Plan

Create an **Implementation Plan** from the Feature Dossier and Repository Evidence Brief. Include:

- affected architectural layers and responsibilities;
- existing components and utilities expected to be reused;
- data flow, state transitions, and ownership;
- public contracts, persistence schemas, migrations, and integration points;
- error handling and cleanup behavior;
- a behavior-oriented test matrix;
- generated-code and localization steps;
- any new dependency, platform permission, build-system, or configuration change;
- an ordered implementation sequence;
- a command ledger plan containing the exact final commands, separately required suites,
  expected expensive runs, timeout handling, and justified rerun conditions;
- risks, alternatives, and tradeoffs when more than one viable design genuinely exists.

Keep the plan architectural and outcome-oriented. Do not prescribe line-by-line code or prevent
the implementer from adapting local details to repository evidence.

Present the Feature Dossier and Implementation Plan to the user and wait for explicit approval.
The original request to implement the feature is not plan approval. Highlight dependencies,
migrations, public API changes, destructive behavior, and security decisions separately.

If the user changes a material requirement, update the dossier and plan and obtain approval
again. Refresh affected evidence when the worktree or plan changes. Do not send an obsolete plan
or stale evidence to an implementer.

## Stage 3: Implementation Candidate

Start a fresh general-purpose subagent for the first implementation of an approved architectural
candidate and assign it the **Feature Implementer** role. Give it:

- the approved Feature Dossier;
- the approved Implementation Plan;
- the Repository Evidence Brief and its freshness assumptions;
- repository constraints and applicable project skills;
- the allowed scope and explicit non-goals;
- the implementation baseline and known unrelated worktree changes;
- the required validation commands and command protocol;
- the required implementation report format.

The implementer must:

1. Read repository instructions and load every project skill relevant to the planned work before
   editing.
2. Verify the Repository Evidence Brief and plan against the files, public contracts, state owners,
   direct callers, and integration points it will change or rely on. Inspect the cited canonical
   sibling and relevant existing tests. Do not repeat broad discovery unless evidence is stale,
   incomplete, contradicted by source, or insufficient for a demonstrated risk.
3. Build a test matrix from the acceptance criteria and relevant risks before production edits.
4. Implement the complete approved feature, including tests, dependency injection,
   localization, accessibility, migrations, platform configuration, documentation, and generated
   code where required by the contract or repository.
5. Preserve unrelated changes and avoid opportunistic refactoring. Report adjacent defects or
   cleanup opportunities instead of silently expanding scope.
6. Keep public API and dependency additions minimal. Do not add a dependency, schema change,
   permission, or public contract that was not approved.
7. Follow the repository's architecture and established patterns unless the approved plan
   explicitly changes them.
8. Run the implementation validation gates under the command protocol below.

The implementer may adjust local implementation details when repository evidence supports the
same approved behavior and architecture. It must stop and return `PLAN_CONFLICT` when evidence
requires a material change to behavior, architecture, scope, dependencies, public API,
persistence, migration, security policy, or supported platforms. The primary agent decides
whether to revise the plan and seek new approval.

### Testing Strategy

Coverage means coverage of behavior and risk, not only a line percentage. Obey a repository's
numeric threshold when one exists, but never treat the threshold as proof of completeness.

Use test-first development for domain logic, state transitions, data transformations, validation,
and other isolated behavior when a meaningful failing test can be expressed. Do not manufacture
a RED step whose only failure is that a brand-new type does not compile. UI, platform, and broad
integration work may develop code and tests together, but acceptance coverage remains mandatory.

Select the test levels that prove the contract with the least coupling: unit, Bloc or state,
widget, golden, integration, platform, or deterministic harness tests. Cover the dimensions
relevant to the feature:

- normal success, empty results, partial results, and dependency failures;
- minimum, maximum, malformed, duplicate, and unexpected input;
- retries, cancellation, overlapping operations, late completion, and idempotency;
- lifecycle transitions and deterministic cleanup of streams, subscriptions, controllers,
  timers, isolates, ports, and platform handles;
- persistence, migrations, offline behavior, process restart, and compatibility;
- permissions, authorization, validation at trust boundaries, and secure failure policy;
- localization, text scaling, keyboard or assistive navigation, responsive layouts, and target
  platforms for user-facing UI.

Not every dimension applies to every feature. Choose tests from demonstrated behavior and risk,
not as a ritual checklist. Record material omissions and why they are safe.

Tests must assert observable behavior rather than private implementation details. Mock external
or architectural boundaries, not every internal collaborator. A test must be capable of failing
for a meaningful regression. Never weaken, delete, skip, or broadly rewrite an existing test only
to obtain green output.

### Implementation Quality

Prefer the smallest design that cleanly owns the approved behavior.

- Reuse an existing canonical utility or component instead of creating a local duplicate.
- Do not add speculative APIs, wrappers, configuration, extension points, or abstractions for
  hypothetical future work.
- Keep visibility minimal and remove unused methods, classes, fields, imports, exports, fixtures,
  and generated artifacts.
- A private helper, class, widget, extension, constructor, or factory must express a useful
  responsibility or materially reduce complexity. Do not create pass-through layers solely to
  make files look smaller.
- Extract repeated code only when it represents the same semantic rule or invariant. Do not
  generalize coincidentally similar lines, and do not duplicate the same rule across files when a
  focused shared function, extension, constructor, or factory is the clearer owner.
- Keep feature-specific code within the feature unless it has a demonstrated cross-feature owner.
- Maintain one source of truth for state. Avoid shadow state, temporal-coupling flags, and fields
  that can desynchronize from the resource they represent.
- Avoid broad catches, silent fallback values, unexplained force casts, mutable aliasing, and
  cleanup that depends on a success-only path.
- Do not hand-edit generated files.

Repository-specific rules override generic preferences. For example, a project may correctly
prefer private widget classes over widget-returning helper methods. Judge whether an abstraction
has a meaningful responsibility; do not reject it merely because it is private.

### Dart And Flutter Command Protocol

Discover and use the repository's real commands. The examples below describe gates, not a license
to substitute commands that the project does not use.

Run every `dart`, `flutter`, `fvm`, `melos`, analyzer, generator, and build command sequentially.
Never place two toolchain commands in one parallel or multi-tool call, overlap them across agents,
or start the next command before the previous process exits. Use one analyzer interface per gate;
do not run CLI analysis and LSP or MCP analysis for the same gate.

A hung, timed-out, cancelled, or interrupted command does not pass. Do not start another
toolchain command until the old process has exited. Retry only after identifying and removing a
transient cause such as a startup lock. Never switch command interfaces to bypass a failed gate.

During development:

- Run dependency resolution only when dependencies changed or the environment demonstrably lacks
  resolved dependencies.
- Run targeted tests after a coherent behavior or test slice, not after every file edit.
- Do not repeat an unchanged green targeted test without a relevant code change.
- Use targeted commands to diagnose an observed failure, not to replace required complete gates.
- Settle all generator inputs before code generation. Run each required generator once per code
  candidate and rerun it only when an input changes.
- Do not run broad automatic-fix commands that can create unrelated edits unless the plan or
  repository explicitly requires them.

Maintain a compact command ledger with each toolchain command, its purpose, exit status, duration,
and result. Include only material diagnostics for a failure or warning; do not pass raw successful
output to another agent. Do not repeat an unchanged successful command without a relevant code,
test, generated, dependency, migration, or configuration change.

For the final implementation candidate, run these gates sequentially and fail fast:

1. Run required localization, source generation, schema, or migration commands.
2. Format all hand-written Dart files changed by the implementer.
3. Run the repository analyzer once.
4. Run the complete applicable test suite once. Workspace packages, integration tests, platform
   tests, or golden tests excluded from the default command remain separate required commands.
5. For every user-facing Flutter change, launch or connect to the application, follow repository
   instructions for hot reload or hot restart, exercise the approved primary interaction on the
   representative target sizes or platforms, and inspect runtime errors. If the environment
   cannot perform this check, return `BLOCKED` unless the Feature Dossier contains an explicit
   user-approved runtime-check waiver and its limitations.

These gates belong exclusively to the implementer. A missing, timed-out, cancelled, interrupted,
or failed result does not pass. The primary agent must not start review unless the implementer
returns `IMPLEMENTED`, which asserts that every required final gate passed after the last relevant
change.

Do not run targeted tests immediately before a complete suite that already includes them. A gate
failure rejects the current candidate. Diagnose the failure, make the smallest justified change,
then restart at the earliest affected gate. A new candidate may run the gates again; unchanged
code may not rerun them merely to seek a different result.

If an unrelated pre-existing failure prevents a gate from proving the feature, do not repair it
outside scope. Return `BLOCKED` with the command, output, and evidence that the failure is
unrelated.

### Implementation Report

The implementer returns exactly one status:

- `IMPLEMENTED`: the approved feature is complete and all required gates passed;
- `PLAN_CONFLICT`: repository evidence requires a material plan or contract change;
- `BLOCKED`: the environment, requirements, or pre-existing failures prevent completion.

The report includes:

- changed and created files, including overlap with pre-existing changes;
- implemented acceptance criteria;
- tests added or changed and the behaviors they prove;
- generator, format, analyzer, test, and runtime commands with compact results;
- plan deviations that did not change the approved contract;
- omitted checks, residual risks, and blockers.

The primary agent checks that the report is complete, but does not treat it as independent
acceptance.

## Stage 4: Independent Acceptance

Start a new general-purpose subagent in a fresh context for the first review of each architectural
candidate and assign it the **Feature Reviewer** role. Resume that reviewer for localized rework
within the same architectural candidate. Start a fresh reviewer only under the routing rules
below. Brief each fresh reviewer in two steps within that reviewer's context so implementation
evidence cannot anchor its expectations.

First give the reviewer only:

- the original feature goal;
- the approved Feature Dossier, acceptance criteria, and non-goals;
- repository constraints and allowed scope.

Require it to derive and record its contract, risk, edge-case, and test-adequacy checklist before
inspecting changed implementation files, the diff, changed tests, or implementation evidence.
It may read repository instructions during this step.

Then resume that same reviewer context and give it:

- the Repository Evidence Brief and implementation baseline;
- the changed-file inventory and known unrelated or concurrent worktree changes;
- the implementation diff and changed tests.

Do **not** give the reviewer the Implementation Plan, selected design, patch explanation, or the
implementer's reasoning. The reviewer must derive expected state, edge, failure, security,
concurrency, compatibility, and test behavior before inspecting the diff.

Do not provide design labels or implementation rationales with the evidence. The reviewer
independently enumerates deltas from the baseline instead of trusting the implementer's
changed-file list.

The reviewer inspects the changed files, affected public contracts, direct callers, changed tests,
state owners, one relevant sibling path, and areas required by its risk checklist. It verifies
brief facts where they affect judgment, but does not repeat broad discovery. Expand beyond the
causal neighborhood only for a documented contradiction, missing fact, or material risk. Return
`BLOCKED` when overlapping concurrent edits cannot be attributed safely.

The reviewer never patches findings. It checks:

### Contract And Correctness

- every acceptance criterion is implemented with the approved observable behavior;
- loading, empty, success, partial, failure, retry, cancellation, and lifecycle transitions are
  correct where relevant;
- state has one owner and cannot become stale or contradictory;
- async work, streams, isolates, resources, and callbacks are safely ordered and cleaned up;
- persistence, migration, public API, generated code, and platform behavior remain compatible;
- validation and authorization occur at trust boundaries with the approved fail-open or
  fail-closed behavior;
- demonstrated hot paths avoid unbounded work, avoidable repeated I/O, and materially wasteful
  allocations without speculative micro-optimization.

### Test Adequacy

- tests map to acceptance criteria and relevant edge cases;
- failure, boundary, concurrency, lifecycle, migration, and platform risks are covered when
  applicable;
- assertions observe public behavior rather than private structure;
- mocks do not hide the integration being claimed;
- tests would fail for realistic regressions and are deterministic;
- existing tests were not weakened, skipped, or rewritten without a contract reason;
- coverage gaps are not concealed by a numeric coverage percentage.

### Design And Cleanliness

- the implementation follows repository architecture and uses canonical project utilities;
- no dead, unused, unreachable, speculative, or unrelated code was added;
- public surface and dependencies are no larger than required;
- private helpers and classes have a real responsibility instead of merely forwarding calls or
  fragmenting readable code;
- repeated semantic rules have one appropriate owner, while superficially similar code was not
  over-generalized;
- feature-local behavior was not prematurely moved into a global core package;
- no duplicate source of truth, shadow state, broad catch, silent fallback, unexplained cast, or
  success-only cleanup was introduced;
- documentation, localization, accessibility, and generated artifacts satisfy repository rules.

Do not demand abstraction solely because two snippets look alike. Recommend a shared function,
extension, constructor, factory, widget, or service only when it would own the same stable rule
and reduce real duplication. Likewise, do not accept repeated private helpers across files when
an existing or focused shared owner already expresses that rule.

Review is static acceptance, not a second validation run. Everything sent to the reviewer is
considered formatted, analyzed, fully tested, generated where required, and runtime-checked where
required because review starts only after `IMPLEMENTED`. The reviewer never runs formatter,
analyzer, tests, generators, builds, or runtime scenarios. It judges contract coverage,
correctness, regression risk, test adequacy, and design from repository evidence and the diff.

If inspection finds a blocking issue or missing test, return `REWORK`. The implementer owns every
resulting code or test change and all required validation reruns before review resumes.

### Review Verdict

The reviewer returns exactly one verdict:

- `PASS`: acceptance criteria are proved and no blocking correctness, regression, security, test,
  or maintainability finding remains;
- `REWORK`: implementation changes are required;
- `BLOCKED`: requirements, evidence, environment, or unrelated failures prevent acceptance.

Every `REWORK` finding contains:

- severity;
- file and line;
- concrete evidence;
- violated acceptance criterion, repository rule, or invariant;
- user or maintenance risk;
- required behavior or design outcome, without prescribing an unnecessary patch;
- the missing or inadequate test when applicable;
- a non-binding scope hint of `LOCAL` or `STRUCTURAL`.

Style preferences, hypothetical concerns, and optional enhancements are not blocking findings.
The primary agent, not the reviewer, makes the final rework-routing decision.

## Rework Routing

After `REWORK`, classify the required change semantically rather than by line count or number of
files. Classify it as `LOCAL` only when all are true:

- the approved contract, architecture, causal neighborhood, and state ownership remain correct;
- the defect is bounded, its owner is known, and the existing implementation remains a sound base;
- no public API, dependency, schema, migration, security policy, persistence model, or platform
  contract changes;
- the finding is not a repeat of a previously reported mistake.

For `LOCAL` rework, resume the same implementer context. Send the findings and required outcomes,
not a proposed patch. The implementer updates tests and code and reruns every required final gate
invalidated by the change before returning `IMPLEMENTED`. Resume the same reviewer context
afterward. The reviewer verifies the new delta, the original findings, and the regression radius
instead of restarting discovery or repeating validation commands.

Classify rework as `STRUCTURAL` when any are true:

- the contract was misunderstood or requirements changed;
- the implementation strategy, architecture, causal neighborhood, or state ownership is unsound;
- concurrency, security, persistence, migration, platform behavior, dependency, or public API
  needs redesign;
- a substantial requirement, architectural layer, or test strategy is missing;
- cleanup requires broad removal of speculative, duplicated, or dead structure;
- the same class of finding recurs.

Structural rework creates a new architectural candidate. If it changes the approved behavior,
architecture, state ownership, public contracts, dependencies, persistence, migration, security
policy, platform scope, or material causal neighborhood, return to Stage 1 or Stage 2 as needed,
update the dossier, plan, and evidence, and obtain renewed approval before implementation. A fresh
replacement caused only by repeated findings or broad cleanup may use the still-correct approved
plan.

Start the replacement as a fresh implementation subagent with everything required by Stage 3,
the current worktree state, and reviewer findings, while excluding the previous implementer's
reasoning. It revalidates the whole approved plan and test matrix and takes ownership of the
complete feature. When its candidate is ready, start a fresh reviewer and use the two-phase
briefing from Stage 4.

Even when findings remain `LOCAL`, replace both delegated contexts after the same implementer
receives two `REWORK` verdicts. This is an ownership reset, not by itself a new architectural
candidate, and does not require renewed approval when the existing dossier and plan remain
correct. Brief the replacement implementer under Stage 3 and start a fresh reviewer when its
candidate is ready.

Start a fresh reviewer when any are true:

- a fresh implementer takes ownership;
- the approved contract, architecture, state ownership, public contract, dependency, schema,
  migration, security policy, platform scope, or material causal neighborhood changes;
- the same class of review finding recurs or prior review assumptions proved materially wrong;
- reviewer independence is compromised;
- the previous reviewer context is unavailable or no longer contains a reliable checklist and
  review history.

Do not start a fresh reviewer merely because localized code changed, a command was rerun, missing
evidence was supplied, or a `BLOCKED` condition was removed. Resume the existing reviewer for
those cases. A concurrent change outside the causal neighborhood does not require new agents, but
the implementer must rerun any final gates it invalidates before review starts or resumes. Return
`BLOCKED` when a concurrent change inside the causal neighborhood cannot be attributed safely.

| Event | Implementer context | Reviewer context |
| --- | --- | --- |
| First approved implementation | Fresh | Fresh when the candidate is ready |
| Missing evidence or resolved `BLOCKED` | Resume if already started | Resume if already started |
| Local code or test rework | Resume | Resume |
| Second local `REWORK` or repeated finding class | Fresh | Fresh when the replacement is ready |
| Structural rework | Fresh after any required approval | Fresh when the candidate is ready |
| Approved contract or plan change | Fresh | Fresh when the candidate is ready |
| Concurrent change outside the causal neighborhood | Resume and revalidate if needed | Resume |
| Unattributable overlap inside the causal neighborhood | Stop as `BLOCKED` | Return or remain `BLOCKED` |

Do not send `PLAN_CONFLICT` to review. The primary agent first resolves it, updates the dossier,
plan, and evidence where necessary, and obtains renewed user approval for material changes. An
approved contract or architecture change starts both a fresh implementer and a fresh reviewer.

Track `REWORK` history per architectural candidate and implementer and record each routing reason.
Escalate to the user when a fresh implementer created for structural rework receives another
structural `REWORK` against the same approved dossier and plan. A replacement created only after
two localized verdicts may receive one structural-rework replacement before escalation.

Only `PASS` completes the feature. The primary agent then reports the delivered behavior, changed
areas, tests, validation commands, runtime evidence, and residual limitations.

## Stop These Shortcuts

| Rationalization | Required response |
| --- | --- |
| "The specification is already detailed" | Verify it against the project and turn it into observable acceptance criteria |
| "It is a small feature" | Small scope still requires approval, tests, and independent acceptance |
| "The implementer can decide the unclear UX" | Ask the user when the choice materially changes behavior |
| "The plan says to create this helper" | First search for an existing canonical owner and verify the abstraction is useful |
| "Coverage is high" | Check behavior, boundaries, failures, concurrency, and lifecycle risks |
| "The analyzer would catch dead code" | Inspect for speculative APIs, redundant wrappers, duplicate rules, and useless private structure |
| "Targeted tests passed" | The implementer must run the complete applicable suite before returning `IMPLEMENTED` |
| "The reviewer can fix this tiny issue" | Return it to the implementer and preserve reviewer independence |
| "Every patch needs a fresh reviewer" | Resume the independent reviewer for local rework; start fresh for a new architectural candidate |
| "Independent review must rerun every command" | Validation belongs to the implementer; the reviewer performs static acceptance only |
| "Many changed lines mean a fresh implementer" | Classify rework by contract and architecture, not diff size |
| "The commands are independent" | Dart and Flutter toolchain commands never overlap |

Red flags include production edits before approval, hidden assumptions, unapproved dependencies
or migrations, multiple concurrent writers, implementation by the primary agent, a reviewer
given the selected design, broad rediscovery without a named gap or risk, a reviewer editing files,
review started before `IMPLEMENTED`, reviewer-run formatter, analyzer, tests, generators, builds,
or runtime checks, parallel toolchain commands, hand-edited generated code, tests coupled to
private details, high coverage used to excuse missing behavior, duplicated semantic rules,
speculative abstractions, hidden command failures, or completion without `PASS`.
