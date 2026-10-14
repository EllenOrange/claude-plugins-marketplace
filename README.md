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

Response-template skills for concise technical prose, plus skills
that write, critique, and fix a plan for an issue. A plan is written
as decisions and outcomes.
[`plugins/writing/docs/plan-style.md`](plugins/writing/docs/plan-style.md)
states the format, the length, and the style of a plan. A plan carries the
sections Problem, Design, Acceptance, and Files affected, in that
order, and nothing else.

Skills:

- **summarize-findings**: emit review or investigation findings as a
  prioritized list. Each finding carries a title, a one-sentence
  problem, a triage verdict of `fix`, `refute`, or `discuss`, and a
  proposed solution of 1 to 3 sentences.
- **write-plan**: read an issue, the foundational docs, and the code
  the issue touches, then interview the user until no design question
  is open. When there is a real choice between designs, it shows the
  candidates and lets the user pick one. It then shows a draft of the
  plan's Design section, and drafts nothing else until the user
  confirms that Design. It derives the acceptance criteria from the
  confirmed Design. It drafts the plan in the harness scratchpad,
  self-reviews the draft, and shows it to the user. The self-review
  checks the format, the length, that the Design is the one the user
  confirmed, each claim about the tree, the review's questions, the
  installed `sdlc:orchestrate-readiness` bar, and the plan's second-order
  consequences for the surrounding code and text. It posts the plan as
  an issue comment once the user approves it. It runs on Opus.
- **critique-plan**: read a plan, its issue, the foundational docs,
  and the code the plan touches, then report one prioritized list. It
  checks the problem first, then the decisions and the gaps, the plan
  against its style, each claim about the tree, the questions of the
  review that will grade the implementation, and the installed
  readiness bar. A finding names every instance of its defect. Each
  finding states its provenance and carries a label,
  `readiness-failure`, `build-changing`, or `text-only`. It runs on
  Fable.
- **converge-plan**: run one critique-and-fix round over a plan on an
  issue. It reads the plan off the issue comment or the issue body,
  has `critique-plan` read it once in a fresh context, and puts the
  verified findings to the user as one batch. It applies the accepted
  findings, every instance of each defect and the second-order
  consequences of each fix, in one edit. It refuses to edit a body
  when an open pull request or an unmerged remote branch already
  carries the issue. It reports how many claims the critic read and
  refuted, how many the edit fixed, and how many findings it rejected.
- **promote-plan**: move an approved plan out of its issue comment and
  make it the whole issue body. It recognizes a plan comment by the
  sections `plan-style.md` states. The body it writes is the plan and
  nothing else. It asks first when the plan fails an item of the
  installed `sdlc:orchestrate-readiness` bar. One question covers the
  body write and the comment deletion together. After the write it
  runs the sdlc readiness check and reports its verdict.

## License

GPL-3.0. See [LICENSE](LICENSE).
