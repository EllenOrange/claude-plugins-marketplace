---
name: summarize-findings
description: Report findings as a prioritized numbered list with triage verdicts. Use whenever presenting the results of a code review, audit, investigation, or debugging session to the user, including when they only ask "what's wrong", "what did you find", or "any issues?" without naming a review.
---

# summarize-findings

Emit the findings from the current review, audit, or investigation as
a prioritized list.

## Before you write: push back

Drop any finding the reader would dismiss on sight. A cheap-to-state
fact the reader likely has not noticed still earns a line. When the
findings review an implementation plan or spec, prune harder. Drop
anything a reasonable senior engineer could figure out alone,
especially omissions and wording ambiguities. A finding earns its
place only if the reader would act on it.

Skip this step entirely when the caller states that the report feeds
an automated verification loop rather than a human. Emit every
finding in that mode. The loop verifies each finding itself and keys
its own stopping rule on the full set. A pruned finding therefore
costs the loop a signal rather than a reader's attention.

Skip it too when the caller states that every finding is already
verified. Each one then holds, so a pruned finding hides a real defect
from the reader.

## While you write

The list is the emission, so there is no draft to revise. Apply these
rules as you write each line, not after:

- One sentence for Problem, stating the defect alone. Keep it to about
  20 words. A finding's consequence class, its evidence, and the
  other members of its class never go in it.
- One term per concept across the whole list. Use the words the
  reviewed work uses.
- Name the defect, not its category. "The count says four and the
  list has five" beats "a consistency issue".
- Name only the identifiers the reader needs to find the defect or
  act on it, and say the rest in plain words. A sentence that reads
  as a run of identifiers is rewritten.

## Format

Group the findings by triage verdict. The `fix` items come first, as
one batch the reader can veto item by item. The `discuss` items come
next, then the `refute` items. Within each group, order by priority,
most important first. Number the findings straight through the whole
list. Emit each as:

```text
#N. Title
Problem: one sentence.
Evidence: one short line.
Why it matters: one sentence.
Triage: fix | refute | discuss
Proposed Solution: 1 to 3 sentences.
```

- **Title**: a specific, short name for the finding. Not a category.
- **Problem**: one sentence stating the defect.
- **Evidence**: the finding's consequence class, its evidence, and the
  other members of its class, in one short line. A human reader gets
  no Evidence line, so emit it only when the caller states that the
  report feeds an automated verification loop.
- **Why it matters**: one plain sentence stating what the defect costs
  the reader or the work if it stays.
- **Triage**: pick one.
  - `fix`: the finding is correct, and the overall shape of the repo
    or the decisions the reviewed work already makes settle which of
    the available fixes is right; apply it.
  - `refute`: the finding rests on a wrong premise or a defensible
    choice; answer it, change nothing.
  - `discuss`: the finding is correct, and neither the shape of the
    repo nor the work's own decisions settle which fix is right; put
    it to the user before anyone acts.
- **Proposed Solution**: 1 to 3 sentences. For `refute`, give the
  refutation itself. For `discuss`, give two to four options and a
  recommendation, never a question.

When the caller states that the reviewed work is a plan, every fix a
`fix` or `discuss` item proposes meets
`${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md`. Recast a proposed fix that
does not before you emit it.

## After the list

Stop. Do not restate the findings in prose. Do not apply any `fix`
items unless the user asks.
