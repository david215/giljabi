---
name: to-tickets
description: Break a plan or spec into tracer-bullet tickets with blocking edges, grouped into slices — independently-mergeable PR groups — and publish them to the configured tracker. Use to slice approved work into tickets, or as phase 3 of /giljabi.
---

# To Tickets

Break the work into **tickets** — tracer-bullet vertical slices, each declaring its blocking edges —
and group the tickets into **slices**, each shipping as one independently-mergeable PR.

The issue tracker should have been configured — run `/setup` if `docs/agents/issue-tracker.md` is
missing.

## Process

### 1. Gather context

Work from the conversation and the spec. If the user passes a reference (a spec path, an issue URL),
fetch and read its full body and comments.

### 2. Explore the codebase

If you have not already, explore enough to slice honestly. Use `docs/domain/` vocabulary in titles
and descriptions; respect page invariants in the area. Look for prefactoring opportunities — "make
the change easy, then make the easy change" — and put any prefactor first.

### 3. Draft the tickets

<vertical-slice-rules>

- Each ticket cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) —
  vertical, never a horizontal slice of one layer.
- A completed ticket is demoable or verifiable on its own.
- Each ticket is sized to fit one fresh context window.
- Prefactoring goes first.

</vertical-slice-rules>

Give each ticket its **blocking edges** — the tickets that must complete before it starts.

**Wide refactors are the exception to vertical slicing.** One mechanical change whose blast radius
fans across the codebase — a column rename, a shared-symbol retype — cannot land green as one
tracer bullet. Sequence it as **expand–contract**: expand (add the new form beside the old), migrate
call sites in batches sized by blast radius (each batch a ticket blocked by the expand), contract
(delete the old form, blocked by every batch). When even batches cannot stay green alone, keep the
sequence on a shared integration branch that all block a final integrate-and-verify ticket.

### 4. Group into slices

A **slice** is the PR unit: a set of tickets that merges as one reviewable, revertable, deployable
change. Rules:

- Every slice is mergeable on its own — it leaves the integration branch releasable.
- A slice's tickets' blockers all resolve inside the slice or in earlier slices; edges never point
  forward across a slice boundary.
- Size for a reviewer, not a milestone: a slice a human cannot review in one sitting is two slices.
- A single-slice feature is normal. Do not manufacture slices.

Slices are declared here and revisable mid-flight — implementation may split a slice that grew or
merge two that collapsed; update `slices.md` when it happens.

### 5. Quiz the user

Present the breakdown as a numbered list — per ticket: **Title**, **Blocked by**, **What it
delivers**; per slice: which tickets and what the PR ships. Ask: is the granularity right? are the
edges genuine? do the slice boundaries match how this should be reviewed and merged? Iterate until
approved.

### 6. Publish

- **Local files** → one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`,
  numbered from `01` in dependency order, using the ticket template below. Never one combined file.
- **A real tracker** → one issue per ticket in dependency order, native blocking links where the
  platform has them, `ready-for-agent` label unless told otherwise.

Either way, write `.scratch/<feature-slug>/slices.md`:

```markdown
# Slices — <feature-slug>

| Slice | Ships | Tickets | Status |
| --- | --- | --- | --- |
| 1 — <slug> | <what the PR delivers> | 01–03 | not started |
| 2 — <slug> | … | 04–06 | not started |
```

Do NOT close or modify any parent issue.

<ticket-template>

# <NN> — <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective —
not a layer-by-layer list.

**Slice:** <N — slug>

**Blocked by:** numbers/titles, or "None — can start immediately".

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</ticket-template>

No file paths or code snippets — they go stale fast. Exception: a prototype-produced snippet that
encodes a decision more precisely than prose; trim to the decision-rich part.

**State scope by extent, not by count.** "Removes all of its call sites" survives contact with the
code; "removes all four call sites" is a measurement taken from reasoning. Where a number genuinely
carries the requirement, grep for it first — and read the hits, not the match count.

## Capture as you go

Slicing exposes things no ticket should carry — an unsafe prefactor, a coupling that blocks a clean
slice, a module whose coverage will not support the change. Append each to
`.scratch/<feature-slug>/findings.md`, one line, newest last:

```
- <what you found> — <where it bites> [tickets]
```

A finding is not a ticket. A ticket is work someone will do; a finding is something true nobody is
acting on. Filing the second as the first is how a backlog fills with items nobody scheduled.
