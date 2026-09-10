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
  interview the user to resolve open design questions. The interview
  runs uninterrupted and records each ruling to a durable ledger,
  marked user-ratified or repo-derived. The Propose step runs in two
  stages: the framing and the candidate solutions first, then the
  criteria the chosen solution earns. The agreed core is drafted to
  disk, given one `sweep-consequences` pass and one `sweep-style`
  pass, and revised once through `revise-plan` before the full plan is
  drafted from it. The plan carries an Acceptance criteria section
  with a Postconditions subsection and an Invariants subsection. Each
  entry is a class-quantified claim about the merged result, written
  as the PR reviewer's rubric. Each carries the check that settles it,
  and either the test that pins it or a waiver saying why none
  exists. The skill walks the plan's dependencies at the ref the plan
  builds on, and walks every behavior the plan states against the
  repo's rule for that kind of behavior, or against a completeness
  test of its own where the repo states no such rule. It derives the
  plan's scope from the repo's sweep sections and its neighboring
  issues. It cites its authorities instead of restating them. Every
  sweep question passes through `summarize-findings` triage, so only a
  `discuss` verdict reaches the user. It posts the plan as an issue
  comment and leaves its state directory in place for `converge-plan`
  to seed from.
- **sweep-consequences**: discover the edits a decision set forces on
  a plan and emit them as instructions. It enumerates the
  cross-cutting consequences of the whole set, walks every behavior
  those decisions alter, and finds each fix's sibling defect
  instances. It owns the channel that routes a question it cannot
  settle back through the caller's triage. It writes no file and posts
  nothing.
- **sweep-style**: sweep a whole plan against the communication-style
  rule and `write-plan`'s Write step, and emit the repairs as
  instructions. It emits no question. It writes no file and posts
  nothing.
- **revise-plan**: apply an instruction batch to one plan file in fresh
  context. It style-sweeps every unit an instruction landed in, then
  reads the result back to confirm that every decision, obligation,
  membership rule, qualifier, and check survives unchanged. It owns
  the restructuring moves an instruction may prescribe and the rule
  for resolving an instruction it could not apply. It reverts an edit
  whose read-back finds changed meaning, and reports every unapplied
  instruction with the conflict named.
- **promote-plan**: move an approved plan out of its issue comment and
  make it the issue body. It recognizes a plan comment by the sections
  `write-plan` emits, Solution ahead of Acceptance criteria and that
  section carrying both its subsections. Whatever the old body carried
  that the plan does not state lands under a trailing `## Notes`
  section. One question covers the body write and the comment deletion
  together. It asks first when the plan's Open questions section is
  not empty.
- **critique-plan**: read a plan and the foundational docs, then
  report one prioritized list. The list carries the decisions that
  fail to fully address the identified problems, the decisions that
  cause problems elsewhere, and the gaps. The skill runs the sources
  of the review that will grade the implementation against the plan.
  It reads the style guides that review enforces. It reports a
  criterion above its altitude, a section past its budget, and a
  compound outline action. It treats a user-ratified ruling as fixed
  and may report a finding against a repo-derived one. Each finding
  states its provenance and carries a second label, `build-changing`
  or `text-only`.
- **converge-plan**: run the critique-and-fix loop over a plan on an
  issue until a stopping rule ends it. The loop keeps a decision
  ledger, an open-issues doc, per-round snapshots, and the round's
  draft as durable state, seeding the ledger from `write-plan`'s own
  state directory when one is there. It orchestrates rather than
  edits: it verifies each finding and applies the acceptance bar
  itself, collects the round's edit instructions through one
  `sweep-consequences` call over the round's whole accepted batch, and
  hands the batch to `revise-plan`. Every sweep question passes
  through `summarize-findings` triage before the blocked rule fires. A
  spent budget runs one consolidation pass through `sweep-style`
  before the loop reports. It loops in place over the plan comment or
  over the promoted plan in the issue body, leaving that body's
  `## Notes` section unchanged. It refuses to edit a body when an open
  pull request or an unmerged remote branch already carries the issue.
  A round budget caps how many critique rounds the loop runs.

## License

GPL-3.0. See [LICENSE](LICENSE).
