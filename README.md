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
per an always-on writing-style rule based on
ASD-STE100, Simplified Technical English, Issue 9, 2025. The rule
ships with the plugin at
[`plugins/writing/rules/writing-style.md`](plugins/writing/rules/writing-style.md),
where it is inert. The `install-writing-style` skill copies it to
`~/.claude/rules/writing-style.md` and wires it into
`~/.claude/CLAUDE.md` so it loads always-on. Running
`plugins/writing/install-rule.sh` directly does the same thing.

Skills:

- **install-writing-style**: install the shipped writing-style rule
  into `~/.claude/rules/` and add the `@~/` load line to
  `~/.claude/CLAUDE.md`.
- **findings-summary**: emit review or investigation findings as a
  prioritized list: title, one-sentence problem, a triage verdict of
  `fix`, `refute`, or `discuss`, and a proposed solution of 1 to 3
  sentences.
- **write-plan**: read an issue and the foundational docs, interview
  the user to resolve open design questions, write an
  inverted-pyramid technical spec and plan, and post it as an issue
  comment. It walks the plan's dependencies at the ref the plan
  builds on, and cites its authorities instead of restating them.
- **promote-plan**: move an approved plan out of its issue comment
  and into the bottom of the issue body, under a `## Plan` header.
- **critique-plan**: read a plan and the foundational docs, then
  report one prioritized list carrying both the decisions that fail
  to fully address the identified problems or cause problems
  elsewhere and the gaps. Each finding states its provenance and
  carries a second label, `build-changing` or `text-only`.
- **plan-converge**: run the critique-and-fix loop over a plan on an
  issue until a stopping rule ends it, keeping a decision ledger, an
  open-issues doc, and per-round snapshots as durable state.

## License

GPL-3.0. See [LICENSE](LICENSE).
