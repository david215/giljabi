---
name: knowledge
description: Maintain the repo's knowledge layer — one current-state page per domain entity, rewritten in place, git as the ledger. Use when recording a design decision, defining or sharpening domain terminology, updating docs after a code change, or when another skill needs the page contract.
---

# Knowledge

The knowledge layer is `docs/domain/`: **one page per domain entity, stating how the repo is now.**
No ADRs, no known-issues ledger, no append-only anything. When a fact changes, the page is rewritten
in place; git history is the only record of what it used to say. A page asserts present tense, which
makes it falsifiable — a wrong page is a bug you can find by reading the code, not an old memo with
an excuse.

## Layout

```
docs/domain/
├── README.md            ← index: one line per entity — the only file a reader must find unaided
├── subscription.md
├── invitation.md
└── …
```

Create pages lazily — an entity earns a page when the first fact about it needs a home. The index
gains a line in the same edit.

## Page format

```markdown
---
id: subscription
status: built                # intended | built — page-level; a wholly-new entity starts intended
relations:
  - {rel: classified-by, to: subscription-type}
  - {rel: reduced-by, to: scheduled-seat-reduction}
---
# Subscription

One or two sentences: what this entity IS. This opening is the term's definition — the glossary
and the page are the same document.
_Avoid_: plan, contract    ← synonyms this repo deliberately does not use

## Lifecycle
States and transitions, as prose or a short list.

## Invariants
The rules that must hold, each with the line that defends it when a reader would break it.

## Hazards
Known defects and traps in this entity's territory — current, open, and stated plainly.
```

Sections beyond the opening definition appear only when there is content for them; an entity with no
hazards has no Hazards section. Use `Lifecycle`, `Invariants`, `Hazards` as the section names when
they apply — a fixed vocabulary is what lets an update land in the right place instead of appending
at the bottom.

**Frontmatter is an index, never a summary.** It holds only what the prose does not state — the id,
the lifecycle status, machine-greppable relations. Never restate a prose claim in frontmatter: what
is stated once cannot disagree with itself.

## The four rules

1. **Current state only.** The page says what is true now. How it got that way, what it replaced,
   who decided — `git log` on the page answers all of it. When a decision changes, overwrite and
   delete the reference to what was there before.
2. **One home per fact.** Every fact lives on exactly one page; other pages that need it carry a
   pointer (`see subscription.md`), never a copy. When a fact could live on two pages, it lives on
   the entity whose code defends it.
3. **Same diff as the code.** A change that alters an entity's behaviour updates that entity's page
   in the same commit. A doc update deferred to later is a doc update that does not happen — this
   rule exists because a deferral pile was tried and became a graveyard.
4. **`(intended)` marks the unbuilt.** Planning commits claims about code that does not exist yet.
   Tag each such claim inline with `(intended)`; a wholly-new entity takes `status: intended`
   page-level instead. `grep -rn '(intended)' docs/domain/` is the list of promised-but-unbuilt
   work. Implementation removes each marker in the diff that makes the claim true.

## What a page keeps — the anti-inference test

Every line must pass:

> **Would a competent reader, working from the code alone, arrive at the opposite?**

If no, cut it. A name, a type, or a test already carries most facts; the page earns its length only
with what code cannot show. The highest-value line is a decision the obvious reading actively
fights — where the textbook answer is the wrong one here. Spend words there and nowhere else.

**Keep:** invariants a reader would "fix" into bugs; constraints invisible in code (a client keying
on a status code, a measured population, a partner's rate limit); deliberate omissions; a rejected
alternative *only while a reader starting from the current code could still choose it* — once the
code forecloses it, it is history, and history goes.

**Cut:** motivation, narrative, how a fact was learned (minimal provenance: keep the failure mode,
cut the story); anything restating the code; references to anything ephemeral — tickets, specs,
`.scratch/` paths, feature slugs. State the fact, not where it was decided: *no ticket asked for
it* → *nobody asked for it*.

Point at a page from code in **one line**; never restate its argument at the call site — two copies
drift, and the code copy is the one nobody updates.

## Sharpening, while designing

When maintaining the model live (a grill session, a design discussion):

- **Challenge terms against the pages.** A term used contrary to its page's definition gets called
  out immediately: "subscription.md defines X — you seem to mean Y. Which is it?"
- **Sharpen fuzzy language.** Propose one canonical term; record the losers under `_Avoid_`.
- **Cross-reference the code.** When the user states how something works, check whether the code
  agrees, and surface contradictions rather than recording the claim.
- **Write inline, the moment a term or decision crystallises.** Batching is how it gets lost.

## Integrity check

```bash
grep -rho 'to: [a-z0-9-]*' docs/domain/ | sed 's/to: //' | sort -u | while read id; do
  grep -qrl "^id: $id$" docs/domain/ || echo "dangling relation: $id"
done
```

Dangling relations fail the review's Knowledge axis. The check validates references, not truth —
truth is checked by reading, which is why pages stay short enough to read.
