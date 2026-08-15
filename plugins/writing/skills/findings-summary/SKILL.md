---
name: findings-summary
description: Report findings as a prioritized numbered list with triage verdicts. Use whenever presenting the results of a code review, audit, investigation, or debugging session to the user.
---

# findings-summary

Emit the findings from the current review, audit, or investigation as
a prioritized list. Write all prose per
`~/.claude/rules/writing-style.md`.

## Before you write: push back

Drop any finding that a reasonable senior engineer could figure out
alone. This applies especially to omissions and wording ambiguities.
A finding earns its place only if the reader would act on it.

## Format

Order findings by priority, most important first. Emit each as:

```text
#N. Title
Problem: one sentence.
Triage: fix | respond | discuss
Proposed Solution: 1–3 sentences.
```

- **Title** — a specific, short name for the finding. Not a category.
- **Problem** — one sentence stating the defect and its consequence.
- **Triage** — pick one:
  - `fix` — the finding is correct and the change is mechanical;
    apply it.
  - `respond` — the finding rests on a wrong premise or a defensible
    choice; answer it, change nothing.
  - `discuss` — a legitimate design issue that needs discussion with
    the user before anyone acts.
- **Proposed Solution** — 1–3 sentences. For `respond`, the response
  itself. For `discuss`, the question to put to the user.

## After the list

Stop. Do not restate the findings in prose, and do not apply any
`fix` items unless the user asks.
