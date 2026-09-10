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

- `converge-plan` cites the write-plan heading "5. Write", the
  critique-plan Report bullet "Skip the pruning under a loop", the
  critique-plan headings "Inputs" and "4. Collect", the promote-plan
  heading "4. Write the plan into the issue body", and the sweep-plan
  headings "Inputs" and "Output".
- `critique-plan` cites the write-plan headings "Derive the scope",
  "5. Write", and "State the acceptance criteria".
- `promote-plan` cites the write-plan heading "5. Write".
- `write-plan` cites the promote-plan heading "2. Read both texts
  verbatim", the converge-plan heading "2. Set up the state", and the
  sweep-plan headings "Inputs" and "Output".
- `sweep-plan` cites the write-plan headings "Walk each stated
  behavior", "5. Write", "7. Style pipeline", and "8. Human review",
  and the write-plan self-review bullet "Restatements".
- `revise-plan` cites the write-plan heading "5. Write".

No sibling file cites the sweep-plan headings "The one-change agenda"
and "The style agenda" by that spelling. `converge-plan`,
`write-plan`, `README.md`, and `plugins/writing/EVAL.md` name them in
lowercase prose instead, as "the one-change agenda" and "the style
agenda". A case-sensitive grep for the heading text therefore misses
every one of those references, and they dangle on a rename all the
same. Sweep them alongside the verbatim citations above, and grep for
the lowercase form:

```bash
git grep -n "one-change agenda"
```

A case-sensitive grep for "The style agenda" does return hits outside
the headings. One is sweep-plan's own Inputs list item, which labels
the agenda that heading documents. The rest are this file's own
quotations of the heading text, in the paragraph above and in this
one. Rename all of them with the heading.

Renaming a heading in one `SKILL.md` leaves a dangling reference in
another, and nothing catches it. Treat a heading rename as an API
change. Update every citation in the same commit as the rename.

A skill also cites a heading in another plugin. Every such citation,
whichever plugin it names, sits in
`plugins/writing/docs/review-sources.md` or under
`plugins/writing/skills/`. Resolve it against the install path the
locator in `review-sources.md` returns for the named plugin.

A skill also cites its own headings:

- `converge-plan` points one step at another through the section
  names "Run a round", "The staleness guard", and "The body-surface
  guard". Its round steps 3 and 4 both name the stopping rule
  "Blocked", which is a bold list item rather than a heading.
- `write-plan` cites its own headings from these units, and this list
  is the whole set:
  - "The interview's state" points at "5. Write" and "9. Post".
  - "Resume or start fresh" points at "The interview's state",
    "4. Propose", and "5. Write".
  - "Sweep each ruling at decision time" points at "5. Write",
    "7. Style pipeline", and "8. Human review".
  - "Walk each stated behavior" points at "Cite the authority instead
    of restating it".
  - "4. Propose" points at "State the acceptance criteria" and "Walk
    each stated behavior".
  - "5. Write" points at "Derive the scope" and "State the acceptance
    criteria".
  - "Derive the scope" points at "1. Read".
  - "State the rule that generates each set" points at "State the
    acceptance criteria".
  - "Cite the authority instead of restating it" points at "State the
    rule that generates each set".
  - "6. Self-review" points at "1. Read", "5. Write", "7. Style
    pipeline", "Derive the scope", "Mark every waiver", "State the
    acceptance criteria", "State the rule that generates each set",
    "The problem states no solution", and "Walk each stated behavior".
    It also names "State the how, never the result", which is a bold
    list item under "The outline" rather than a heading.
  - "8. Human review" points at "7. Style pipeline".
- `critique-plan` points one section at another through the name
  "Derive each named set from the code". Its Collect step also names
  the "Inputs" section, and that section names the Collect step by
  that word rather than by the numbered heading "4. Collect". The
  Collect step names the Report step by that word too, rather than by
  the numbered heading "5. Report".
- `sweep-plan`'s one-change agenda points at its own "Output" section
  for the routing of an unanswered question. Its "Inputs" section
  names "Output" as its co-owner of the sweep-file handoff mechanism,
  and its "What each caller passes" section names both "Inputs" and
  "Output" as that mechanism's owner.

A rename inside one file dangles just as silently. Sweep the file you
renamed in as well as its siblings.

Search wrap-tolerantly, because a citation is prose and prose wraps.
The converge-plan citation of "Skip the pruning under a loop" sits
across two lines today. A line-oriented grep for the whole cited text
therefore matches only the bullet it came from, and misses the
citation you need to update. Grep instead for one distinctive word
from the cited text. A single word is the longest fragment a wrap can
never split:

```bash
grep -rn "pruning" plugins/*/skills/*/SKILL.md
```

When the cited text has no distinctive single word, run a multiline
search whose pattern tolerates the wrap:

```bash
rg -U --multiline-dotall 'Skip\s+the\s+pruning\s+under\s+a\s+loop' plugins
```

Write a word boundary with `git grep -P`, never `git grep -E`. The
extended-regex engine reads `\b` as a literal `b`, so an `-E` pattern
carrying a boundary matches nothing and reports a clean sweep whether
or not the references are still there. The boundary is load-bearing
whenever a bare skill name also sits inside a longer word, because
without it the grep reports that longer word as a hit:

```bash
git grep -nP 'sweep-plan\b'
```

Run such a check once before the rename and confirm it matches. A
zero-hit result afterwards means something only if you have seen the
same command produce hits.

## The sweep's model is restated at every spawn site

`sweep-plan` → "Execution context" mandates that every call run in a
fresh-context general-purpose subagent on the Opus model. That section
owns the mandate. A spawning skill has to name a model at the spawn
itself, so `converge-plan` and `write-plan` each restate it at every
site that spawns a sweep. `README.md` restates it once more, in its
`sweep-plan` entry. Changing the mandated model means changing the
mandate and every restatement in the same commit.

Search wrap-tolerantly here too. The phrase wraps across two lines in
`README.md` today, so a line-oriented grep misses that restatement:

```bash
rg -U --multiline-dotall 'Opus\s+model' .
```

These sites look like misses and are not:

- `converge-plan`'s `critique-plan` spawn names no model, and says so
  in words. Leave it that way.
- `converge-plan`'s "Blocked" step 4 sweeps a ratified ruling through
  `sweep-plan` per "Run a round" step 4. It routes to that spawn
  rather than spawning, so it names no model. Leave it that way.
- `plugins/writing/EVAL.md` defers to the model `sweep-plan` mandates
  rather than naming it, so its expectations survive a change of
  model. Do not re-inline the model name there.

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
