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
  marked user-ratified or repo-derived. A repo-derived ruling keeps
  its derivation in the ledger, and a failed command in that
  derivation blocks the ruling. The Propose step runs in two stages:
  the framing and the candidate solutions first, then the criteria
  the chosen solution earns. The agreed core is drafted to disk, given
  one `sweep-consequences` pass and one `sweep-style` pass, and
  revised once through `revise-plan` before the full plan is drafted
  from it. Each sweep writes its instructions to a file of its own in
  the state directory, and `revise-plan` applies those files, so the
  skill composes no instruction itself. The repo-derived answers to a
  sweep's `fix`-triaged questions go to one fold call of
  `sweep-consequences`, and each becomes a ruling only after the fold
  reports its check passed. Every command the plan carries, every
  text it prescribes verbatim, and every claim about how existing
  code behaves is run or quoted first, and the record is appended to
  an evidence log before the item is written. An item the skill
  cannot verify lands under Open questions, never as plan text. Its
  "Write for the implementer" section owns the altitude rule, which
  keeps plan text at the level the implementer cannot derive from the
  tree. The plan carries the sections Problem, Scope, Solution,
  Acceptance, Outline, Files affected (floor), and Open questions, in
  the issue-body grammar of `sdlc:orchestrate-readiness`.
  The Acceptance section splits into Mechanical and Semantic claims
  about the merged result, written as the PR reviewer's rubric. Each
  bullet is a bold title and one claim, and each Mechanical claim
  names one read-only command. Self-review grades the draft against
  the installed readiness bar, and reports the grading as skipped when
  the sdlc plugin is absent. The skill walks the plan's dependencies
  at the ref the plan builds on, and walks every behavior the plan
  states against the repo's rule for that kind of behavior, or against
  a completeness test of its own where the repo states no such rule.
  It derives the plan's scope from the repo's sweep sections, and
  describes the bordering work it rules out without naming an issue
  number. It cites its authorities instead of restating them. Every
  sweep question passes through `summarize-findings` triage, so only a
  `discuss` verdict reaches the user. It posts the plan as an issue
  comment and leaves its state directory in place for `converge-plan`
  to seed from. That directory sits under the XDG state home, keyed
  by the target repo's host, owner, and name, so it survives any
  repo-local cleanup and a later postmortem can read the ledger and
  the evidence log.
- **sweep-consequences**: discover the edits a decision set forces on a
  plan and emit them as instructions. It enumerates the cross-cutting
  consequences of the whole set, walks every behavior those decisions
  alter, and finds each fix's sibling defect instances. It owns the
  channel that routes a question it cannot settle back through the
  caller's triage. It writes only the instruction file its caller names,
  appends only to the evidence file its caller names, and posts nothing.
  The instruction file carries the primary instruction for every
  decision that forces an edit, so the caller composes none, and every
  instruction keeps the altitude rule `write-plan` → "Write for the
  implementer" owns. A fix to a rule stated at several sites emits one
  instruction naming one owner. The repo-derived answers to a call's
  `fix`-triaged questions fold through exactly one further call, which
  writes its own file beside the first and returns a failed answer as a
  question.
- **sweep-style**: sweep a whole plan against the communication-style
  rule and `write-plan`'s Write step, and emit the repairs as
  instructions. It emits no question. It writes only the instruction
  file it is handed, and posts nothing. It repairs form only: it never
  merges or splits an Acceptance bullet, and never changes what a
  sentence claims.
- **revise-plan**: apply one or more instruction files to one plan
  file in fresh context. It returns unapplied any instruction that
  breaks the altitude rule `write-plan` → "Write for the implementer"
  owns. It style-sweeps every unit an instruction landed in, then
  reads the result back to confirm that every decision, obligation,
  membership rule, qualifier, and check survives unchanged. It owns
  the restructuring moves an instruction may prescribe and the rule
  for resolving an instruction it could not apply. It reverts an edit
  whose read-back finds changed meaning, and reports every unapplied
  instruction with the conflict named.
- **promote-plan**: move an approved plan out of its issue comment and
  make it the whole issue body. It recognizes a plan comment by the
  sections `write-plan` emits. The body it writes is the plan and
  nothing else, with an Open questions section reading `None.`
  dropped. It asks first when the plan's Open questions section is
  not empty, and when the plan fails an item of the installed
  `sdlc:orchestrate-readiness` bar. One question covers the body write
  and the comment deletion together. After the write it runs the sdlc
  readiness check and reports its verdict.
- **critique-plan**: read a plan and the foundational docs, then
  report one prioritized list. The list carries the decisions that
  fail to fully address the identified problems, the decisions that
  cause problems elsewhere, and the gaps. The skill runs the sources
  of the review that will grade the implementation against the plan.
  It reads the style guides that review enforces. It reports a
  criterion above its altitude, a section past its budget, and a
  compound outline action. It takes the caller's evidence log as an
  optional input, reads an item's record before it verifies the item,
  and reports a record that contradicts its item. An item with no
  record it verifies itself. It treats a user-ratified ruling as fixed
  and may report a finding against a repo-derived one. Each finding
  states its provenance and carries a second label,
  `readiness-failure`, `build-changing`, or `text-only`.
- **converge-plan**: run the critique-and-fix loop over a plan on an
  issue until a stopping rule ends it. The loop keeps a decision
  ledger, an open-issues doc, per-round snapshots, the round's draft,
  an evidence log, and each sweep's instruction file as durable state
  under the XDG state home, outside the target repo. It seeds the
  ledger and copies the evidence log from `write-plan`'s own state
  directory when one is there, and before round 1 presents every
  seeded repo-derived ruling with its derivation for one batch veto.
  It orchestrates rather than edits: it verifies each finding and
  applies the acceptance bar itself, collects the round's edit
  instructions through one `sweep-consequences` call over the round's
  whole accepted batch, and hands the file that call wrote to
  `revise-plan` without adding, removing, or rewording a line. A
  round's `fix`-triaged sweep answers go to one fold call, and a
  failed fold answer pauses the round as a `discuss` item. Every
  sweep question passes through `summarize-findings` triage before
  the blocked rule fires. In every round after the first, the critic
  receives the previous snapshot and the instruction files that round
  applied, so the churn rule can fire in any round. Churn counts
  every finding against text the previous edit or a consolidation
  pass added, whatever produced that text, a user ruling included. A
  spent budget runs one consolidation pass through `sweep-style`
  before the loop reports. It loops in place over the plan comment or
  over the promoted plan in the issue body, and on a body it
  snapshots and edits the whole body. A body carries the Open
  questions section only while the ledger holds an open item. It
  refuses to edit a body when an open pull request or an unmerged
  remote branch already carries the issue.
  A round budget caps how many critique rounds the loop runs.

## License

GPL-3.0. See [LICENSE](LICENSE).
