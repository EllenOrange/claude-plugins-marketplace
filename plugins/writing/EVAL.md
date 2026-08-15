# Evaluation prompts for the writing plugin

Manual test prompts for the plugin's skills, per the skill-creator
workflow: run each prompt in a fresh session, once with the plugin
enabled and once without, and compare triggering, output shape, and
token cost. Record notes per run next to the prompt.

A prompt passes on the "with" run when the named skill triggers and
the output matches the expected behavior. A prompt also passes when a
skill correctly does **not** trigger on the negative cases.

## findings-summary

1. "Review this diff and tell me what's wrong with it."
   Expect: the skill triggers; findings arrive as a prioritized
   numbered list with `fix | respond | discuss` triage verdicts; no
   prose restatement after the list.
2. "Audit our error handling in `src/server/` and report what you
   find."
   Expect: the skill triggers; low-value findings (obvious omissions,
   wording nits) are dropped.
3. Negative: "What does this function do?"
   Expect: the skill does not trigger; a plain explanation is fine.

## critique-plan

1. "Red-team this design doc: `docs/cache-design.md`."
   Expect: the skill triggers; Claude reads the doc, project docs, and
   touched code; output is two lists (failing decisions, gaps) in the
   findings-summary format; the plan is not rewritten.
2. "Here's my migration plan — poke holes in it." (plan pasted
   inline)
   Expect: the skill triggers on inline text, not only on files.
3. Negative: "Critique the naming in this function."
   Expect: the skill does not trigger; it is scoped to plans and
   specs.

## write-plan

1. "Plan the work for issue #42."
   Expect: the skill triggers; Claude reads the issue and touched
   code, interviews before writing, posts an inverted-pyramid spec as
   an issue comment, and reports the comment URL.
2. "Spec out how we'd add rate limiting (ticket PROJ-17)."
   Expect: the skill triggers on non-GitHub ticket phrasing and uses
   installed issue skills when present.
3. Negative: "What's your plan for fixing this failing test?"
   Expect: the skill does not trigger for an inline fix; no issue
   comment is posted.

## install-writing-style

1. "Install the writing-style rule."
   Expect: the skill triggers; `install-rule.sh` runs from
   `${CLAUDE_PLUGIN_ROOT}`; the CLAUDE.md line is added or confirmed;
   the result is verified.
2. "Update my installed writing-style rule to the plugin's latest."
   Expect: on a diverged installed copy, Claude shows the diff and
   asks before re-running with `--force`.

## Follow-up

The heavier benchmark path — with-skill vs. baseline runs graded by
the `skill-creator` plugin (`/plugin install
skill-creator@claude-plugins-official`) — remains open; see issue #2.
