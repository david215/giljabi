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
| 2. Specify | `/to-spec` — drafted by a `deep` agent from `findings.md`, edited here | `spec.md` |
| 3. Slice | `/to-tickets` — drafted by a `deep` agent from `spec.md`, approved here | `issues/NN-*.md`, `slices.md` |
| 4. Commit the plan | — | a small docs PR, merged before any implementation |
| 5. Build, per slice | `/implement` × N, `/review`, `/pr` | code, page updates, one PR per slice |
| 6. Close | — | cleanup, friction routed to retro |

Every phase runs on every feature, a one-line fix included — the phases self-limit (an interview
with no fork has nothing to ask; a spec for a one-line fix is five lines), so there is no size
exemption to judge.

Phases 1–3 need only `docs/domain/` (and tolerate its absence). If `docs/agents/` is missing, say
so once and continue; the gate is at phase 4.

## Phases 2 and 3 — draft delegated, decision here

`/grill` checkpoints `findings.md` after every round so that the transcript is disposable at the end
of phase 1. Phase 2 tests that: spawn a `deep` agent to run `/to-spec` **from `findings.md` and the
repo**, not from this conversation. It returns the draft; you review and edit it here with the user,
then write `spec.md` and publish. If the draft is thinner than the discussion felt, the checkpoint
was thin — fix `findings.md`, re-run the drafter, and log the gap as `[friction]`. Phase 3 is the same
shape: a `deep` agent drafts the ticket breakdown from `spec.md`; the quiz and the publish happen
here.

## Phase 4 — commit the plan

**Gate:** `docs/agents/` must exist from here on — branch names, commit language and the PR host all
come from it. Missing → stop and run `/setup`; a workflow that guesses the integration branch
produces PRs nobody wants.

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
2. **Implement** — one `/implement` run per ticket, a context reset between tickets. Work the
   frontier: any ticket whose blockers are done, lowest number first. Name tickets by **filename**
   (`/implement 03-invitations-follow-organization-timezone`), never by position.
3. **Review** — `/review` at slice scope: fixed point is the slice branch's start, spec source is
   `spec.md` restricted to this slice's tickets; its three axes run as `deep` agents. Loop fix →
   `/review` → `/commit` until green or until a failure is accepted out loud — by the user, not by
   you.
4. **PR** — `/pr`, run by a `standard` agent. Then write `STATE.md` and reset the context.

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

## Delegation and tiers

Work leaves this context when its primary source is an artifact, not the conversation. Three
**tiers** name how much model a delegated job deserves; each fixes model *and* reasoning effort
together, because both answer one question and two knobs is a choice with no rule:

| Tier | Runs | Claude Code | Codex |
| --- | --- | --- | --- |
| `deep` | `/to-spec` and `/to-tickets` drafts; every `/review` axis | agent type `deep` (`fable`, effort high) | `spawn_agent(model: gpt-5.6-sol, reasoning_effort: high)` |
| `standard` | `/pr`; also the inline session default | agent type `standard` (`opus`, medium) | `spawn_agent(model: gpt-5.6-terra, reasoning_effort: medium)` |
| `fast` | `/commit`; test runs; read-only search sweeps | agent type `fast` (`sonnet`, low) | `spawn_agent(model: gpt-5.6-luna, reasoning_effort: low)` |

The Claude Code agent types ship in this repo's `agents/`. `/grill`, `/setup` and `/implement` never
delegate their own work — their primary source is the user. Never verify a tier by asking the model
what it is: self-report is wrong on both harnesses; the harness's session log is the evidence.

## Harness map

Skills name capabilities, not one harness's spelling of them. Where a skill says one of these, do
what this session's harness offers:

| Capability | Claude Code | Codex |
| --- | --- | --- |
| reset the context | `/clear` | `/new` |
| summarise and continue | `/compact` | `/compact` |
| hand off to another session | `/handoff` | write the handoff document by hand |
| ask the user a structured question | `AskUserQuestion` | ask in prose; Codex has no equivalent outside plan mode |
| read-only search subagent | `Explore` | `spawn_agent` with a read-only instruction — Codex has no read-only type, so state the constraint in the prompt |
| tiered subagent | agent types `deep`/`standard`/`fast` | `spawn_agent(model, reasoning_effort)` per the tier table |

Codex subagents can invoke skills and can be pinned to a model (both verified). On an unmapped
harness, translate these six yourself before the first phase and write the translation to
`directives.md`.

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
Directives: 2 active — directives.md
Also:     one-line pointers only — side quests, experiments, warnings
```

Hard cap ~12 lines. **A line may point, never narrate** — slice detail lives in `slices.md`,
outcomes in `findings.md`, operating hazards on knowledge pages. The previous design allowed
narration nowhere and gave overflow no destination, so overflow went here; the destinations now
exist, so use them. Write it when work completes, not when context resets — a reset leaves no turn
to act. Read it first when a session starts mid-feature, then `directives.md`, then the phase's
artifact.

## directives.md — what the user told you to do differently

An instruction from the user that is not spec, not a repo fact, and not a hazard — "skip the e2e
suite this week", "log every skill hiccup to workflow-notes.md", "don't touch the billing module
until Kim's PR lands" — has no page and no ticket. It goes to `.scratch/<feature-slug>/directives.md`
the moment it is said: one line each, current state only, rewritten in place, deleted when it
lapses. Every session start reads it after `STATE.md`; every delegated agent is told to read it. It
is not `findings.md` — that file grows and its register is unjudged discovery; a directive on line
40 is a directive missed.

## Boundaries

At the end of each phase or ticket, take the first yes:

1. **Does the next step need this conversation as a primary source?** Continue. True inside a phase;
   false the moment the artifacts capture it — which phases 2 and 3 exist to do.
2. **Is everything here disposable now?** Reset the context. The usual answer after phase 3,
   between tickets, and after each slice's PR. If the spec reads thinner than the discussion felt,
   fix the spec — don't keep the transcript.
3. **Is the work travelling** — new harness, new repo, a colleague? Hand off.
4. **Can it run unattended, tightly scoped?** A subagent. Discovery sweeps, yes; a ticket, never —
   `/implement` keeps you in the loop by design.
5. Otherwise summarise and continue, with an instruction naming what the next phase needs. Last
   resort, not first reach — a summary is confidently wrong about exactly one decision, and you don't know which.

## Capturing as you go

Every phase appends to `.scratch/<feature-slug>/findings.md` the moment something surfaces — a
defect passed by, a constraint measured, an hour-eating gotcha, a `[friction]` moment with a skill.
Immediate and unjudged: a finding not written within a minute is gone. Routing is judged later —
`/implement` routes discoveries as it works; phase 6 routes friction.

## Before the first run

`/setup` writes `docs/agents/` (vcs, testing, tracker) and the `docs/domain/` scaffold. Phases 1–3
run without it; phase 4 does not (see its gate). Facts may live in other repos — read them wherever
they are. Artifacts are single-homed: `.scratch/`, `docs/`, and every branch belong to the repo
being changed.

## Anti-goals

- **Do not re-explain a phase's skill here.** This file owns sequence and boundaries; each skill owns
  its method. Two copies drift, and this is the copy with no tests.
- **Do not batch tickets into one `/implement` run.** A run spanning four tickets is the context
  problem this skill exists to avoid, wearing a different hat.
- **Do not parallelize slices**, however clean the graph looks. Independently *mergeable* is weaker
  than concurrently *editable*, and nothing computes the stronger property.
