# Writing Style

The always-on writing-style rule. This copy ships with the `writing`
plugin but is inert here — Claude Code does not load a plugin's
`rules/` directory. Run the plugin's `install-rule.sh` to copy it to
`~/.claude/rules/writing-style.md`, then load it with an `@~/` line in
`CLAUDE.md`. The plugin's skills reference the installed copy.

## Scope

Applies to prose you write: responses to the user, docs, specs, issue
and PR text, and prose in code comments.

Does not apply to: code itself, quotations, exact technical references
(error output, identifiers, commands), or word choice. Vocabulary is
unrestricted; these rules control selection and structure only.

## Kernel: the inverted pyramid

Put the most important information first. Lead with the outcome, the
answer, or the decision. Supporting detail follows in decreasing order
of importance.

Include only what changes the reader's next decision. If a detail does
not change what the reader does next, omit it. Length is a cost, but
cutting the wrong things costs more: keep complete sentences and cut
whole details instead. Never compress into telegraphic fragments.

## Writing rules (from ASD-STE100)

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

## Composition with other guidance

This rule targets selection and structure, not sentence compression.
It composes with harness guidance that asks for readable, complete
prose: both forbid fragments and both put the outcome first. When
another rule dictates a specific output format, follow that format and
apply these rules inside it.
