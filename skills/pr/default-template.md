# Default PR template

Used only when the repo ships no `pull_request_template.md`. A repo that adopts one takes over from
this file entirely — that is the point of Step 3.

Deliberately thin. A repo's real template encodes what its reviewers agreed to check; anything
invented here would be a guess at that, so this covers the minimum a reviewer needs and stops.

```markdown
## What changed

- **API changes**
  - `<METHOD /path>` (BREAKING|new|changed)
    - <what a caller must now do differently>
- **<label>**
  - <detail>
  - <detail>
- **<label>**
  - <detail>

## Expected effect

- <outcome supported by the diff>

## Tests

- <what CI or a user-reported run proves — cite the source, or leave unchecked>
```

## Notes

**`API changes` is a change-group label inside `What changed`, first position** — not a section of its
own, and never under `Expected effect`. See Step 4's *Which section it goes in*.

**Translate every label into the repo's prose language**, `API changes` included. The English here
names the concept; it is not a string to copy into a body written in another language.

**Omit `API changes` entirely** when no route has caller-visible change. An empty label reads as
"checked and clear" when it usually means "not checked".

**`Tests` states only what evidence proves** — see Step 4's *Test items are filled on evidence,
never on assumption*. With no CI run and no user-reported run, leave it honestly unchecked rather
than claiming one.

The label → detail shape, the change-group rule, and the `API changes` tags are specified in
`SKILL.md` and apply here unchanged.
