---
name: giljabi
description: Run a feature from an idea to merged PRs — grill, spec, tickets sliced into independently-mergeable PRs, a plan commit, sequential implementation, three-axis review. Owns the phase order and the context resets; each phase's method lives in its own skill. Use when starting or resuming feature work.
---

# giljabi (길잡이)

Six phases from an idea to merged PRs. This skill does none of the work — each phase belongs to a
skill that exists on its own. What it owns is **the order, the slices, and where the context resets.**

A feature does not fit in one context window. The fix is not a bigger window: **every phase leaves an
artifact**, so the next phase reads a file instead of remembering a conversation. Once that holds, a
reset costs nothing.

| Phase | Skill | Leaves behind |
| --- | --- | --- |
| 1. Interrogate | `/grill` | knowledge pages (`(intended)`-marked), `findings.md` |
| 2. Specify | `/to-spec` | `spec.md` |
| 3. Slice | `/to-tickets` | `issues/NN-*.md`, `slices.md` |
| 4. Commit the plan | — | a small docs PR, merged before any implementation |
| 5. Build, per slice | `/implement` × N, `/review`, `/pr` | code, page updates, one PR per slice |
| 6. Close | — | cleanup, friction routed to retro |

Every phase runs on every feature, a one-line fix included — the phases self-limit (an interview
with no fork has nothing to ask; a spec for a one-line fix is five lines), so there is no size
exemption to judge.

## Phase 4 — commit the plan

Phase 1 wrote knowledge pages carrying `(intended)` claims. Commit them on their own branch and open
a small PR, **merged before implementation starts**. Two reasons: reviewing that PR is reviewing the
design, at design size; and every slice branches from the integration branch, so the plan must be on
it for any slice after the first to see it.

## Phase 5 — build, slice by slice

A **slice** is a group of tickets that ships as one independently-mergeable PR (`/to-tickets`
declares them, in `slices.md`). Slices run **sequentially, always** — never in parallel, whatever the
ticket graph looks like. Per slice:

1. **Branch** — off the integration branch, named by `vcs.md`'s convention over
   `<feature-slug>-<slice-slug>`. If the previous slice's PR has not merged yet, branch off that
   slice's branch instead and say so in the PR description.
2. **Implement** — one `/implement` run per ticket, `/clear` between tickets. Work the frontier:
   any ticket whose blockers are done, lowest number first. Name tickets by **filename**
   (`/implement 03-invitations-follow-organization-timezone`), never by position.
3. **Review** — `/review` at slice scope: fixed point is the slice branch's start, spec source is
   `spec.md` restricted to this slice's tickets. Loop fix → `/review` → `/commit` until green or
   until a failure is accepted out loud — by the user, not by you.
4. **PR** — `/pr`. Then write `STATE.md` and `/clear`.

The ticket close-out — tests green, page updates in the diff, `/commit`, `STATE.md` — fires at the
reset between tickets. Tickets run back to back in one window blur the boundary, and the close-out
is what goes missing.

## Phase 6 — close

After the last slice's PR merges:

```bash
git fetch origin
# 1. The feature's commits are on the integration branch:
git log origin/<integration-branch> --oneline | head -20
# 2. The knowledge pages landed — derive from the merged ranges, not memory:
git diff --name-only <merge-base> <last-merge-commit> -- docs/
# 3. Only when both hold:
rm -rf .scratch/<feature-slug>
```

`.scratch/` is gitignored; a deleted directory is unrecoverable. That is the point — and why the
checks run first, every time.

**Route the friction.** `findings.md` lines tagged `[friction]` — moments a skill fought you, an
instruction that misfired, a gate that checked the wrong thing — append to `retro/inbox.md` in the
giljabi repo checkout. When the user runs a retro there: read the inbox, propose one skill diff per
item, apply each only on their approval, delete the routed lines. Evolution is regular, never
automatic — a skill that edits itself unsupervised is a feedback loop with no test.

## STATE.md — where you are

Artifacts carry content; none carries **position**. `.scratch/<feature-slug>/STATE.md` does,
**overwritten as the closing act of each phase and each ticket**:

```
# State — email-language

Workflow: /giljabi — read that skill before acting
Phase:    5 of 6 — build (slice 2 of 3)
Next:     /implement 04-timezone-backfill
Slices:   1 merged (PR 5699) · 2 in progress: 03 done, 04–05 open · 3 not started
Branch:   feat/email-language-timezone
Also:     one-line pointers only — side quests, experiments, warnings
```

Hard cap ~12 lines. **A line may point, never narrate** — slice detail lives in `slices.md`,
outcomes in `findings.md`, operating hazards on knowledge pages. The previous design allowed
narration nowhere and gave overflow no destination, so overflow went here; the destinations now
exist, so use them. Write it when work completes, not when context resets — `/clear` leaves no turn
to act. Read it first when a session starts mid-feature.

## Boundaries

At the end of each phase or ticket, take the first yes:

1. **Does the next step need this conversation as a primary source?** Continue. True inside a phase;
   false the moment the artifacts capture it — which phases 2 and 3 exist to do.
2. **Is everything here disposable now?** `/clear`. The usual answer after phase 3, between tickets,
   and after each slice's PR. If the spec reads thinner than the discussion felt, fix the spec —
   don't keep the transcript.
3. **Is the work travelling** — new harness, new repo, a colleague? `/handoff`.
4. **Can it run unattended, tightly scoped?** A subagent. Discovery sweeps, yes; a ticket, never —
   `/implement` keeps you in the loop by design.
5. Otherwise `/compact`, with an instruction naming what the next phase needs. Last resort, not
   first reach — a summary is confidently wrong about exactly one decision, and you don't know which.

## Capturing as you go

Every phase appends to `.scratch/<feature-slug>/findings.md` the moment something surfaces — a
defect passed by, a constraint measured, an hour-eating gotcha, a `[friction]` moment with a skill.
Immediate and unjudged: a finding not written within a minute is gone. Routing is judged later —
`/implement` routes discoveries as it works; phase 6 routes friction.

## Before the first run

The repo must be configured — `/setup` writes `docs/agents/` (vcs, testing, tracker) and the
`docs/domain/` scaffold. If `docs/agents/` is missing, stop and run it: a workflow that guesses the
integration branch and commit language produces PRs nobody wants.

Facts may live in other repos — read them wherever they are. Artifacts are single-homed:
`.scratch/`, `docs/`, and every branch belong to the repo being changed.

## Anti-goals

- **Do not re-explain a phase's skill here.** This file owns sequence and boundaries; each skill owns
  its method. Two copies drift, and this is the copy with no tests.
- **Do not batch tickets into one `/implement` run.** A run spanning four tickets is the context
  problem this skill exists to avoid, wearing a different hat.
- **Do not parallelize slices**, however clean the graph looks. Independently *mergeable* is weaker
  than concurrently *editable*, and nothing computes the stronger property.
