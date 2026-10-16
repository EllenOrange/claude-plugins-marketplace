# Plan style

This file states the format, the length, and the style of a plan. A
plan is the spec for one issue. It carries the decisions that cross a
boundary and the outcomes the merged tree shows, and nothing else.

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

A plan omits `### Mechanical` when no criterion goes under it. It
omits no other section.

### Problem

Problem states what is wrong today, as the current behavior and what
it costs. Its last sentence states what the issue leaves alone.

### Design

Design is one short summary paragraph followed by a bullet list of
decisions and outcomes. Each bullet is one sentence where it can be. A
large plan may group the bullets under `###` subheadings.

Every Design sentence is a decision or an outcome, and is true of the
merged tree read without the diff:

- A **decision** settles something that crosses a boundary, which is
  anything a user, another component, another repo, or a reviewer
  depends on. Behavior users see, an interface other code calls, a
  data format, a name or a path another tool reads, and the fate of
  what the change subsumes are decisions.
- An **outcome** is a property the merged tree shows at such a
  boundary.

Whatever crosses no boundary is the implementer's, such as internal
names, helper functions, module layout, and call order. Design states
none of it. A sentence that names a step, such as an edit to make or a
command to run, or that compares the merged tree against today's code,
is an instruction however it is phrased. A plan does not carry it.

### Acceptance and Files affected

Both follow the issue-body grammar of the orchestration readiness bar,
with one criterion or one path per bullet:

- A criterion goes under `### Mechanical` only when a check key that
  grammar defines settles it. Its bullet opens with that key, followed
  by its arguments, and carries no command. A plan never coins a key,
  and never stretches a key past the claim the grammar gives it.
- `[no-match]` is the only key that matches a pattern against a file,
  and it asserts absence. A claim that content is present, added, or
  emitted therefore goes under `### Semantic`.
- Every other criterion goes under `### Semantic`. Its bullet is one
  claim about the delivered change that a reviewer can attempt to
  disprove against the diff. It names the artifact it is about, such
  as the file, the section, or the output that carries the content.
- Where the readiness bar is not installed, no key can be checked
  against its grammar, so every criterion goes under `### Semantic`.
- A Files affected bullet is one repo-relative path in backticks and
  one tag. The list is a floor: it names every path the plan knows the
  change touches.

## A plan is settled

A plan poses no question and leaves no decision implicit.

## Length

A plan runs about 525 words, and a plan over 800 words is too long.
Its Design runs about 200 words, and a Design over 300 words is too
long. Count words as `wc -w` counts them over the Markdown, the Files
affected list included. Cut a plan that is too long by whole details,
never by compressing its sentences.

## The style

These rules govern the plan's own prose. A path, an identifier, and a
command are exempt. A numeric limit is a target, and clarity wins when
a target and clarity conflict.

- **Most important first.** Each section, paragraph, and sentence
  leads with the decision, the outcome, or the fact it carries.
  Supporting detail follows in decreasing order of importance.
- **Only what the reader needs.** A detail that changes nothing the
  implementer or the reviewer does is cut. A plan argues for nothing:
  it gives no rationale, lists no rejected alternative, recounts no
  history of its own writing, and assesses no risk.
- **Full, short sentences.** Every sentence has an explicit subject,
  verb, and articles, and carries one idea. A sentence that sets a
  requirement, such as a decision or a criterion, runs about 20 words.
  A sentence that describes, such as a Problem sentence or an outcome,
  runs about 25.
- **Active voice and simple tenses.** Write in the active voice, in
  the past, present, or future tense, with no perfect or progressive
  construction.
- **Plain terms.** A noun cluster is 3 words or fewer, broken apart
  with prepositions when longer. The plan uses one term for each
  concept throughout, because a second term reads as a second thing.
- **Names in backticks, behavior in prose.** A plan names a path, a
  skill, or an identifier in backticks, and gives a path relative to
  the repo root. It states how existing code or text behaves in plain
  prose, rather than quoting it as evidence.
- **Short paragraphs and vertical lists.** A paragraph carries one
  topic in 6 sentences or fewer, each following from the one before.
  Put 3 or more parallel items in a vertical list.
- **No parenthetical.** A plan sets no content off in parentheses,
  between paired hyphens, or between paired dashes. Write it into the
  sentence, give it a sentence of its own, or delete it. Parentheses
  that carry technical meaning stay, such as function-call syntax, a
  unit, or the tag of a Files affected bullet. Elsewhere, a colon
  introduces, a comma separates, and a period ends, in place of a dash.
- **No derivable count.** A plan states no count the reader can derive
  from what it already shows, such as "five sections:" in front of a
  list. A number that carries its own meaning, such as a limit or a
  timeout, is not derivable.
