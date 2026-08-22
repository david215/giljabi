# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

**`.scratch/` is gitignored and ephemeral.** It carries thinking between context windows — the spec
answers "what are we building", the tickets answer "what do I build next", and both questions stop
being asked the moment the feature merges. Nothing durable may live only here. See *Lifecycle*.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` — never a single combined tickets file
- Triage state is recorded as a `Status:` line near the top of each issue file
- Comments and conversation history append to the bottom of the file under a `## Comments` heading
- The findings log is `.scratch/<feature-slug>/findings.md`, beside the spec
- The slice plan is `.scratch/<feature-slug>/slices.md`, beside the spec
- **Ticket bodies stay thin; acceptance criteria stay thick.** A few sentences of what-to-build, a detailed checklist, and a line naming the knowledge page to read first. Do not restate the spec's reasoning in the ticket — that copy is the one an implementing agent reads, and the one most likely to be stale.

## Lifecycle

Specs and tickets are extracted, then deleted. Nothing in `.scratch/` survives its feature.

**Durable value never waits here.** Knowledge pages change in the same diff as the code
(`/knowledge`); discoveries are routed to tickets or decisions as they surface (`/implement`).
Nothing in `.scratch/` is a holding pen for documentation.

**After the merge — delete.** The procedure lives in the `/giljabi` skill, not here. It is identical
on every tracker, because `.scratch/<feature-slug>/` exists on every tracker; what differs on this one
is only how much sits inside it — the spec and tickets as well as the working files.

**There is no recovery** — `.scratch/` is gitignored, so a deleted directory is not in a branch, a
stash, or the remote. The `/giljabi` procedure checks before it removes.

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

