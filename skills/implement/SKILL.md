---
name: implement
description: Implement one ticket (or a small spec) test-first — red-green at pre-agreed seams, knowledge pages updated in the same diff, discoveries routed to tickets or decisions instead of deferred, closed out with a commit. Use for each ticket in phase 5 of /giljabi, or standalone for any test-first build or fix.
---

# Implement

Implement the work one ticket describes, test-first, and leave nothing implicit behind: the tests
prove it, the knowledge pages state it, the commit carries it.

## Test-first: the loop

Red → green, at **pre-agreed seams**. A **seam** is the public boundary you test at — the interface
where behaviour is observed without reaching inside (everything a caller must know: types, but also
invariants, ordering, error modes). Before writing any test, write down the seams under test and
confirm them with the user — usually the spec already did; re-confirm only what it left open. Tests
at unconfirmed seams don't get written: agreeing seams up front is how effort lands on critical
paths instead of every edge case. A seam over an input enumerates the value classes the transport
allows — absent, present, `null`, empty — one case each where the spec distinguishes them; a
present/omitted table never sends the `null` a client can.

- **Red before green.** The failing test first, then only enough code to pass it. No speculative
  features, no anticipating future tests.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle — each test a
  tracer bullet that responds to what the last cycle taught you. Never all tests first, then all
  implementation: bulk tests verify imagined behaviour and go insensitive to real changes.
- **Refactoring is not part of the loop.** It belongs to the review, not the red-green cycle.
- **Red by mutation when the behaviour already exists.** A guard spec over shipped behaviour cannot
  go red by being written, so prove it red the other way: snapshot the green file (`cp <file>
  <scratch>`) **immediately before** the mutation, break the source in the one way the spec guards —
  flip the constant, shift the index, swap the fixture — watch the spec fail, then restore from the
  snapshot and `cmp` proves it. `git checkout -- <file>` restores `HEAD`, and on a test-first run
  `HEAD` is not your green file. A guard spec that never went red guards nothing.

A good test verifies behaviour through the public interface and reads like a specification —
"user can checkout with valid cart" — with one logical assertion. It survives refactors because it
doesn't care about internal structure. Anti-patterns to refuse:

- **Implementation-coupled** — mocks internal collaborators, tests private methods, asserts call
  counts, or verifies through a side channel. The tell: it breaks on refactor with behaviour
  unchanged. A spec that pins a helper's ORM or query call shape is this smell even when the helper
  is "the unit": where a convention page names a module boundary, the seam sits at that boundary,
  never below it. A seam that rule refuses is the user's decision, never yours — accept is
  human-only here as in review — unless this ticket's diff redraws that page's boundary, in which
  case the page change lands first and the seam follows the rule as rewritten.
- **Tautological** — the assertion recomputes the expected value the way the code does, so it passes
  by construction. Expected values come from an independent source: a known-good literal, a worked
  example, the spec.

Where to inject dependencies and what to fake: [mocking.md](./mocking.md).

Run the typechecker and single test files regularly; `docs/agents/testing.md` carries this repo's
commands and traps. Three reads come before the first edit: `docs/conventions/README.md` and the pages
it names for whatever the ticket writes — comments and their language, naming, layout; the
`docs/domain/` page of every entity the ticket changes; and the `docs/platform/` page of every
technology the ticket's code calls into — the ORM, the database, the framework — found through
`docs/platform/README.md`. A trap learned here costs one read; learned from the review it costs a
round.

A red spec whose output shows no cause: look first at what the spec mutes — a spied logger, a
swallowed rejection — before reading the code it exercises. The cause printed; the spec ate it.

## Knowledge rides the same diff

A change that alters an entity's behaviour updates that entity's `docs/domain/` or `docs/platform/`
page **in the same commit**, regenerates the index, and removes each `(intended)` marker this
ticket's code just made true (`/knowledge` has the page contract, the marker rule and the index
script). Updating means putting every behaviour this ticket changed through `/knowledge`'s
anti-inference test — *would a reader working from code alone arrive at the opposite?* — and writing
each line that passes: a column nullable in the schema that no writer leaves null, a path no caller
can reach. The review's Knowledge axis runs the same test over the diff and fails what is missing.
This is not a follow-up task; a doc update deferred out of the diff is one that does not happen.

The entity's page is not the only page that talks about its code. Read its **neighbourhood** — the
`related:` ids on the page's index line, or `/knowledge`'s lookup — for every claim about the code
this ticket changed, and rewrite each one that is no longer true, in the same diff. You are the one
session that knows which claim just went stale; the review's axis only catches what you missed.

## Route discoveries; never defer them

Mid-implementation discovery gets classified the moment it surfaces:

- **Belongs to this ticket** — fix it in scope.
- **Belongs to a page** — a trap in the test infrastructure, a behaviour of the stack, a command
  that misleads — is written where its layer lives (`docs/agents/testing.md`, `docs/platform/`, a
  `## Hazards` section) in this diff, like any page update; left in `findings.md` it is relearned
  next run.
- **Real but separate** — create a ticket **now**: into this feature's `slices.md` plan when it
  blocks the feature, into the tracker's backlog when it does not. Then carry on.
- **Ambiguous** — put the decision to the user and wait.

A decision the ticket leaves open across several sites — one refusal for three strategies, one
default for seven fields — is taken after reading what each site consumes, and the reading goes in
`findings.md` beside the decision.

A discovery that changes what the plan asserts — a path dropped, an error shape corrected — is an
**amendment**, and it lands on every artifact carrying the claim in the same turn: `spec.md`, the
knowledge page, and every open `issues/*.md`. Grep the changed fact across
`.scratch/<feature-slug>/` **and `docs/`** and rewrite each hit; re-read the spec's Out of Scope and
Testing Decisions whole, since an appended amendment contradicts the line it did not read; the
amendment is done when the grep returns nothing. An open ticket still describing the old shape is
the next window's spec.

There is no deferral pile. Non-work facts — a constraint measured, a gotcha that cost an hour, a
`[friction]` moment with a skill — still go to `.scratch/<feature-slug>/findings.md` as they
surface, one line, unjudged:

```
- <what you found> — <where it bites> [implement]
```

## Delegate discovery, keep decisions

A bounded, read-only question goes to a `standard`-tier search subagent (`/giljabi` maps the type per
harness): every call site of `X`, every spec building a fixture, every importer of a module you are
changing. It returns **`file:line` lists, never counts** — state that contract in the prompt; a
subagent reporting a number has thrown the evidence somewhere nobody can inspect. Running a suite is
the same shape — a `fast` agent runs the command from `docs/agents/testing.md` and returns the
failures verbatim, keeping the log out of this window. Decisions and edits stay here. The tier
agents are told not to edit, and told that no tool set enforces it — so say it again in the prompt
(*report only; change nothing*), and treat an unexpected diff after a sweep as the agent's error, not
a gift. This is not "send the ticket to a subagent", which `/giljabi` forbids: discovery answers a
question you already have; implementation decides what to do about the answer.

## Close out

The close-out is a sequence, and the gates are the last step before anything is committed —
an edit made after them is work the gates never saw:

1. **Pages and ticket file.** The pages are updated in the diff. The ticket file records what this
   run finished — its `Status:` line set to `done` where the tracker has one, since `STATE.md` names
   only the next ticket and nothing else says which ones finished.
2. **Gates, over the tree that will be committed.** The typecheck and this ticket's suites, run
   after the last edit to any file — a red suite means the work is wrong: fix it, or have the user
   accept the failure out loud, and every fix returns you to this step. Tick each acceptance box
   from this run's output and only then; a box ticked from an earlier run vouches for code it never
   saw. A note claiming a run was green or a mutation was killed names the command and quotes its
   result line — a reviewer treats a bare claim as unverified, so write what they can check.
3. **`/commit`** on the current branch — delegated to a `standard` agent briefed as `/giljabi`'s
   delegation section says: paths to read, no format instruction of its own.
4. **`STATE.md`** names the next ticket.

Review runs at slice scope via `/review` — running standalone outside `/giljabi`, run `/review`
yourself over the whole change at the end, and say that you did.
