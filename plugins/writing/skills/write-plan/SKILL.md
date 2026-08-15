---
name: write-plan
description: Write a technical spec and implementation plan for an issue and post it as an issue comment. Use whenever the user asks to plan, spec, or design the work for an issue or ticket.
---

# write-plan

Produce a technical spec and implementation plan for one issue, and
post it as a comment on that issue. Write all prose per
`~/.claude/rules/writing-style.md`.

## 1. Read

- Read the issue. If the user has issue skills installed (for example
  `/issues:issue-view`), use them; they dispatch to the repo's
  configured tracker. Otherwise use `gh issue view`.
- Read the project's foundational docs: `CLAUDE.md`, `README.md`,
  design docs under `docs/`, and any files the issue references.
- Read the code the issue touches before proposing changes to it.

## 2. Interview

Resolve open design questions with the user before you write.
Follow `~/.claude/rules/ask-vs-discuss.md` if present: build
understanding with plain questions, one at a time; reserve
multiple-choice forms for bounded decisions among known options.
Do not manufacture questions you can settle by reading the repo.

## 3. Write

Write the spec and plan as an inverted pyramid:

1. **Decision** — what will be built, in one short paragraph.
2. **Why** — the problem and the constraints that picked this design,
   including alternatives rejected and the reason each lost.
3. **Design** — the components, interfaces, and data changes.
4. **Plan** — ordered implementation steps, each independently
   verifiable.
5. **Risks and open questions** — only ones that survived the
   interview.

Include only what changes the implementer's next decision.

## 4. Post

Post the spec as a comment on the issue. Prefer an installed issue
skill (for example `/issues:issue-comment`); otherwise use
`gh issue comment`. Then report the comment URL to the user.
