# claude-plugins-marketplace

Personal Claude Code plugin marketplace `ellenorange`. Plugins live
under `plugins/<name>/` with a `.claude-plugin/plugin.json` manifest
and skills under `skills/<name>/SKILL.md`.

## Releasing plugin changes

Bump the plugin's `version` in `.claude-plugin/plugin.json` in the
same PR as any change to the plugin's skills, rules, or scripts.
Installed plugins cache by version, under
`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`. A
content change without a version bump can therefore leave installed
copies serving the old cached files after the marketplace updates.

## A plugin's `docs/` file a skill loads is Instruction Markdown

A file under `plugins/<plugin>/docs/` that a skill reads through
`${CLAUDE_PLUGIN_ROOT}/docs/<file>` is Instruction Markdown, though a
path-based classifier calls it Documentation. Implement, style-check,
and review it inside the review loop as code, and leave it out of the
docs-writer pass. Before treating such a file as Documentation, grep
the plugin's skills for `docs/<file>`. The repo root `README.md` stays
Documentation.

## A renamed skill heading dangles in whatever cites it

A skill may cite another skill's section heading verbatim as a prose
pointer, and a skill may cite one of its own. Renaming a heading
leaves a dangling reference, and nothing catches it. Treat a heading
rename as an API change. Find every citation by grep and update it in
the same commit as the rename. The repo keeps no index of those
citations, so grep is the whole discovery mechanism. A rename inside
one file dangles just as silently, so sweep the file you renamed in as
well as its siblings.

Search wrap-tolerantly, because a citation is prose and prose wraps. A
line-oriented grep for the whole cited text matches only the line the
heading itself sits on, and misses a citation that wraps across two
lines. Grep instead for one distinctive word from the cited text. A
single word is the longest fragment a wrap can never split:

```bash
grep -rn "<distinctive-word>" plugins/*/skills/*/SKILL.md
```

When the cited text has no distinctive single word, run a multiline
search whose pattern tolerates the wrap:

```bash
rg -U --multiline-dotall '<word>\s+<word>\s+<word>' plugins
```

Write a word boundary with `git grep -P`, never `git grep -E`. The
extended-regex engine reads `\b` as a literal `b`, so an `-E` pattern
carrying a boundary matches nothing and reports a clean sweep whether
or not the references are still there. The boundary is load-bearing
whenever a bare skill name also sits inside a longer word, because
without it the grep reports that longer word as a hit:

```bash
git grep -nP 'critique-plan\b'
```

Run such a check once before the rename and confirm it matches. A
zero-hit result afterwards means something only if you have seen the
same command produce hits.

## Markdown

Every Markdown file must pass `npx markdownlint-cli2 <file>` with zero
errors before commit.

## Prose in this repo

This repo's own Markdown carries no parenthetical. Do not set prose
off with any of these:

- parentheses
- paired hyphens
- paired dashes

Choose one of these instead:

- Write the content into the sentence.
- Give it a sentence of its own.
- Delete it.

Parentheses that carry technical meaning stay, such as function-call
syntax or a unit.

Put no count in front of a self-counting list. Write "The plan has these
sections:", not "The plan has five sections:".

Quoted material is exempt, including the user prompts in
`plugins/writing/EVAL.md`.
