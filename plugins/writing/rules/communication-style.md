# Communication Style

The always-on communication-style rule, shipped with the `writing` plugin.
Claude Code does not load a plugin's `rules/` directory, so the
plugin's `install-rule.sh` copies this file to
`~/.claude/rules/communication-style.md`, where an `@~/` line in `CLAUDE.md`
loads it always-on. The plugin's skills use the installed copy when it
exists and fall back to the bundled copy otherwise.

## Scope

Applies to prose you write: responses to the user, docs, specs, issue
and PR text, and prose in code comments.

Does not apply to: code itself, quotations, exact technical
references such as error output, identifiers and commands, or word
choice. Vocabulary is unrestricted; these rules control selection and
structure only.

## Kernel: the inverted pyramid

Put the most important information first. Lead with the outcome, the
answer, or the decision. Supporting detail follows in decreasing order
of importance.

Include only what changes the reader's next decision. If a detail does
not change what the reader does next, omit it. Length is a cost, but
cutting the wrong things costs more: keep complete sentences and cut
whole details instead. Never compress into telegraphic fragments.

## Writing rules from ASD-STE100

These are targets, not word-count ceilings to game. When a rule and
clarity conflict, clarity wins.

- Keep sentences short: about 20 words for instructions, about 25 for
  description.
- Give one instruction per sentence.
- Use the active voice in procedures and instructions.
- Use simple tenses: past, present, future. Avoid perfect and
  progressive constructions.
- Keep noun clusters to 3 words or fewer. Break longer clusters apart
  with prepositions.
- Use one term per concept. Do not vary terms for elegance; repeat
  the same word for the same thing.
- Keep one topic per paragraph, 6 sentences or fewer.
- Use a vertical list for a sequence of steps and for 3 or more
  parallel items.
- Write explicit subjects, verbs, and articles. Do not drop words to
  save space; no telegraphic fragments, no ellipsis-style terseness.

## No parentheticals

Do not set prose off from its sentence. A parenthetical is any span
held apart by paired punctuation: parentheses, paired hyphens, or
paired dashes of any width. Decide instead what the content is worth:

- The content matters. Write it into the sentence, or give it a
  sentence of its own.
- The content does not matter. Delete it.

Avoid the dash elsewhere too. A colon introduces, a comma separates,
and a period ends. One of those three replaces almost every dash.

This rule covers prose. Parentheses that carry technical meaning stay:
function-call syntax, a citation, a unit of measure, and an option
list inside a command.

## No derivable numbers

Do not state a count, total, or percentage the reader can compute
from what is already shown.

The failure is not the arithmetic. It is the second copy: the number
and the thing it counts drift apart the moment either is edited, and
the prose then asserts something false. Instances:

- A count in front of a list that enumerates its own members. Write
  "The forbidden forms are:", not "The three forbidden forms are:",
  and let the reader count.
- A total under a table whose rows the reader can add up.
- A percentage that restates a ratio already displayed.
- "I changed 7 files" above a diff or a file list.

A number that carries independent meaning is not derivable and is
fine: "retry up to 3 times", "exactly one parent per issue", "the
timeout is 30s". There the number is a constraint, not a tally of
something already in view.

## Audience calibration

The same rules apply everywhere. Only the balance moves.

In conversational replies, brevity wins. Say the thing and stop. Do
not restate what the reader just said, do not recap a change the
diff already shows, and do not append a summary to a short answer.

In written artifacts such as issue bodies, docs, PR bodies, and
commit messages, completeness wins, because the reader arrives
without the conversation that produced the document. An artifact may
legitimately be long. It may not be padded: the length must come
from content a future reader needs, not from restating what the
surrounding text already says.

## Composition with other guidance

This rule targets selection and structure, not sentence compression.
It composes with harness guidance that asks for readable, complete
prose: both forbid fragments and both put the outcome first. When
another rule dictates a specific output format, follow that format and
apply these rules inside it.
