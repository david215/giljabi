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
paths instead of every edge case.

- **Red before green.** The failing test first, then only enough code to pass it. No speculative
  features, no anticipating future tests.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle — each test a
  tracer bullet that responds to what the last cycle taught you. Never all tests first, then all
  implementation: bulk tests verify imagined behaviour and go insensitive to real changes.
- **Refactoring is not part of the loop.** It belongs to the review, not the red-green cycle.

A good test verifies behaviour through the public interface and reads like a specification —
"user can checkout with valid cart" — with one logical assertion. It survives refactors because it
doesn't care about internal structure. Anti-patterns to refuse:

- **Implementation-coupled** — mocks internal collaborators, tests private methods, asserts call
  counts, or verifies through a side channel. The tell: it breaks on refactor with behaviour
  unchanged.
- **Tautological** — the assertion recomputes the expected value the way the code does, so it passes
  by construction. Expected values come from an independent source: a known-good literal, a worked
  example, the spec.

Where to inject dependencies and what to fake: [mocking.md](./mocking.md).

Run the typechecker and single test files regularly; `docs/agents/testing.md` carries this repo's
commands and traps.

## Knowledge rides the same diff

A change that alters an entity's behaviour updates that entity's `docs/domain/` page **in the same
commit** — and removes each `(intended)` marker this ticket's code just made true (`/knowledge` has
the page contract). This is not a follow-up task; a doc update deferred out of the diff is one that
does not happen, and the review's Knowledge axis will fail the slice for it.

## Route discoveries; never defer them

Mid-implementation discovery gets classified the moment it surfaces:

- **Belongs to this ticket** — fix it in scope.
- **Real but separate** — create a ticket **now**: into this feature's `slices.md` plan when it
  blocks the feature, into the tracker's backlog when it does not. Then carry on.
- **Ambiguous** — put the decision to the user and wait.

There is no deferral pile. Non-work facts — a constraint measured, a gotcha that cost an hour, a
`[friction]` moment with a skill — still go to `.scratch/<feature-slug>/findings.md` as they
surface, one line, unjudged:

```
- <what you found> — <where it bites> [implement]
```

## Delegate discovery, keep decisions

A bounded, read-only question goes to an `Explore` subagent: every call site of `X`, every spec
building a fixture, every importer of a module you are changing. It returns **`file:line` lists,
never counts** — state that contract in the prompt; a subagent reporting a number has thrown the
evidence somewhere nobody can inspect. Decisions and edits stay here — `Explore` has no `Edit`,
which is why it is the right type. This is not "send the ticket to a subagent", which `/giljabi`
forbids: discovery answers a question you already have; implementation decides what to do about the
answer.

## Close out

The ticket is done when: the typecheck and this ticket's suites are green (a red suite means the
work is wrong — fix it, or have the user accept the failure out loud); the pages are updated in the
diff; `/commit` has run on the current branch; and `STATE.md` names the next ticket. Review runs at
slice scope via `/review` — running standalone outside `/giljabi`, run `/review` yourself over the
whole change at the end, and say that you did.
