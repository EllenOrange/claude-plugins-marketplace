---
name: findings-summary
description: Report findings as a prioritized numbered list with triage verdicts. Use whenever presenting the results of a code review, audit, investigation, or debugging session to the user, including when they only ask "what's wrong", "what did you find", or "any issues?" without naming a review.
---

# findings-summary

Emit the findings from the current review, audit, or investigation as
a prioritized list. Write all prose per the writing-style rule: the
installed copy at `~/.claude/rules/writing-style.md` if present, else
the plugin's bundled copy at
`${CLAUDE_PLUGIN_ROOT}/rules/writing-style.md`.

## Before you write: push back

Drop any finding the reader would dismiss on sight. A cheap-to-state
fact the reader likely has not noticed still earns a line. When the
findings review an implementation plan or spec, prune harder: drop
anything a reasonable senior engineer could figure out alone,
especially omissions and wording ambiguities. A finding earns its
place only if the reader would act on it.

Skip this step entirely when the caller states that the report feeds
an automated verification loop rather than a human. Emit every
finding in that mode. The loop verifies each finding itself and keys
its own stopping rule on the full set, so a pruned finding costs it a
signal rather than a reader's attention.

## While you write

The list is the emission, so there is no draft to revise. Apply the
writing-style rule as you write each line, not after:

- One sentence for Problem. Keep it to about 20 words.
- One term per concept across the whole list. Use the words the
  reviewed work uses.
- Name the defect, not its category. "The count says four and the
  list has five" beats "a consistency issue".

## Format

Order findings by priority, most important first. Emit each as:

```text
#N. Title
Problem: one sentence.
Triage: fix | refute | discuss
Proposed Solution: 1 to 3 sentences.
```

- **Title**: a specific, short name for the finding. Not a category.
- **Problem**: one sentence stating the defect and its consequence.
- **Triage**: pick one.
  - `fix`: the finding is correct and the change is mechanical;
    apply it.
  - `refute`: the finding rests on a wrong premise or a defensible
    choice; answer it, change nothing.
  - `discuss`: a legitimate design issue that needs discussion with
    the user before anyone acts.
- **Proposed Solution**: 1 to 3 sentences. For `refute`, give the
  refutation itself. For `discuss`, give the question to put to the
  user.

## After the list

Stop. Do not restate the findings in prose, and do not apply any
`fix` items unless the user asks.
