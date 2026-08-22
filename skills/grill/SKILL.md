---
name: grill
description: A relentless interview that sharpens a plan or design until nothing is silently assumed — mapping the codebase and data first, working the decision tree in rounds, and writing knowledge pages as decisions crystallise. Use when the user wants a plan stress-tested, says "grill me", or as phase 1 of /giljabi.
---

# Grill

Interview the user until you reach a shared understanding. Map the subject as a **design tree**:
every decision branches into the decisions that hang off it. Do not act on the outcome until the
user confirms the understanding is shared.

## Map the territory before round one

When the subject touches existing code, the design tree comes from the codebase, not the user.
Before the first round, find every call site the change touches, what each can reach, and what
already exists to reuse. Timebox it — the shape, not a full reading. Mapping *produces* the
questions: the sharpest question in a session is usually a fork nobody knew was there. Skip the map
and you open by asking the user to describe their own codebase — slower and less accurate than
reading it.

**Delegate the sweep, read the hits yourself.** Send each sweep to an `Explore` subagent — one per
question — returning **`file:line` pointers, never conclusions or counts**; state that contract in
every prompt. Then open the files that matter, here: the map becomes the design tree, and a
summarised map is a secondary source at the moment you most need a primary one.

**Map the data too, when behaviour keys off it.** Code says what *can* happen; only stored data says
how often and to how many rows. Read production **read-only, aggregates before identities** — counts
and distributions first, rows only when the count is small. The map prices existence; the survey
prices importance — a question deserves attention in proportion to the population it governs. If you
cannot reach the database, write the SQL to `.scratch/<feature-slug>/`, show it, and ask — do not
proceed on an unrun survey without saying the spec rests on unmeasured assumptions.

## Name the feature after its outcome

`.scratch/<feature-slug>/` is named at the moment of maximum ignorance. Slug the **outcome**, never
the mechanism — mechanisms are what a grilling overturns. A term already on a knowledge page is the
safest choice; it survived this scrutiny once. `/to-spec` owns the checkpoint that renames while it
still costs one `mv`.

## Work the tree in rounds

The **frontier** is every decision whose prerequisites are settled — askable now without guessing at
answers you haven't heard. Ask the whole frontier each round; a question depending on another still
open this round belongs to the next. Each answer reshapes the tree; recompute and go again. The
session is done when the frontier is empty.

Each question goes on **both** surfaces:

```
❓ **Q1** — **<title>**: <the reasoning, at whatever length the argument needs>

➡️ <your recommended answer>
```

…and `AskUserQuestion`, one question per frontier item, recommendation first and labelled
`(Recommended)`. They carry different content, not two copies: the tool's labels cannot hold an
argument, and prose cannot be clicked. Four questions per tool call at most — on a wider frontier,
ask the remainder in prose rather than dropping it.

**Facts are your job; decisions are the user's.** A question needing a fact from the environment
goes to a lookup or a subagent, never to the user — and an unfinished lookup only blocks the
questions downstream of it, so ask the rest of the frontier now.

Grill hard means challenging premises, not collecting preferences: when the user's frame is wrong,
argue against it with evidence before asking within it.

## Checkpoint continuously

After every round, write the settled decisions and open branches to
`.scratch/<feature-slug>/findings.md`. A long grilling outlives its window; the checkpoint is what
lets a mid-phase `/clear` re-enter from files instead of re-interviewing. The main window holds the
conversation — never the greps.

## Write knowledge as it crystallises

Load `/knowledge` and hold the interview to its discipline: challenge terms against existing pages,
sharpen fuzzy language to one canonical term, cross-reference claims with code. The moment a
decision or term settles, write it to the entity's page — marked `(intended)` where the code does
not yet make it true. Do not batch; phase 4 commits these pages as the plan.

Findings that are neither terms nor decisions — a defect passed by, a measured constraint, a gotcha
— append to `findings.md` as they surface, one line, unjudged.
