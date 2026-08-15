# claude-plugins-marketplace

Ellen Orange's Claude Code plugin marketplace. One marketplace
(`ellenorange`), one plugin (`writing`).

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

Response-template skills for concise technical prose. Each skill
styles its output per an always-on writing-style rule based on
ASD-STE100 (Simplified Technical English, Issue 9, 2025). The rule
ships with the plugin at
[`plugins/writing/rules/writing-style.md`](plugins/writing/rules/writing-style.md),
where it is inert; the `install-writing-style` skill (or
`plugins/writing/install-rule.sh` directly) copies it to
`~/.claude/rules/writing-style.md` and wires it into `CLAUDE.md` so it
loads always-on.

Skills:

- **install-writing-style** — install the shipped writing-style rule
  into `~/.claude/rules/` and add the `@~/` load line to `CLAUDE.md`.

- **findings-summary** — emit review or investigation findings as a
  prioritized list: title, one-sentence problem, a triage verdict
  (`fix` / `respond` / `discuss`), and a 1–3 sentence proposed
  solution.
- **write-plan** — read an issue and the foundational docs, interview
  the user to resolve open design questions, write an
  inverted-pyramid technical spec and plan, and post it as an issue
  comment.
- **critique-plan** — read a plan and the foundational docs; list
  decisions that fail to fully address the identified problems or
  cause problems elsewhere, and list gaps.

## License

GPL-3.0. See [LICENSE](LICENSE).
