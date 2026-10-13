# Plan style

This file states the format and the style of a plan. A plan is the
spec for one issue. It carries the decisions the implementer cannot
make alone and the outcomes the merged tree shows, and nothing else.

## The sections

A plan carries these sections, in this order, and no other:

```markdown
## Problem

## Design

## Acceptance

### Mechanical

### Semantic

## Files affected (floor)
```

### Problem

Problem states what is wrong today, as the current behavior and what
it costs. It quotes the text that shows the defect, under the quote
rule below. Its last sentence states what the issue leaves alone.

### Design

Design is prose paragraphs, with no list and no subheading. Each
paragraph opens with a bold phrase that names the decision the
paragraph carries.

Every Design sentence is a decision or an outcome:

- A **decision** is one the implementer cannot make alone, such as a
  name, a placement, a contract, or the fate of what the change
  subsumes.
- An **outcome** is a property the merged tree shows.

A sentence that tells the implementer which section to edit, which
line to add, or which command to run is neither, and a plan does not
carry it.

### Acceptance

Acceptance follows the issue-body grammar of the orchestration
readiness bar. Each bullet is one criterion:

- A `### Mechanical` bullet opens with one of that grammar's check
  keys, followed by its arguments, and carries no command.
- A `### Semantic` bullet is one claim about the delivered change that
  a reviewer can attempt to disprove against the diff.

### Files affected

Files affected follows the same grammar. Each bullet is one
repo-relative path in backticks and one tag. The list is a floor: it
names every path the plan knows the change touches.

## A plan is settled

A plan poses no question and leaves no decision implicit.

## The quote rule

A claim about how existing code or text behaves is a verbatim quote
with its repo-relative path, or the plan does not make it. The quote
is the evidence. It matches the tree, character for character, at the
ref the plan builds on. A paraphrase of existing code or text is a
claim with no evidence.

Give the path in backticks, then the quote. Put a short quote in
double quotation marks inside the sentence, and a quote of more than
one line in a fenced block.

## The style

- **Full sentences.** Every sentence in a plan has a verb, and leads
  with the decision or the fact it carries.
- **Short and active.** A sentence is short and in the active voice.
- **One term per concept.** The plan uses one term for each concept,
  throughout. A second term for the same thing reads as a second
  thing.
- **No parenthetical.** A plan sets no content off in parentheses,
  between paired hyphens, or between paired dashes. Write the content
  into the sentence, give it a sentence of its own, or delete it.
  Parentheses that carry technical meaning stay, such as function-call
  syntax, a unit, or the tag of a Files affected bullet.
- **No derivable count.** A plan states no count the reader can derive
  from what the plan already shows. Write "these sections:", never
  "five sections:", in front of a list.
- **No argument.** A plan argues for nothing. It gives no rationale,
  lists no rejected alternative, recounts no history of its own
  writing, and assesses no risk.

## Citations

- **A skill section** is cited as the skill name in backticks,
  followed by an arrow and the heading in double quotation marks:
  `` `<plugin>:<skill>` → "<heading>" ``.
- **A path** is cited as a repo-relative path in backticks.
