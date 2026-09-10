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

- `converge-plan` cites the write-plan headings "5. Write", "State
  the acceptance criteria", "The state directory", and "Define the
  ledger's entry classes", the critique-plan Report bullet "Skip the
  pruning under a loop", the critique-plan headings "Inputs" and
  "4. Collect", the promote-plan heading "4. Write the plan into the
  issue body", the sweep-consequences headings "Execution context" and
  "Output", the sweep-style heading "Execution context", and the
  revise-plan heading "Output".
- `critique-plan` cites the write-plan headings "Derive the scope",
  "5. Write", "State the acceptance criteria", and "The outline".
- `promote-plan` cites the write-plan headings "5. Write" and "State
  the acceptance criteria".
- `write-plan` cites the promote-plan heading "2. Read both texts
  verbatim", the converge-plan heading "2. Set up the state", the
  sweep-consequences headings "Execution context" and "Output", the
  sweep-style heading "Execution context", and the revise-plan heading
  "Output".
- `sweep-consequences` cites the write-plan headings "Walk each stated
  behavior" and "5. Write", and the revise-plan heading "The edit
  rules".
- `sweep-style` cites the write-plan heading "5. Write", the
  write-plan self-review bullet "Restatements", the
  sweep-consequences heading "Output", and the revise-plan heading
  "The edit rules".
- `revise-plan` cites the write-plan heading "5. Write".

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
  names "Run a round", "The staleness guard", "The body-surface
  guard", and "1. Locate the plan". Its budget-spent rule names the
  stopping rule "Churn" for the consolidation mechanics it reuses. Its
  round steps 3 and 4 both name the stopping rule "Blocked", which is
  a bold list item rather than a heading.
- `write-plan`'s Propose step, Write step, and self-review point at
  its own subsections, among them "Derive the scope", "State the
  acceptance criteria", "State the rule that generates each set", and
  "Mark every waiver". Its Propose step and its self-review also point
  at "Walk each stated behavior", and that subsection in turn points at
  "Cite the authority instead of restating it". Its state directory
  points at "4. Propose", and its interview and triage steps point at
  "Define the ledger's entry classes". Its human review step points at
  "Triage the sweep's questions". Its self-review points at "7. Style
  pipeline". Its Propose step and its self-review point at "5. Write".
  Its "Derive the scope" subsection and its self-review point at
  "1. Read".
- `critique-plan` points one section at another through the name
  "Derive each named set from the code". Its Collect step also names
  the "Inputs" section, and that section names the Collect step by
  that word rather than by the numbered heading "4. Collect". The
  Collect step names the Report step by that word too, rather than by
  the numbered heading "5. Report".
- `sweep-consequences`' decision-set agenda points at its own "Output"
  section for the routing of an unanswered question.

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
git grep -nP 'sweep-style\b'
```

Run such a check once before the rename and confirm it matches. A
zero-hit result afterwards means something only if you have seen the
same command produce hits.

## One skill's state directory is another skill's input

`write-plan` writes its ledger and its draft to
`.claude/tmp/write-plan-<issue>/`, and leaves the directory in place
after it posts. `converge-plan` reads that same path to seed its own
ledger and to compare the draft against the live plan surface. The
path and the filenames `ledger.md` and `draft.md` are a contract
between them.

A rename on either side dangles as silently as a renamed heading. The
heading sweep above misses it, because the pointer is a path rather
than quoted prose. Sweep for the directory name instead:

```bash
git grep -nP 'write-plan-<issue>'
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
