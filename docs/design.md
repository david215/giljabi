# Design rationale

What the skills cannot say for themselves: why they are shaped this way and not the obvious other
way. Every entry defends a decision a competent reader might "fix".

## Why current-state pages, not a typed knowledge graph

The graph was designed and rejected. Its only load-bearing parts were the `intended | built`
lifecycle and referential integrity — both kept, as one frontmatter field and a 5-line grep. The
rest lost on all three axes that matter: node-per-fact makes N reads plus a join where one read
would do (models err at joins, not reads); every typed edge is stated twice and the checker
validates syntax, never truth; and a schema taxes every reader when only writers are governed.
Readers are many and ungoverned — that asymmetry decides where structure is allowed to cost.

## Why pages change in the same diff as the code

A deferred-documentation phase was tried (`/to-durable`) and became the place everything was
deferred to. No format survives write-timing failure: docs drift when updating them is a separate
chore, so the same-diff rule outranks every format choice, and the review's Knowledge axis exists
to enforce it at the only moment it is cheap.

## Why slices are always sequential

Independently *mergeable* is a weaker property than concurrently *editable*: two slices can share
no output edge and still edit the same bytes, and nothing computes byte-disjointness. Worktrees
were considered — they only convert silent clobbering into deferred merge conflicts, share all dev
state (one database, one port range), and the human whose decisions both slices need does not
parallelize.

## Why the plan is its own PR, merged first

Slices branch from the integration branch. If the `(intended)` pages rode the first slice, every
later slice would branch blind to the plan it implements. Merging the plan first also reviews the
design at design size instead of inside a 3,000-line diff.

## Why "accept" is human-only in review

Reviewers made good catches and then closed the judgment calls the human would have decided
differently — silently. The gate that fixes it is not severity (a low-severity judgment call is
exactly what the human wanted to see) but *whether a documented rule decides the finding*: rules
can be applied autonomously, judgment cannot. Each judgment call the human decides becomes a
documented rule, so the prompts shrink by construction.

## Why there is no test-report skill

It existed to work around a ts-jest memory constraint that forced judicious suite selection, and to
carry point-in-time results a description would let go stale. The constraint was fixed and CI owns
the evidence; `/pr` now claims only what CI or the user proves.

## Why skills never edit themselves

A self-modifying skill is a feedback loop with no test and no ground truth. Evolution is a friction
inbox plus a human-gated retro: regular, never automatic.

## Why STATE.md may point but never narrate

Its predecessor banned narration without giving overflow a destination, so multi-PR progress, ops
notes, and outcomes all flowed into the one file the next session was guaranteed to read — a
25-line log wearing a bookmark's name. The fix was homes (slices.md, findings.md, knowledge pages),
not a sterner ban.
