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
per an always-on communication-style rule based on
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
- **findings-summary**: emit review or investigation findings as a
  prioritized list: title, one-sentence problem, a triage verdict of
  `fix`, `refute`, or `discuss`, and a proposed solution of 1 to 3
  sentences.
- **write-plan**: read an issue and the foundational docs, interview
  the user to resolve open design questions, write an
  inverted-pyramid technical spec and plan, and post it as an issue
  comment. The plan carries an Acceptance criteria section, with an
  Invariants subsection, whose entries are class-quantified claims
  about the merged result, each with the check that settles it and the
  test that pins it. It walks the plan's dependencies at the ref the
  plan builds on, derives its scope from the repo's sweep sections and
  its neighboring issues, and cites its authorities instead of
  restating them.
- **promote-plan**: move an approved plan out of its issue comment
  and into the bottom of the issue body, under a `## Plan` header. It
  asks first when the plan's Open questions section is not empty.
- **critique-plan**: read a plan and the foundational docs, then
  report one prioritized list carrying both the decisions that fail
  to fully address the identified problems or cause problems
  elsewhere and the gaps. It runs the sources of the review that will
  grade the implementation against the plan, reading the style guides
  that review enforces. Each finding states its provenance and
  carries a second label, `build-changing` or `text-only`.
- **plan-converge**: run the critique-and-fix loop over a plan on an
  issue until a stopping rule ends it, keeping a decision ledger, an
  open-issues doc, and per-round snapshots as durable state. It loops
  in place over the plan comment or over the promoted plan in the
  issue body, and it refuses to edit a body an open branch or pull
  request already carries. A round budget caps how many critique
  rounds the loop runs.

## License

GPL-3.0. See [LICENSE](LICENSE).
