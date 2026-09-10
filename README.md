# claude-plugins-marketplace

Ellen Orange's Claude Code plugin marketplace `ellenorange`. It
carries one plugin, `writing`.

## Install

Add to `extraKnownMarketplaces` in `~/.claude/settings.json`:

```json
"ellenorange": {
  "source": {
    "source": "git",
    "url": "https://github.com/ellenorange/claude-plugins-marketplace.git"
  },
  "autoUpdate": true
}
```

Then enable the plugin in `enabledPlugins`:

```json
"writing@ellenorange": true
```

## The `writing` plugin

Response-template skills for concise technical prose, plus a bounded
loop that drives a plan to convergence. Each skill styles its output
per an always-on communication-style rule. The rule is based on
ASD-STE100, Simplified Technical English, Issue 9, 2025. The rule
ships with the plugin at
[`plugins/writing/rules/communication-style.md`](plugins/writing/rules/communication-style.md),
where it is inert. The `install-writing-style` skill copies it to
`~/.claude/rules/communication-style.md` and wires it into
`~/.claude/CLAUDE.md` so it loads always-on. Running
`plugins/writing/install-rule.sh` directly does the same thing.

Skills:

- **install-writing-style**: install the shipped communication-style rule
  into `~/.claude/rules/` and add the `@~/` load line to
  `~/.claude/CLAUDE.md`.
- **summarize-findings**: emit review or investigation findings as a
  prioritized list. Each finding carries a title, a one-sentence
  problem, a triage verdict of `fix`, `refute`, or `discuss`, and a
  proposed solution of 1 to 3 sentences.
- **write-plan**: read an issue and the foundational docs, then
  interview the user to resolve open design questions. Write an
  inverted-pyramid technical spec and plan, and post it as an issue
  comment. The plan carries an Acceptance criteria section with a
  Postconditions subsection and an Invariants subsection. Each entry
  is a class-quantified claim about the merged result. Each carries
  the check that settles it, and either the test that pins it or a
  waiver saying why none exists. The interview keeps its rulings, its
  open questions, and its draft in `.claude/tmp/write-plan-<issue>/`,
  so a run that pauses for a ruling survives the session and resumes
  from that state. The skill walks the plan's dependencies at the ref
  the plan builds on, and walks every behavior the plan states
  against the repo's rule for that kind of behavior, or against a
  completeness test of its own where the repo states no such rule. It
  derives the plan's scope from the repo's sweep sections and its
  neighboring issues. It cites its authorities instead of restating
  them. It sweeps each interview ruling and each human-review change
  through `sweep-plan`, and applies the style pass and the
  human-review changes through `revise-plan`. An interview sweep runs
  in the background, so the question on the table waits on nothing.
- **sweep-plan**: discover the edits a plan needs and emit them as
  instructions. Under the one-change agenda it enumerates the
  cross-cutting consequences of one accepted fix or one ratified
  ruling, walks every behavior that change alters, and finds the fix's
  sibling defect instances. Under the style agenda it sweeps the whole
  plan against the communication-style rule and `write-plan`'s Write
  step. Every call runs in a fresh-context subagent on the Opus
  model, in every caller. It edits no plan file and posts nothing.
  Given a caller output path it writes that one file, and given none
  it returns the instructions inline.
- **revise-plan**: apply an instruction batch to one plan file in fresh
  context. It style-sweeps every unit an instruction landed in, then
  reads the result back to confirm that every decision, obligation,
  membership rule, qualifier, and check survives unchanged. It reverts
  an edit whose read-back finds changed meaning, and reports every
  instruction it could not apply with the conflict named.
- **promote-plan**: move an approved plan out of its issue comment and
  make it the issue body. Whatever the old body carried that the plan
  does not state lands under a trailing `## Notes` section. One
  question covers the body write and the comment deletion together. It
  asks first when the plan's Open questions section is not empty.
- **critique-plan**: read a plan and the foundational docs, then
  report one prioritized list. The list carries the decisions that
  fail to fully address the identified problems, the decisions that
  cause problems elsewhere, and the gaps. The skill runs the sources
  of the review that will grade the implementation against the plan.
  It reads the style guides that review enforces. Each finding states
  its provenance and carries a second label, `build-changing` or
  `text-only`.
- **converge-plan**: run the critique-and-fix loop over a plan on an
  issue until a stopping rule ends it. The loop keeps a decision
  ledger, an open-issues doc, per-round snapshots, the round's draft,
  and the sweep and batch files the round hands between skills as
  durable state. It orchestrates rather than edits: it verifies each
  finding and applies the acceptance bar itself, collects the round's
  edit instructions through `sweep-plan`, composes them into a batch
  file, and hands that file's path to `revise-plan`. It loops in
  place over the plan comment or over the promoted plan in the issue
  body, leaving that body's `## Notes` section unchanged. It refuses
  to edit a body when an open pull request or an unmerged remote
  branch already carries the issue. A round budget caps how many
  critique rounds the loop runs.

## License

GPL-3.0. See [LICENSE](LICENSE).
