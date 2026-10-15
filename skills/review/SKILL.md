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

The axes run as **parallel non-editing sub-agents at the `deep` tier** (`/giljabi` maps the type per
harness) so they don't pollute each other's context. That is a **precondition, not an implementation
detail**: if this session cannot spawn sub-agents, stop and say so before any setup — do not quietly
run the axes in one context, where the report looks the same and is weaker. A reviewer that edits
will occasionally fix what it found, putting unreviewed changes into the diff under review. No tool
set prevents that — the `deep` agent has Bash because `git diff` and the index check need it — so the
constraint is instruction, and it goes in **every** axis prompt on every harness: *report only; edit
nothing; run no command that changes the working tree or git state.* After the axes return,
`git status --porcelain` against the pre-review state is the check that they obeyed.

## 1. Pin the fixed point

Whatever the user supplied — a SHA, branch, tag, merge-base. Under `/giljabi`, the previous slice's
merged tip — the feature branch's start for slice 1. If unspecified, ask.

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
touches — map pages to changed files by the entity each file serves, erring toward inclusion —
**and each touched page's neighbourhood** (`/knowledge`'s lookup: the pages declaring an edge at it),
read for the claims they make about the touched entity; plus `/knowledge-tend` at that scope —
placement and index (checks 1–2) and drift on every claim of every touched page (check 4) as
pass/fail, shape (check 3) as proposals. This is the layer's primary tend, run before the PR that
changes it.

## 3. Spawn the gates and the three sub-agents in one turn

The **gates** and the axes start together: a `fast` agent runs the typecheck and the slice's suites
from `docs/agents/testing.md` — the brief names the page each command is copied from (a migration
proof from the migrations platform page) and composes none, and states the condition to **run** in
the positive (*run the suite when step 1 printed nothing*), since a skip condition inverts in a
low-effort reader — and returns failures verbatim, while you run the index diff and the
dangling-relation check (`/knowledge-tend` check 2) here. Neither waits on the other — an axis
spends its run on judgment and the gates on execution — so each axis prompt says the gates are
running beside it and it runs none of them. Gate output is evidence: a red typecheck, a failing
suite or a stale index enters step 4 as an evidence-backed finding you own. A claim about a
population goes to the query command `docs/agents/data.md` names, run by **you** when an axis
returns the claim marked unchecked with the query it needs — no gate can pre-run it and no axis
holds the command. Each prompt carries the diff command, the commit list, the spec source's path,
the integration branch's name, and `directives.md`'s path when a feature is in flight — every path
and every premise in it read at its source this session (`ls` the path; open the spec file behind a
`STATE.md` summary), since a wrong premise in a brief is reproduced by three axes at once. Anything
an axis must **obey** goes in its prompt in full — the smell baseline, the page contract; paths it
merely needs to **read** pass as paths. Each returns findings as `file:line` with the line quoted
beside it + claim + evidence, under 400 words, and every `file:line` it writes — the anchor and each
supporting citation alike — was read back with `sed -n` before it was written. A finding whose
quote is not at that line is unverified: it goes back to its axis for the pointer before it is
disposed — a rule can be real while its pointer is invented. A claim that a line is pre-existing or
new is made from `git log -L` or the range diff, with the command beside it.

A finding that contradicts a decision the spec source records — a runbook choice, a default the
user settled — is a **conflict**, not a failure: the axis quotes both lines, and it lands in step
4's judgement-call batch for the user to close once.

- **Standards brief**: every place the diff violates a documented standard (cite file + rule), and
  every baseline smell (name it, quote the hunk). The tier is decided by what you can quote: a
  documented rule quoted at `file:line` → **hard**; a baseline smell or a taste → **judgement**. A
  rule whose page states an exception is quoted with the exception beside it, and the finding says
  why the hunk is not the exception — one bullet read without its neighbour is half a rule. A
  zero-callers or dead-code claim is verified against the integration branch (`git grep <symbol>
  origin/<integration-branch>`), never the checkout alone: a branch behind it sees callers that are
  not there.
- **Spec brief**: (a) requirements missing or partial; (b) behaviour nobody asked for — the plan
  commit's pages excluded: phase 1's tend ships in slice 1's PR by design (`/giljabi` phase 4), and
  the brief names that commit; (c) requirements that look implemented but wrong — every optional
  input the spec names traced absent, present **and `null`**, the value a transport allows that a
  present/omitted table never sends. Quote the spec line for each.
- **Knowledge brief**: (a) every claim on every touched page, re-verified against code — a claim the
  diff made false and one already stale surface alike, since a page rewritten in this PR is signed
  off whole; a number on a page is repaired with its enumeration pasted (the listing, never the old
  number plus one); a sentence asserting intent or a decision (*this is deliberate*, *not a
  capability anyone decided to offer*) cites where it was decided — `spec.md`, a `findings.md`
  decision line — or is reported as unsourced; (b) behaviour changes
  the diff makes that no page states and the anti-inference test says a page must (paste the test:
  *would a reader working from code alone arrive at the opposite?*); (c) `(intended)` markers whose
  code this diff built but whose marker survives; (d) a new page with no `context:`, or a page or
  `CLAUDE.md` paragraph the layer table places elsewhere — the index diff and the relation checks
  are gates the caller runs; (e) a page this diff grew that now passes the noun-section test
  (`/knowledge-tend` check 3) — proposed as a split, so the shape fix rides the slice that caused it
  rather than a later docs PR. When later slices will rewrite the same sections, the proposal is
  written into `slices.md` against the **last slice**, whose review runs check 3 over the series
  whole; `/giljabi`'s close runs no shape check, so a deferral pointed there is a deferral lost.
  This axis checks pages against **code**, including entities the spec never mentioned.

## 4. Aggregate, then dispose

Present the three reports under their own headings, verbatim or lightly cleaned — never merged or
reranked; the separation is the point, since a change can pass one axis and fail another. End with
one line per axis: finding count and the worst item.

Then route **every** finding through the disposition rule — the gates' failures included:

- **Evidence-backed** — it violates a documented standard, the spec, or a page invariant — dispose
  of it yourself: **fix now** when it belongs to this change, **ticket** when it doesn't (into the
  feature's slice plan if it blocks the feature, the backlog otherwise). A ticket is code work
  someone will schedule; a wrong page claim is never one — rewrite it now, or tag it
  `(unverified)`. A repo whose tracker is `.scratch/` has no backlog, since phase 6 archives the
  feature directory and nothing reads the archive:
  what fits no slice is fixed now, lands on the page's `## Hazards`, or goes to the user. List
  every call you made in the report.
- **Judgement call** — no documented rule decides it — goes to the user, all of them **batched into
  one prompt**, your recommendation first. The prompt is sent once, after every finding of every
  axis has a class; a second round means the first went out early.
- **Accept is human-only.** You may fix and you may ticket; you may never decide something stays
  broken. Any would-be accept escalates.

A fix that renames, moves or deletes a page section sweeps `.scratch/<feature-slug>/` for the old
heading and every quote of it — open tickets anchor on page text — and repoints each hit in the
same commit; the sweep is done when the grep returns nothing.

**Fix under the page contract, where the code lives.** A fix-now edit is written as `/implement`
writes: the convention and platform pages for the file it touches are read first (an edit under
`migrations/` reads the migrations page's freeze rule before the first byte); a number it writes
into a page carries the enumeration behind it — the `ls` or grep output, pasted — since a count is
incremented only by someone who did not enumerate; a claim it rewrites was read at the code it
describes in this session. A hazard goes on the page whose code holds it — a testing mechanic on
`testing.md`, not the domain page — written once, where the re-check will find it. Prose written
mid-review is the least-reviewed prose in the PR, and every re-check round after the first exists
because of it.

**Re-check the fixes, not the slice — and loop until clean.** After the fix-now dispositions land,
re-run only the axes whose findings you fixed, each over the fix commits alone
(`git diff <pre-fix HEAD>...HEAD`) with its findings pasted, returning each as closed or open. A fix
commit that touches a page or a comment also gets the Knowledge axis's full brief over that commit,
whichever axis raised the finding. The gates run once more, here. A new finding re-enters the
disposition rule and its fix is re-checked in turn: the loop runs until a round returns every
finding closed and nothing new — a second round is the expected case. What a round re-checks
shrinks as it goes: a finding whose fix only **deletes or repoints** — a claim cut, a pointer
corrected, a quote re-anchored — closes by reading the line back (`sed -n`) plus the gates, since a
deletion adds no claim for an axis to test; a fix that **asserts** anything new gets its axis. A fix
confined to what a gate proves — a typecheck error, a stale index — needs the gate, not an axis.
Green is every axis's findings closed, nothing new, and the gates clean.

A judgement call the user decides is a candidate rule for a knowledge page or standards doc — write
it down and it becomes evidence-backed forever after, which is how this review asks less over time.
