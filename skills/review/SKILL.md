---
name: review
description: Review the changes since a fixed point along three axes — Standards (repo's coding standards + smell baseline), Spec (does the diff match what was asked?), and Knowledge (do the docs/domain and docs/platform pages still tell the truth, and is the layer's shape intact?) — in parallel read-only sub-agents, then route every finding through the disposition rule. Use to review a slice, branch, or PR, or as the review step of /giljabi.
---

# Review

Three-axis review of the diff between `HEAD` and a fixed point:

- **Standards** — does the code conform to this repo's documented standards (plus the smell
  baseline below)?
- **Spec** — does the code faithfully implement what was asked?
- **Knowledge** — after this diff, do the `docs/domain/` and `docs/platform/` pages still tell the
  truth, and is the layer's shape intact (placement, generated index, relations)?

The axes run as **parallel read-only sub-agents at the `deep` tier** (`/giljabi` maps the type per
harness) so they don't pollute each other's context. That is a **precondition, not an implementation
detail**: if this session cannot spawn sub-agents, stop and say so before any setup — do not quietly
run the axes in one context, where the report looks the same and is weaker. A reviewer that can edit
will occasionally fix what it found, putting unreviewed changes into the diff under review — the
tier agents cannot edit; on a harness without read-only types, state the constraint in each prompt.

## 1. Pin the fixed point

Whatever the user supplied — a SHA, branch, tag, merge-base. Under `/giljabi`, the slice branch's
start. If unspecified, ask.

```bash
git rev-parse <fixed-point>                 # must resolve
git diff <fixed-point>...HEAD               # three-dot: against the merge-base; must be non-empty
git log <fixed-point>..HEAD --oneline
```

Fail here on a bad ref or empty diff — not inside three parallel sub-agents.

## 2. Identify the sources

**Spec source**, in order: issue references in commit messages (fetch via
`docs/agents/issue-tracker.md`) → a path the user passed → a spec under `.scratch/` or `docs/`
matching the branch → ask. Under `/giljabi`, `spec.md` restricted to this slice's tickets. No spec
exists → the Spec axis reports "no spec available".

**Standards sources**: whatever the repo documents (`CONTRIBUTING.md`, coding-standards files, agent
docs). On top, the Standards axis always carries this **smell baseline** (Fowler, *Refactoring*
ch.3) — each a labelled judgement call, never a hard violation; a documented repo standard overrides
it; skip anything tooling enforces:

- **Mysterious Name** — a name that doesn't reveal what it does or holds → rename; if no honest name
  comes, the design's murky.
- **Duplicated Code** — the same logic shape in more than one hunk → extract, call from both.
- **Feature Envy** — a method reaching into another object's data more than its own → move it.
- **Data Clumps** — the same fields travelling together → bundle into one type.
- **Primitive Obsession** — a primitive standing in for a domain concept → give it a type.
- **Repeated Switches** — the same cascade on the same type recurring → polymorphism or one map.
- **Shotgun Surgery** — one logical change scattered across many files → gather into one module.
- **Divergent Change** — one module edited for unrelated reasons → split by reason.
- **Speculative Generality** — abstraction for needs the spec doesn't have → delete it.
- **Message Chains** — `a.b().c().d()` navigation → hide the walk behind one method.
- **Middle Man** — a thing that mostly delegates onward → cut it, call the target.
- **Refused Bequest** — an implementer ignoring most of what it inherits → composition.

**Knowledge sources**: the `docs/domain/` and `docs/platform/` pages whose entities the diff
touches — map pages to changed files by the entity each file serves, erring toward inclusion — plus
`/knowledge-tend`'s placement, index and relation checks (its checks 1–3) as pass/fail.

## 3. Spawn the three sub-agents in parallel

Each prompt carries the diff command and commit list. Anything an axis must **obey** goes in its
prompt in full — the smell baseline, the page contract; paths it merely needs to **read** pass as
paths. Each returns findings as `file:line` + claim + evidence, under 400 words.

- **Standards brief**: every place the diff violates a documented standard (cite file + rule), and
  every baseline smell (name it, quote the hunk). Distinguish hard violations from judgement calls.
- **Spec brief**: (a) requirements missing or partial; (b) behaviour nobody asked for; (c)
  requirements that look implemented but wrong. Quote the spec line for each.
- **Knowledge brief**: (a) claims on touched pages the diff has made false; (b) behaviour changes
  the diff makes that no page states and the anti-inference test says a page must (paste the test:
  *would a reader working from code alone arrive at the opposite?*); (c) `(intended)` markers whose
  code this diff built but whose marker survives; (d) dangling `relations:` ids; (e) a generated
  index that no longer matches its pages (`diff <(index.sh docs/domain) docs/domain/README.md`, same
  for platform), a new page with no `context:`, or a page or `CLAUDE.md` paragraph the layer table
  places elsewhere. This axis checks pages against **code**, including entities the spec never
  mentioned.

## 4. Aggregate, then dispose

Present the three reports under their own headings, verbatim or lightly cleaned — never merged or
reranked; the separation is the point, since a change can pass one axis and fail another. End with
one line per axis: finding count and the worst item.

Then route **every** finding through the disposition rule:

- **Evidence-backed** — it violates a documented standard, the spec, or a page invariant — dispose
  of it yourself: **fix now** when it belongs to this change, **ticket** when it doesn't (into the
  feature's slice plan if it blocks the feature, the backlog otherwise). List every call you made in
  the report.
- **Judgement call** — no documented rule decides it — goes to the user, all of them **batched into
  one prompt**, your recommendation first.
- **Accept is human-only.** You may fix and you may ticket; you may never decide something stays
  broken. Any would-be accept escalates.

A judgement call the user decides is a candidate rule for a knowledge page or standards doc — write
it down and it becomes evidence-backed forever after, which is how this review asks less over time.
