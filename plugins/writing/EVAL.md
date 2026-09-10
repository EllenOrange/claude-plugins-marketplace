# Evaluation prompts for the writing plugin

Manual test prompts for the plugin's skills, following the
skill-creator workflow. For each prompt:

- Run it in a fresh session, once with the plugin enabled and once
  without.
- Compare triggering, output shape, and token cost between the runs.
- Record notes per run next to the prompt.

A prompt passes on the "with" run when the named skill triggers and
the output matches the expected behavior. A prompt also passes when a
skill correctly does **not** trigger on the negative cases.

## summarize-findings

1. "Review this diff and tell me what's wrong with it."
   Expect: the skill triggers; findings arrive as a prioritized
   numbered list with `fix | refute | discuss` triage verdicts; no
   prose restatement after the list.
2. "Audit our error handling in `src/server/` and report what you
   find."
   Expect: the skill triggers, and it drops low-value findings such
   as obvious omissions and wording nits.
3. "Summarize these findings for an automated verification loop, not
   for me."
   Expect: the skill triggers. Claude skips the pruning step, and
   every collected finding appears in the list.
4. Negative: "What does this function do?"
   Expect: the skill does not trigger; a plain explanation is fine.

## critique-plan

1. "Red-team this design doc: `docs/cache-design.md`."
   Expect: the skill triggers. Claude reads the doc, project docs, and
   touched code. The output is one prioritized list in the
   summarize-findings format, carrying both the failing decisions and
   the gaps. Claude does not rewrite the plan.
2. "Here's my migration plan, poke holes in it." with the plan pasted
   inline.
   Expect: the skill triggers on inline text, not only on files.
   Expect the problem-definition check to run first, including the
   test for a problem statement that presupposes its solution.
3. "Critique this plan. It builds on the branch in PR #77."
   Expect: Claude verifies every claim about the repo at that branch's
   ref, not at main. Each finding names the file and ref Claude
   verified it against.
4. "Critique this plan." on a plan that prescribes an AWS SDK call
   pattern with no citation.
   Expect: a finding that flags the uncited external prescription.
   Claude checks the plan's stated usage against the docs for the
   targeted version, not from recollection.
5. "Critique this plan." on a plan that restates a repo rule and gets
   it wrong.
   Expect: the proposed solution deletes the restatement and cites
   the rule, rather than correcting the copy.
6. "Critique this plan." with a decision ledger and a known-open list
   supplied.
   Expect: no finding re-litigates a ratified ruling or re-reports a
   known-open question. Each finding carries a `build-changing` or
   `text-only` label alongside its triage verdict.
7. "Critique this plan." on a repo with the sdlc plugin installed.
   Expect: Claude resolves the review's sources through
   `docs/review-sources.md`. Claude reads the installed
   `sdlc:theorem-generation` skill. Claude asks each source's question
   of the plan and of the implementation the outline prescribes.
8. "Critique this plan." on a repo with no sdlc plugin installed, run
   from a repo other than this one.
   Expect: the locator returns nothing. Claude reads the bundled
   `docs/review-sources.md` through `${CLAUDE_PLUGIN_ROOT}` and
   proceeds with the fallback. Claude reports no error and invents no
   style rule.
9. "Critique this plan." on a plan whose outline prescribes a style
   violation of a rule in the guides the review enforces.
   Expect: a finding naming the violated rule heading, quoted rather
   than paraphrased.
10. "Critique this plan." on a plan that cites a repo rule and
    restates it short.
    Expect: a finding that the restatement does not match the
    authority. The proposed solution deletes the restatement and cites
    the rule.
11. "Critique this plan." on a plan that cites an authority for a
    class and enumerates some of the class's members beside the
    citation, with no member marked illustrative.
    Expect: a finding that the enumeration displaces the authority it
    sits beside. The proposed solution states the membership rule or
    marks the named members as illustrations.
12. "Critique this plan." on a plan with no Acceptance criteria
    section.
    Expect: a finding labelled `build-changing` rather than
    `text-only`, because a missing criterion changes what the reviewer
    checks.
13. Negative: "Critique the naming in this function."
    Expect: the skill does not trigger; it is scoped to plans and
    specs.

## write-plan

1. "Plan the work for issue #42."
   Expect: the skill triggers. Claude reads the issue and touched
   code, and interviews before writing. Claude posts an
   inverted-pyramid spec as an issue comment and reports the comment
   URL.
2. "Spec out how we'd add rate limiting (ticket PROJ-17)."
   Expect: the skill triggers on non-GitHub ticket phrasing and uses
   installed issue skills when present.
3. Negative: "What's your plan for fixing this failing test?"
   Expect: the skill does not trigger for an inline fix, and Claude
   posts no issue comment.
4. "Plan the work for issue #42."
   Expect: the Problem section names no fix, mechanism, or component.
   The Solution section is one paragraph and not a task list. The
   Outline gives each unit a `###` header and each action a bullet.
5. "Plan the work for issue #42." on an issue that builds on a
   component sitting on an unmerged branch.
   Expect: Claude walks each outline action against that component's
   surface at the branch ref, and turns each gap into an interview
   question or a named extension unit.
6. "Plan the work for issue #42." on an issue whose work calls an
   external SDK.
   Expect: Claude reads the SDK docs before prescribing the call
   pattern, and cites what it read. Long citations land in a
   References section at the bottom.
7. "Plan the work for issue #42." with a mid-interview ruling that
   renames a field.
   Expect: Claude enumerates the ruling's consequences at decision
   time, and the plan's Open questions section carries only questions
   the body still leaves open. An empty section reads `None.`.
8. "Plan the work for issue #42."
   Expect: the plan's sections are, in order:
   - Problem
   - Scope
   - Acceptance criteria
   - Solution
   - Outline
   - Open questions
   - References, which is optional

   Acceptance criteria carries these subsections: Postconditions and
   Invariants. Postconditions carries at least one entry. Invariants
   reads `None.` plus one clause when the outline touches no contract.
9. "Plan the work for issue #42."
   Expect: every entry under Postconditions and under Invariants opens
   with a bold title and states a claim about the merged result,
   quantified over a class with its membership rule. Each entry
   carries a `Check:` sub-bullet and a `Pinned by:` or `Waiver:`
   sub-bullet. No entry is an action or an exemplar to imitate.
10. "Plan the work for issue #42."
    Expect: the Propose step shows the postconditions and the
    invariants between the scope summary and the proposed solutions,
    as the definition of done each solution is measured against.
11. "Plan the work for issue #42." on an issue whose work changes a
    fact the repo's `CLAUDE.md` says several surfaces mirror.
    Expect: Scope names those surfaces. The Outline carries one
    class-level sweep action with a grep-shaped verify command. Scope
    names by number the issues whose work borders this one.
12. "Plan the work for issue #42." on a machine with no sdlc plugin
    installed.
    Expect: Claude reads the bundled `docs/review-sources.md` for the
    review's sources and the decision set, and proceeds with no
    error.
13. "Plan the work for issue #42." on an issue whose solution states
    a two-step write with no completion rule.
    Expect: Claude reads the repo for a class rule for that kind of
    write before it turns the gap into a question. Claude walks the
    write against that rule, or against the walk's test, before the
    interview closes. Each unanswered question becomes an interview
    question. A behavior the human review adds is walked by the
    one-change sweep before the post. The posted plan answers every
    question, or carries it under Open questions.
14. "Plan the work for issue #42." with a mid-interview ruling.
    Expect: Claude spawns a fresh-context subagent that loads
    `sweep-plan` under the one-change agenda, on the model that skill
    mandates, passing the ruling inline, the ledger's path, and a
    `sweep-<n>.md` output path. Claude continues the interview without
    waiting on that sweep, and reads the output file when it returns.
    Claude runs no inline sweep of its own.
15. "Plan the work for issue #42."
    Expect: after self-review, Claude runs the style pipeline. It
    spawns one subagent for `sweep-plan` under the style agenda, on
    the model that skill mandates, reads the `sweep-<n>.md` file it
    writes, composes a `batch-<n>.md`, and spawns a second subagent
    for `revise-plan` with the draft's path and that batch path. It
    reads the revised file back before showing it. The self-review
    does no style checking of its own.
16. "Plan the work for issue #42." with a human-review change
    requested after the draft is shown.
    Expect: Claude sweeps the change through `sweep-plan`, reads the
    sweep's output file, composes a batch carrying the requested
    change, and applies it through `revise-plan` in a fresh-context
    subagent. Claude runs no post-apply behavior walk.
17. "Plan the work for issue #42." on an issue whose
    `.claude/tmp/write-plan-42/` already holds a `ledger.md` from an
    earlier run.
    Expect: Claude shows the ledger's rulings and open questions and
    asks whether to resume or start fresh. On a resume it re-asks no
    ratified ruling. It re-spawns only a sweep whose output file the
    disk lacks, and it reads every sweep file the ledger does not mark
    as drained, appending each question that file leaves unanswered to
    the open-question queue. Claude reaches the Propose step only once
    every spawned sweep has returned and every question they raised is
    resolved. A successful post deletes the directory.

## sweep-plan

1. "Sweep this plan for what my ruling on the retry budget drags with
   it."
   Expect: the skill triggers. This invocation carries no caller
   output path, so the instructions come back inline, each naming the
   plan section it targets. Claude writes no file and posts nothing.
2. "Sweep this plan." on an accepted fix finding.
   Expect: the one-change agenda runs. The instructions cover the
   change's verification commands, doc files, scripts, sibling fields,
   and scope statements, plus every other instance of the same defect
   class in the plan.
3. "Sweep this plan for style." on a plan whose bullets carry several
   actions each and whose parallel items sit inline behind semicolons.
   Expect: the style agenda runs over the whole plan. The instructions
   split the multi-action bullets and convert the inline series to
   vertical lists. This invocation carries no caller output path, so
   they come back inline. Claude writes no file.
4. "Sweep this plan." on a ruling whose behavior the plan leaves
   underspecified.
   Expect: the unanswered question comes back as a question rather
   than as an instruction.
5. "Sweep this plan and write the instructions to
   `.claude/tmp/converge-plan-42/sweep-3.md`."
   Expect: Claude writes exactly that file, overwriting it when it is
   already there, and returns the path plus a summary. Claude creates
   no other file, edits no plan file, and posts nothing.
6. Negative: "Apply these edits to the plan."
   Expect: `sweep-plan` does not trigger; `revise-plan` does.

## revise-plan

1. "Apply the batch at `.claude/tmp/converge-plan-42/batch-2.md` to
   `.claude/tmp/converge-plan-42/draft.md`."
   Expect: the skill triggers. Claude reads the batch file, edits the
   draft alone, and reports which instructions applied and which did
   not.
2. "Apply this fix." on an instruction that adds a second action to a
   bullet.
   Expect: Claude splits the bullet rather than appending a clause,
   and style-sweeps the whole unit the edit landed in.
3. "Apply these instructions." on an instruction whose edit would drop
   a criterion's `Check:` command.
   Expect: the read-back finds the changed meaning. Claude reverts the
   edit and reports the instruction unapplied with the conflict named.
4. "Apply these instructions." on an instruction that conflicts with
   the text it targets.
   Expect: Claude reports it unapplied rather than improvising a
   different edit. Claude proposes no finding of its own.
5. Negative: "What else does this ruling change in the plan?"
   Expect: `revise-plan` does not trigger; `sweep-plan` does.

## converge-plan

1. "Converge the plan on issue #42."
   Expect: the skill triggers, and state lands in
   `.claude/tmp/converge-plan-42/`. Each round spawns a fresh-context
   critic and ends with exactly one in-place edit of the located
   surface. The stop report names the surface and the rule that ended
   the loop.
2. "Keep critiquing and fixing the plan on issue #42 until it
   settles." on an issue whose body already carries a promoted plan
   and a trailing `## Notes` section.
   Expect: the loop runs in place over the body's plan sections, with
   one edit of the body per round. Nothing moves the plan back into a
   comment. The `## Notes` section passes through each round byte for
   byte unchanged.
3. "Run the critique loop on issue #42." on a plan whose round yields
   verified discuss findings.
   Expect: the loop pauses on the blocked rule before it applies the
   round's fixes. It presents the open-issues doc one item at a time,
   and resumes only once every item carries a ruling.
4. "Converge the plan on issue #42." on a plan that keeps yielding
   fresh build-changing fix findings every round.
   Expect: the loop stops rather than running unbounded. The stop
   report names the budget-spent rule and the default round budget
   of 5.
5. "Converge the plan on issue #42." on an issue whose plan is
   promoted and that an open pull request carries.
   Expect: the loop stops before its first edit of the body and
   reports why. The body stays unchanged.
6. "Resume the converge loop on issue #42." on a promoted plan whose
   loop paused for rulings with no pull request open, and that a pull
   request opened during the pause now carries.
   Expect: the resumed run re-runs the body-surface guard before its
   next edit. It stops and reports why. The body stays unchanged.
7. Negative: "Critique the plan on issue #42."
   Expect: `converge-plan` does not trigger; `critique-plan` does,
   and it runs once with no fixes applied.
8. "Converge the plan on issue #42." on a plan whose round yields a
   discuss finding, and whose ruling on that finding changes which
   step decides the outcome.
   Expect: the loop pauses before it applies the round's fixes. After
   the ruling, `sweep-plan` walks the changed behavior before any
   prose edit. The fixes and the ruling's consequences land in one
   edit. The next critic's brief carries no previous snapshot. The
   churn rule does not fire in that round.
9. "Converge the plan on issue #42." on a plan whose round yields
   accepted fix findings.
   Expect: Claude edits no plan text itself. It verifies the findings
   and applies the acceptance bar in the main session, spawns each
   `sweep-plan` pass on the model that skill mandates with the round's
   snapshot path, the ledger's path, and a `sweep-<n>.md` output path,
   reads those output files, composes `batch-<round>.md`, writes
   `draft.md`, and hands the batch file's path to `revise-plan` in a
   fresh-context subagent. The round's one surface edit copies the
   revised draft.
10. "Converge the plan on issue #42." on a round whose `revise-plan`
    call reports an instruction unapplied.
    Expect: Claude resolves it before the round posts. It either
    amends the instruction and re-invokes `revise-plan` on the same
    draft, or records the instruction as rejected with the conflict as
    its reason.
11. "Converge the plan on issue #42." on a plan whose `sweep-plan`
    pass raises an open question.
    Expect: the question lands in the ledger as a discuss item, and
    the round pauses under the blocked rule before it posts. The
    question counts as a verified build-changing discuss finding in
    the round's tallies.
12. "Converge the plan on issue #42." on a round that fires the churn
    rule for the first time.
    Expect: the consolidation pass writes a fresh draft from the live
    surface, runs `sweep-plan` under the style agenda over that
    draft's path on the same continuing sweep counter, reads the
    output file, composes `batch-consolidation-<k>.md`, and hands that
    path to `revise-plan`. The firing line in `ledger.md` carries that
    batch path. Claude applies no consolidation edit inline.

## promote-plan

1. "Promote the plan on issue #42 into the issue."
   Expect: the skill triggers. The plan becomes the issue body, whose
   first heading is `## Problem`. Whatever the old body carried that
   the plan does not state lands under a trailing `## Notes` section.
   Claude asks one question covering both the body write and the
   comment deletion, and asks nothing further before deleting.
2. "Move the plan comment into the issue body." on an issue whose
   body already carries a promoted plan.
   Expect: Claude replaces the whole body with the new plan, and
   carries the existing `## Notes` section's leftovers forward into
   the new body's `## Notes`.
3. "Promote this plan into issue #42." on a plan comment already
   nested under a level-two Plan header, whose own sections are `###`.
   Expect: Claude drops that header line and promotes the plan with
   `##` sections and `###` unit headers. No heading gains a level.
4. "Promote the plan on issue #42." on a plan whose Open questions
   section carries a bullet.
   Expect: Claude shows the open questions and asks whether to promote
   anyway. It proceeds only on a yes, and the report says the plan was
   promoted with open questions.
5. Negative: "Write a plan for issue #42."
   Expect: `promote-plan` does not trigger; `write-plan` does.

## install-writing-style

1. "Install the writing-style rule."
   Expect: the skill triggers, and `install-rule.sh` runs from
   `${CLAUDE_PLUGIN_ROOT}`. Claude adds or confirms the CLAUDE.md
   line. Claude verifies the result.
2. "Update my installed writing-style rule to the plugin's latest."
   Expect: on a diverged installed copy, Claude shows the diff and
   asks before re-running with `--force`.

## Follow-up

The heavier benchmark path remains open; see issue #2. That path runs
with-skill and baseline sessions and grades them with the
`skill-creator` plugin, installed by
`/plugin install skill-creator@claude-plugins-official`.
