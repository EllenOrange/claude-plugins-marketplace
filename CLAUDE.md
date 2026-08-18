# claude-plugins-marketplace

Personal Claude Code plugin marketplace `ellenorange`. Plugins live
under `plugins/<name>/` with a `.claude-plugin/plugin.json` manifest
and skills under `skills/<name>/SKILL.md`.

## Releasing plugin changes

Bump the plugin's `version` in `.claude-plugin/plugin.json` in the
same PR as any change to the plugin's skills, rules, or scripts.
Installed plugins cache by version, under
`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`, so a
content change without a version bump can leave installed copies
serving the old cached files after the marketplace updates.

## Skill headings are quoted by sibling skills

A skill may cite another skill's section heading verbatim as a prose
pointer. `plan-converge` cites the write-plan heading "Sweep each
ruling at decision time" and the write-plan self-review bullet
"Restatements". Renaming a heading in one `SKILL.md` leaves a dangling
reference in another, and nothing catches it. Treat a heading rename
as an API change: grep `plugins/*/skills/*/SKILL.md` for the old text
and update every citation in the same commit.

## Markdown

Every Markdown file must pass `npx markdownlint-cli2 <file>` with zero
errors before commit.

## Prose in this repo

This repo's own Markdown follows the writing-style rule it ships at
`plugins/writing/rules/writing-style.md`. Read that file before
writing prose here. The rule that bites most often is the ban on
parentheticals. Do not set prose off with parentheses, paired
hyphens, or paired dashes. Write the content into the sentence, give
it a sentence of its own, or delete it. Parentheses that carry
technical meaning stay, such as function-call syntax or a unit.

This repo adds a convention of its own, on top of the shipped rule:
no count in front of a self-counting list. Write "The plan has these
sections:", not "The plan has five sections:".

Quoted material is exempt, including the user prompts in
`plugins/writing/EVAL.md`.
