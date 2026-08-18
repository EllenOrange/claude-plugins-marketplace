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
   numbered list with `fix | refute | discuss` triage verdicts; no
   prose restatement after the list.
2. "Audit our error handling in `src/server/` and report what you
   find."
   Expect: the skill triggers; low-value findings such as obvious
   omissions and wording nits are dropped.
3. "Summarize these findings for an automated verification loop, not
   for me."
   Expect: the skill triggers; the pruning step is skipped and every
   collected finding appears in the list.
4. Negative: "What does this function do?"
   Expect: the skill does not trigger; a plain explanation is fine.

## critique-plan

1. "Red-team this design doc: `docs/cache-design.md`."
   Expect: the skill triggers; Claude reads the doc, project docs, and
   touched code; output is one prioritized list in the
   findings-summary format, carrying both the failing decisions and
   the gaps; the plan is not rewritten.
2. "Here's my migration plan, poke holes in it." with the plan pasted
   inline.
   Expect: the skill triggers on inline text, not only on files.
   Expect the problem-definition check to run first, including the
   test for a problem statement that presupposes its solution.
3. "Critique this plan. It builds on the branch in PR #77."
   Expect: every claim about the repo is verified at that branch's
   ref, not at main; each finding names the file and ref it was
   verified against.
4. "Critique this plan." on a plan that prescribes an AWS SDK call
   pattern with no citation.
   Expect: a finding that flags the uncited external prescription;
   the plan's stated usage is checked against the docs for the
   targeted version, not from recollection.
5. "Critique this plan." on a plan that restates a repo rule and gets
   it wrong.
   Expect: the proposed solution deletes the restatement and cites
   the rule, rather than correcting the copy.
6. "Critique this plan." with a decision ledger and a known-open list
   supplied.
   Expect: no finding re-litigates a ratified ruling or re-reports a
   known-open question; each finding carries a `build-changing` or
   `text-only` label alongside its triage verdict.
7. Negative: "Critique the naming in this function."
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
4. "Plan the work for issue #42."
   Expect: the Problem section names no fix, mechanism, or component;
   the Solution section is one paragraph and not a task list; the
   Outline gives each unit a `###` header and each action a bullet.
5. "Plan the work for issue #42." on an issue that builds on a
   component sitting on an unmerged branch.
   Expect: Claude walks each outline action against that component's
   surface at the branch ref, and turns each gap into an interview
   question or a named extension unit.
6. "Plan the work for issue #42." on an issue whose work calls an
   external SDK.
   Expect: Claude reads the SDK docs before prescribing the call
   pattern, and cites what it read; long citations land in a
   References section at the bottom.
7. "Plan the work for issue #42." with a mid-interview ruling that
   renames a field.
   Expect: Claude enumerates the ruling's consequences at decision
   time, and the plan's Open questions section carries only questions
   the body still leaves open.

## plan-converge

1. "Converge the plan on issue #42."
   Expect: the skill triggers; state lands in
   `.claude/tmp/plan-converge-42/`; each round spawns a
   fresh-context critic and ends with exactly one in-place edit of
   the plan comment; the stop report names the rule that ended the
   loop.
2. "Keep critiquing and fixing the plan on issue #42 until it
   settles." on an issue whose body already carries a `## Plan`
   section.
   Expect: Claude asks to demote the plan back into a comment before
   looping, and stops without confirmation.
3. "Run the critique loop on issue #42." on a plan whose remaining
   build-changing findings are all discuss items.
   Expect: the loop pauses on the blocked rule, presents the
   open-issues doc, and resumes only after rulings arrive.
4. Negative: "Critique the plan on issue #42."
   Expect: `plan-converge` does not trigger; `critique-plan` does,
   and it runs once with no fixes applied.

## promote-plan

1. "Promote the plan on issue #42 into the issue."
   Expect: the skill triggers; the plan text lands at the bottom of
   the issue body under a `## Plan` header with its headings shifted
   down one level; Claude asks before deleting the source comment.
2. "Move the plan comment into the issue body." on an issue whose
   body already carries a `## Plan` section.
   Expect: the existing section is replaced, and the body ends with
   exactly one `## Plan` header.
3. Negative: "Write a plan for issue #42."
   Expect: `promote-plan` does not trigger; `write-plan` does.

## install-writing-style

1. "Install the writing-style rule."
   Expect: the skill triggers; `install-rule.sh` runs from
   `${CLAUDE_PLUGIN_ROOT}`; the CLAUDE.md line is added or confirmed;
   the result is verified.
2. "Update my installed writing-style rule to the plugin's latest."
   Expect: on a diverged installed copy, Claude shows the diff and
   asks before re-running with `--force`.

## Follow-up

The heavier benchmark path remains open; see issue #2. That path runs
with-skill and baseline sessions and grades them with the
`skill-creator` plugin, installed by
`/plugin install skill-creator@claude-plugins-official`.
