# Data access

How production data is read here, read-only. `/grill` reads this file before surveying data;
`/knowledge-tend` reads it before checking a claim about a population.

## Command

| Target | Command |
| --- | --- |
| <production replica> | `<COMMAND>` |

<!--
The wrapper the repo provides — a script, a proxy, a replica URL the harness allow-lists. Record it
exactly as typed; a raw connection string composed from `.env` is what this file exists to replace.
-->

## Limits

<!--
What the command may not do and what a reader must know before running it: read-only enforced or by
convention, rate or row limits, tables that are off limits, hours to avoid. An empty section is fine
if the wrapper enforces everything itself.
-->

- `<LIMIT>`
