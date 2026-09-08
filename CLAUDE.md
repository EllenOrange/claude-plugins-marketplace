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
pointer. `plan-converge` cites the write-plan headings "Sweep each
ruling at decision time" and "5. Write", the write-plan self-review
bullet "Restatements", the critique-plan Report bullet "Skip the
pruning under a loop", the critique-plan heading "4. Collect", and the
promote-plan heading "4. Write the plan into the issue body".
`critique-plan` cites the write-plan headings "Derive the scope" and
"5. Write", `promote-plan` cites "5. Write" as well, and `write-plan`
cites the promote-plan heading "2. Read both texts verbatim".
Renaming a heading in one `SKILL.md` leaves a dangling
reference in another, and nothing catches it. Treat a heading rename
as an API change, and update every citation in the same commit as the
rename.

A skill also cites a heading in another plugin. The citations of
`sdlc:` and `cc-tools:` headings live in
`plugins/writing/docs/review-sources.md` and in the skills that file
serves. Resolve such a citation against the install path the locator
in that file returns for the named plugin.

A skill also cites its own headings. `plan-converge` points one step
at another through the section names "Run a round", "The staleness
guard", and "Check the stopping rules", and `write-plan`'s Write step
and self-review point at its own subsections, among them "Derive the
scope", "State the acceptance criteria", "State the rule that
generates each set", and "Mark every waiver". A rename inside one file
dangles just as silently, so sweep the file you renamed in as well as
its siblings.

Search wrap-tolerantly, because a citation is prose and prose wraps.
The plan-converge citation of "Sweep each ruling at decision time"
sits across two lines today. A line-oriented grep for the whole
heading text therefore matches only the heading it came from, and
misses the citation you need to update. Grep instead for one
distinctive word from the heading. A single word is the longest
fragment a wrap can never split:

```bash
grep -rn "Sweep" plugins/*/skills/*/SKILL.md
```

When the heading has no distinctive single word, run a multiline
search whose pattern tolerates the wrap:

```bash
rg -U --multiline-dotall 'Sweep\s+each\s+ruling\s+at\s+decision\s+time' plugins
```

## The review's sources are mirrored by hand

`plugins/writing/docs/review-sources.md` mirrors the sources section
of `sdlc:theorem-generation` and is re-synced by hand. A change to
that skill's sources leaves this file stale, and nothing catches it.

## Markdown

Every Markdown file must pass `npx markdownlint-cli2 <file>` with zero
errors before commit.

## Prose in this repo

This repo's own Markdown follows the communication-style rule it ships at
`plugins/writing/rules/communication-style.md`. Read that file before
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
