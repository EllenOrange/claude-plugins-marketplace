# Brief: Writing style customization for Claude Code

## Goal

Claude's responses and technical prose are too wordy. They contain more
information than the reader needs to understand the message and make a
decision. Fix this with a standing writing-style specification based on
ASD-STE100 (Simplified Technical English, Issue 9, 2025), plus reusable
response-template skills that replace prompt boilerplate we currently
retype.

## Deliverables

### 1. Base style rule — in `global-claude-config-mirrored-to-public`

- `rules/writing-style.md`, always on via a new `@~/` line in
  `CLAUDE.md`.
- Contents: an inverted-pyramid kernel (most important information
  first; include only what changes the reader's next decision), and the
  STE writing-rules subset:
  - Maximum ~20 words per sentence for instructions, ~25 for
    description.
  - One instruction per sentence; active voice for procedures.
  - Simple tenses only.
  - Noun clusters of 3 words or fewer.
  - One term per concept — no synonym variation.
  - One topic per paragraph, 6 sentences or fewer.
  - Vertical lists for sequences and for 3+ items.
  - Explicit subjects, verbs, and articles — no telegraphic fragments.
- Scope: responses to the user, docs, specs, issue/PR text, and prose
  in code comments. Out of scope: code itself, quotations, exact
  technical references, and STE's controlled dictionary (vocabulary
  stays unrestricted).

### 2. Personal plugin marketplace — this repo

Public repo `ellenorange/claude-plugins-marketplace`, cloned at
`/Users/etodd/Developer/personal/claude-plugins-marketplace`.

- `.claude-plugin/marketplace.json` — marketplace `ellenorange`, one
  plugin entry.
- `plugins/writing/` — plugin manifest plus skills. Each skill
  references the base rule for prose style rather than duplicating it:
  - `findings-summary` — prioritize findings and emit
    `#N. Title / Problem: one sentence / Triage: fix | respond |
    discuss / Proposed Solution: 1–3 sentences`. Includes the standing
    push-back license (anything a reasonable senior engineer could
    figure out alone, especially omissions and wording ambiguities)
    and the `discuss` criterion (a legitimate design issue that needs
    discussion with the user).
  - `write-plan` — read the issue and foundational docs, interview the
    user to resolve open design questions (per
    `rules/ask-vs-discuss.md`), write an inverted-pyramid technical
    spec and plan, post it as an issue comment.
  - `critique-plan` — read the plan and foundational docs; list
    decisions that fail to fully address the identified problems or
    cause problems elsewhere, and list gaps.
- Public-repo hygiene: README, LICENSE.

### 3. Wiring — back in the config repo

Add `ellenorange` to `extraKnownMarketplaces` (git URL,
`autoUpdate: true`) and `"writing@ellenorange": true` to
`enabledPlugins` in `settings.json`.

## Constraints

- Skills stay out of the config repo. This preserves the "skills live
  in plugins" invariant in `repo-is-claude-config-source.md`.
- The base rule must compose with the harness system prompt, not fight
  it: target selection and structure, not sentence compression. STE's
  no-ellipsis rule already forbids fragment-style terseness.
- The plugin name is `writing`, not `writing-tools`, to avoid
  colliding with the enabled Voskamps plugin.

## Sequence

1. `rules/writing-style.md` + the `CLAUDE.md` line in the config repo
   (standalone value, no dependencies) — PR.
2. Scaffold this marketplace repo,
   `gh repo create ellenorange/claude-plugins-marketplace --public`,
   push.
3. `settings.json` wiring — PR in the config repo. Verify the skills
   appear, then iterate on wording in real use.
