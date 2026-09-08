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

## Skill headings are quoted by sibling skills

A skill may cite another skill's section heading verbatim as a prose
pointer. The current citations are:

- `plan-converge` cites the write-plan headings "Sweep each ruling at
  decision time" and "5. Write", the write-plan self-review bullet
  "Restatements", the critique-plan Report bullet "Skip the pruning
  under a loop", the critique-plan heading "4. Collect", and the
  promote-plan heading "4. Write the plan into the issue body".
- `critique-plan` cites the write-plan headings "Derive the scope",
  "5. Write", and "State the acceptance criteria".
- `promote-plan` cites the write-plan heading "5. Write".
- `write-plan` cites the promote-plan heading "2. Read both texts
  verbatim".

Renaming a heading in one `SKILL.md` leaves a dangling reference in
another, and nothing catches it. Treat a heading rename as an API
change. Update every citation in the same commit as the rename.

A skill also cites a heading in another plugin. Every such citation,
whichever plugin it names, sits in
`plugins/writing/docs/review-sources.md` or under
`plugins/writing/skills/`. Resolve it against the install path the
locator in `review-sources.md` returns for the named plugin.

A skill also cites its own headings:

- `plan-converge` points one step at another through the section
  names "Run a round", "The staleness guard", and "The body-surface
  guard".
- `write-plan`'s Propose step, Write step, and self-review point at
  its own subsections, among them "Derive the scope", "State the
  acceptance criteria", "State the rule that generates each set", and
  "Mark every waiver".
- `critique-plan` points one section at another through the name
  "Derive each named set from the code".

A rename inside one file dangles just as silently. Sweep the file you
renamed in as well as its siblings.

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
of `sdlc:theorem-generation`. A human re-syncs it by hand. A change to
that skill's sources leaves this file stale, and nothing catches it.

## Markdown

Every Markdown file must pass `npx markdownlint-cli2 <file>` with zero
errors before commit.

## Prose in this repo

This repo's own Markdown follows the communication-style rule it ships at
`plugins/writing/rules/communication-style.md`. Read that file before
writing prose here. The rule that bites most often is the ban on
parentheticals. Do not set prose off with any of these:

- parentheses
- paired hyphens
- paired dashes

Choose one of these instead:

- Write the content into the sentence.
- Give it a sentence of its own.
- Delete it.

Parentheses that carry technical meaning stay, such as function-call
syntax or a unit.

This repo adds a convention of its own, on top of the shipped rule:
no count in front of a self-counting list. Write "The plan has these
sections:", not "The plan has five sections:".

Quoted material is exempt, including the user prompts in
`plugins/writing/EVAL.md`.
