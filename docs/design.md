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

## Why the plan is the first commit on one feature branch, not its own PR

The plan once merged as its own PR before any code, because slices branched from the integration
branch and a later slice would otherwise branch blind to the plan it implements. A feature now runs
on one branch — slices are stacked commits on `feat/<slug>`, each PR opened from it at a slice
boundary — so every slice already sits on the plan and that reason is gone. What the separate PR
still bought, design-size review, came at the price of `(intended)` pages reviewed apart from the
code that proves them and a serial merge before slice 1; the default is now the cheaper shape, with
the plan PR available on request.

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

## Why migration is its own skill, scoped by entity cluster

`/knowledge` is loaded by every phase that touches a page; migration runs once per repo. Carrying
the procedure in `/knowledge` taxed every reader for a writer-only concern, so it moves to
`/migrate-docs`. A run converts one entity cluster from a checkpointed inventory, ordered by
proximity to planned work, until the inventory is empty — bounded, so the two-system period has an
end date. Migration converts *existing* docs only; undocumented entities take the layer's normal
lazy path, which is why "the whole codebase" is never the scope.

## Why knowledge splits into domain and platform

The first layer had one directory, and pages about Postgres collation and Prisma retry semantics sat
beside `subscription.md`. They passed the anti-inference test — the content was right — but the
falsifier was wrong: a business change cannot make a collation page false and a Prisma upgrade cannot
make a subscription page false. Placement by falsifier gives a reader one question per layer and a
reviewer one test for "is this in the right place". The entry point (`CLAUDE.md`) is the residue: a
rule living there has no falsifier but drift, which is why it may hold pointers only.

## Why the index is generated

A hand-kept index is a second home for every definition, and grouping is the one drift nothing else
detects — a page moves context and the README keeps the old group until somebody notices. Generating
from `context:` and the page's first sentence makes the definition the index line, so a bad index
line is a bad definition and the fix lands on the page. `docs/conventions/README.md` is the exception
because it indexes files it does not own.

## Why a relation is declared once and the neighbourhood is derived

Reciprocal edges look like completeness and are the graph's "stated twice" defect in miniature: two
homes for one fact, and the pair drifts the moment one side is edited. Yet an edge in only one
direction is useless to the page it points at — the page that most needs to know it is being
asserted about. The resolution is to pick the home by the same rule as any fact (the page whose code
enforces the edge declares it) and to make the reverse a lookup, not a line: `grep "to: <id>}"`.
The index renders the union on every line so a reader who never learns the rule still sees the
**neighbourhood**, and the skills that touch code — implement, review, grill, tend — read one hop
out along it, because a change to an entity's code goes stale first on the pages *about* it, not on
its own. Relations earned their place only when something traversed them; before that they were
metadata the dangling check validated and nobody read.

## Why tending is its own skill

`/knowledge` is loaded on every page edit and must stay the contract alone. The questions no page
edit asks — is this page in the right layer, is the index stale, has this page outgrown one entity,
does the code still agree — need a caller-scoped procedure, and three skills call it at different
scopes (`/grill` before it trusts a page, `/review` as pass/fail, `/migrate-docs` as its verify step).
One skill with a scope argument beats three restatements. It proposes and never applies unsupervised
for the same reason skills never edit themselves.

## Why harness-specific tokens are capabilities with a map

`/clear`, `AskUserQuestion`, `/handoff` and two others are Claude Code spellings of
capabilities every harness has under another name. Skills name the capability; one table in
`giljabi/SKILL.md` maps it per harness (Claude Code, Codex verified; others translate). The map is
not a `docs/agents/` file because the harness is a property of the session, not the repo. A sixth row
mapped read-only search to Claude Code's built-in `Explore` type and was deleted: `Explore` pins no
model, so a sweep ran at whatever the session was set to — the leak the tiers exist to close — and it
carries Bash like everything else, so it was never the read-only guarantee the row implied. A sweep
is now a `standard` agent with a pointers-only contract, and the capability is the tier.

## Why tiers apply only to delegated work

A skill running inline runs on the session model; nothing a skill says can change that, and
switching `/model` for a thirty-second `/commit` costs more than it saves. The exception proves the
rule: `/implement` is inline and is not thirty seconds, so `giljabi` phase 5 does ask for the switch
— off the ticket's `Weight:` line, not off a fresh judgment. So the tier vocabulary
(`deep | standard | fast`) attaches to subagents — each tier fixing model *and* reasoning effort
together, because both answer one question and two knobs is a choice with no rule — and the set of delegated skills widened to make
tiers worth having: `to-spec` and `to-tickets` draft as `deep` subagents from artifacts (reviewed
and edited inline, published after approval), all three `review` axes run `deep`, `pr` and `commit`
run `standard` — prose humans read, synthesized from several artifacts — and so does every search
sweep, leaving `fast` the suites. On Claude Code a tier is an agent definition the plugin ships, so a skill spawns by type name and
model and effort travel together; on Codex it is the `model` and `reasoning_effort` pair on
`spawn_agent`. A tier is never verified by
asking the model its name — self-report is wrong on both harnesses; session logs are the evidence. `grill`, `setup`, `implement` stay inline — their primary source
is the user.

The tiers name job weight, so the models under them can move without a skill changing. They sit at
Opus/high, Sonnet/medium and Haiku/low: the strongest model is not a tier at all but an escalation
the user asks for — `deep` spawned with a per-call `model: fable` override, recorded in
`directives.md` so it survives the context reset phase 5 performs between tickets. Escalation is the
user's because a tier exists to remove the model choice from spawn time, and a model judging whether
a task is hard enough to deserve more of itself is the one judge with an interest in the answer. The
same reasoning bans effort that floats with perceived complexity: variance is fine when it keys off
something written down, which is why the only complexity-driven choice in the workflow reads a
`Weight:` line `to-tickets` stamped with the whole breakdown in view. `fast`'s floor moved for the
opposite reason — Haiku at low effort is right for running a command and pasting the failures, and
wrong for anything that words or decides, so `commit` (whose message lands in `git log` forever) and
the sweeps (whose misses poison a design map) left it.

## Why there is a standalone path

An earlier version ran every phase on every change, arguing the phases self-limit and so no size
judgment was needed. But `/implement` already claimed to run standalone, so the exemption existed and
`giljabi` merely denied it — every user drew the line privately, which is the worst kind of
judgment call. The test that replaced it is checkable: would resuming need `STATE.md`? The six
phases exist to survive context resets; a change that fits one window has nothing for them to save.
What is never exempted is the knowledge discipline, and that lives in `/implement` and `/review`, not
in the phases — so the standalone path loses no page and no check, only bookkeeping.

## Why the tier agents are non-editing by instruction, not by tool set

Every tier carries Bash: `review`'s Knowledge axis runs `git diff` and `diff <(index.sh …)`, `fast`
runs suites, `standard` runs `/commit`. Bash can also `sed -i` and `git commit`, so no `tools:` list makes an
agent read-only, and an earlier version claiming "read-only by tool set" was asserting a guarantee
nothing provided. The honest shape is the one Codex already had: the constraint is stated in the
agent definition and repeated in every prompt, and the caller checks `git status` afterwards. A
guarantee that is really a convention is safer named as a convention.

## Why directives have their own file

A user instruction that is neither spec, repo fact, nor hazard — "skip e2e this week" — had no
home, so it flowed into STATE.md, which is what the pointer-only cap exists to stop.
`.scratch/<slug>/directives.md` holds them: one line each, rewritten in place, deleted when lapsed,
read at every session start after STATE.md. Not `findings.md` — that file grows and its register is
unjudged discovery; a directive on line 40 is a directive missed.

## Why a code comment may say more than "see the page"

The page owns the domain invariant; the code site may own the *local* why — why this ordering,
what breaks if a reader "fixes" this line — because that fact has no locatable home on a page.
Restating the page's argument at the call site stays banned: two homes, and the code copy drifts.

## Why the setup gate sits at phase 4

`docs/agents/` protects branching and commit conventions, which nothing before phase 4 uses. An
ideation-only run through phases 1–3 was blocked by a gate guarding a step it never reached.
