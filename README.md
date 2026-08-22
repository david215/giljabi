# giljabi (길잡이)

Ten agent skills that run a feature from an idea to merged PRs, and leave the repo in a state any
agent — or any person — can work from. *Giljabi* is Korean for "guide": the one who leaves the
markers so the next traveler crosses the terrain alone.

## The shape of the system

**A feature does not fit in one context window.** Every phase therefore leaves an artifact, and the
next phase reads a file instead of remembering a conversation:

```
/grill  →  /to-spec  →  /to-tickets  →  plan PR  →  /implement × N  →  /review  →  /pr
                                                    └──────── per slice, sequential ───────┘
```

**Documentation is a knowledge layer, not a ledger.** One current-state page per domain entity in
`docs/domain/`, rewritten in place, git as the only history. No ADRs, no known-issues file, no
append-only anything: a page asserts present tense, which makes a wrong page a findable bug instead
of an old memo with an excuse. Pages change in the same diff as the code, and the review's Knowledge
axis fails the change when they don't. `/knowledge` carries the contract.

**Three layers, three placement tests.** A line lives in a skill if it would be identical in every
repo (method); in `docs/agents/` or `docs/domain/` if it could differ per repo (fact); in the
always-on rules file if it should govern a session that never invokes a skill (disposition). A line
passing no test is deleted, not homed.

## The skills

| Skill | Does |
| --- | --- |
| `giljabi` | The orchestrator — phase order, slices, context resets, STATE.md |
| `grill` | Relentless design interview; maps code and data first, asks in rounds |
| `to-spec` | Synthesizes the conversation into a spec |
| `to-tickets` | Tracer-bullet tickets with blocking edges, grouped into mergeable slices |
| `implement` | One ticket, test-first; docs in the same diff; discoveries routed, never deferred |
| `review` | Three axes — Standards, Spec, Knowledge — in parallel read-only sub-agents |
| `commit` | Secret-screened Conventional Commits in the repo's own conventions |
| `pr` | Real PRs from the merge base, template-faithful, on GitHub or Azure DevOps |
| `knowledge` | The knowledge-layer contract: page format, writing tests, integrity check |
| `setup` | One run configures a repo: tracker, VCS, testing, `.scratch/`, `docs/domain/` |

## Install

```
npx skills add david215/giljabi -g -s '*' -y -a claude-code codex cursor gemini-cli
```

Edit here, push, reinstall — never `cp` into an install directory: a copy has no lock entry, so
`skills update` skips it forever while it looks fine on disk. Run `./check.sh` before committing.

## Evolution

Skills evolve through a friction loop, never by editing themselves: workflow runs capture
`[friction]` moments, `/giljabi`'s close phase routes them to `retro/inbox.md` here, and a retro run
in this repo turns each into a proposed diff applied only on human approval.

## Lineage

The grill → spec → tickets → implement core descends from
[Matt Pocock's skills](https://github.com/mattpocock/skills) (MIT — see
[`LICENSE-mattpocock`](./LICENSE-mattpocock)), several generations of rewrite later. The knowledge
layer, slices, and the review's disposition rule are original to this repo.
