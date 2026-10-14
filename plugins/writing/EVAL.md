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
   prose restatement after the list. Each finding carries a plain
   sentence on why it matters, and names only the identifiers the
   reader needs.
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
   Expect: the skill triggers on the Fable model. Claude reads the
   doc, project docs, and touched code. The output opens with the
   number of claims the plan makes, then gives one prioritized list in
   the summarize-findings format. Claude does not rewrite the plan.
2. "Here's my migration plan, poke holes in it." with the plan pasted
   inline.
   Expect: the skill triggers on inline text, not only on files.
   Expect the problem check to run first, including the test for a
   problem that presupposes its design.
3. "Critique this plan. It builds on the branch in PR #77."
   Expect: Claude verifies every claim about the repo
   at that branch's ref, not at main. Each finding names the file and
   ref Claude verified it against.
4. "Critique this plan." on a plan that prescribes an AWS SDK call
   pattern with no source behind it.
   Expect: a finding that flags the unsourced external usage. Claude
   checks the plan's stated usage against the docs for the targeted
   version, not from recollection.
5. "Critique this plan." on a plan whose Design section carries a
   sentence telling the implementer which line to add.
   Expect: a finding that the sentence instructs an edit.
6. "Critique this plan." on a `writing:write-plan` plan whose Design
   is paragraphs, each opening with a bold phrase.
   Expect: a finding that the Design is not one summary paragraph
   followed by a bullet list of decisions and outcomes.
7. "Critique this plan." on a plan that states three facts about a
   file that the file contradicts.
   Expect: one finding that lists all three claims as members of one
   class. Its proposed solution deletes or generalises each claim
   and elaborates none.
8. "Critique this plan." on a repo with the sdlc plugin installed.
   Expect: Claude reads `docs/review-sources.md` and the installed
   `sdlc:theorem-generation` skill, and asks each source's question of
   the plan and of the implementation it describes.
9. "Critique this plan." on a repo with no sdlc plugin installed.
   Expect: Claude asks the questions in `docs/review-sources.md` as
   written, reports no error, and invents no rule. The report says the
   readiness-bar grading was skipped.
10. "Critique this plan." on a repo with the sdlc plugin installed, on
    a plan with no Acceptance section.
    Expect: a `readiness-failure` finding whose provenance names the
    bar item that requires an `## Acceptance` section.
11. "Critique this plan." on a plan that binds an obligation to a list
    of call sites smaller than the set the code holds.
    Expect: a finding that prescribes stating the rule that generates
    the set, not adding the missing member.
12. Negative: "Critique the naming in this function."
    Expect: the skill does not trigger; it is scoped to plans and
    specs.
13. "Critique this plan." on a `writing:write-plan` plan whose Design
    carries "The bump is the catalog edit plus `pnpm install`" and
    "`PlayPage.tsx` renders the hook's balance in place of the account
    read it holds today".
    Expect: one finding that lists both sentences as instructions. The
    first names a step, and the second compares against today's code.
14. "Critique this plan." on a `writing:write-plan` plan whose Design
    names helper functions, their signatures, the module each sits in,
    and the order they are called.
    Expect: a finding that the Design pins choices that are the
    implementer's, listing every such sentence.

## write-plan

1. "Plan the work for issue #42."
   Expect: the skill triggers on the Opus model. Claude reads the
   issue and touched code, and interviews before writing. Claude
   posts the plan as an issue comment and reports the comment URL.
2. "Spec out how we'd add rate limiting (ticket PROJ-17)."
   Expect: the skill triggers on non-GitHub ticket phrasing and uses
   installed issue skills when present.
3. Negative: "What's your plan for fixing this failing test?"
   Expect: the skill does not trigger for an inline fix, and Claude
   posts no issue comment.
4. "Plan the work for issue #42."
   Expect: the posted plan carries these sections, in order, and no
   other:
   - Problem
   - Design
   - Acceptance, with `### Mechanical` and `### Semantic`
   - Files affected (floor)

   Every Mechanical bullet opens with a check key. No question is left
   open.
5. "Plan the work for issue #42."
   Expect: every Design sentence is a decision or an outcome, and each
   is true of the merged tree read without the diff. No Design sentence
   names a step or compares against today's code. No Design sentence
   names an internal function, a helper's signature, a module layout,
   or a call order. Every claim about existing code states the behavior
   in plain prose, quotes no code as evidence, and names each path in
   backticks. The Design is one summary paragraph followed by a bullet
   list of decisions and outcomes.
6. "Plan the work for issue #42." on an issue that builds on a
   component sitting on an unmerged branch.
   Expect: Claude reads that component at the branch ref, and turns
   each gap into an interview question.
7. "Plan the work for issue #42." on an issue whose work calls an
   external SDK.
   Expect: Claude reads the SDK docs before it settles how the work
   uses the SDK.
8. "Plan the work for issue #42."
   Expect: the Propose step shows the problem. It shows candidate
   designs only when there is a real choice between them, and then
   stops for the user's pick. It then shows a draft of the plan's
   Design section, written to `docs/plan-style.md` and within its
   Design length limit, and never a sketch of it in its place.
   It stops for confirmation and drafts nothing else until the user
   confirms. It then derives the criteria from the confirmed Design
   and stops for correction. The posted plan carries the Design the
   user confirmed.
9. "Plan the work for issue #42." on a machine with no sdlc plugin
   installed.
   Expect: Claude proceeds with no error. The report says the
   readiness-bar grading was skipped.
10. "Plan the work for issue #42." with a human-review change
    requested after the draft is shown.
    Expect: Claude fixes every other sentence the change makes wrong
    in the same edit, runs the self-review again, and shows the
    result. Claude writes no state that another skill reads.
11. "Plan the work for issue #42." on an issue whose plan would run
    long.
    Expect: the plan and its Design each stay within the word limits
    in `docs/plan-style.md` before the user sees them. Claude cuts
    whole details to meet a limit, and leaves no sentence a fragment.

## converge-plan

1. "Converge the plan on issue #42."
   Expect: the skill triggers and runs one round. One fresh-context
   critic on the Fable model reads the plan once. Claude verifies its
   findings and applies the accepted ones in one in-place edit of the
   located surface. The
   report gives how many claims the critic read, refuted, fixed, and
   rejected, and offers no further round.
2. "Run the critique loop on issue #42." on an issue whose body
   already carries a promoted plan.
   Expect: the round edits the whole body in place, once. Nothing
   moves the plan back into a comment.
3. "Converge the plan on issue #42." on a round whose accepted finding
   names one instance of a defect the plan repeats elsewhere.
   Expect: Claude sweeps the plan for every instance and fixes all of
   them in the one edit.
4. "Converge the plan on issue #42." on a round that refutes a claim.
   Expect: Claude deletes the claim or generalises it, and never
   elaborates it.
5. "Converge the plan on issue #42." on an issue whose plan is
   promoted and that an open pull request carries.
   Expect: the round stops before it edits the body and reports why.
   The body stays unchanged.
6. "Converge the plan on issue #42." on a round whose verified
   findings mix clear fixes, a design call, and a length reading.
   Expect: each finding states what is wrong, why it matters, and the
   fix, never a bare title. The clear fixes arrive as one numbered
   batch, applied unless the user vetoes one by number. The design call
   comes alone, after the batch, with two to four options and a
   recommendation, and Claude waits for its answer. The length reading
   sits in one closing line, outside the list.
7. "Converge the plan on issue #42." on a round whose critic proposes
   a fix as an implementation step, and another as a file placement.
   Expect: Claude recasts each proposed fix as the decision or outcome
   the plan carries before it shows the fix. No proposed fix names a
   step, a file placement, or an internal name.
8. "Converge the plan on issue #42." on a round with a finding that
   offers two fixes, of which only one fits a decision the plan
   already makes.
   Expect: the finding arrives in the obvious-fix batch with that fix,
   not as a decision.
9. Negative: "Critique the plan on issue #42."
   Expect: `converge-plan` does not trigger; `critique-plan` does,
   and it runs once with no fixes applied.

## promote-plan

1. "Promote the plan on issue #42 into the issue."
   Expect: the skill triggers. The plan becomes the whole issue body,
   whose first heading is `## Problem`, and Claude authors no section
   of its own. Claude asks one question covering both the body write
   and the comment deletion, and asks nothing further before deleting.
   The report gives the verdict of `/sdlc:orchestrate-readiness <N>`.
2. "Move the plan comment into the issue body." on an issue whose
   body already carries a promoted plan.
   Expect: Claude replaces the whole body with the new plan, and
   carries nothing of the old body forward.
3. "Promote this plan into issue #42." on a plan comment already
   nested under a level-two Plan header, whose own sections are `###`.
   Expect: Claude drops that header line and promotes the plan with
   `##` sections. No heading gains a level.
4. "Promote the plan on issue #42." on a repo with the sdlc plugin
   installed, on a plan whose Acceptance section has no bullet.
   Expect: Claude grades the plan against the installed
   `sdlc:orchestrate-readiness` bar before it writes anything. It
   shows the gaps and asks whether to promote anyway, and it proceeds
   only on a yes.
5. Negative: "Write a plan for issue #42."
   Expect: `promote-plan` does not trigger; `write-plan` does.

## Follow-up

The heavier benchmark path remains open; see issue #2. That path runs
with-skill and baseline sessions and grades them with the
`skill-creator` plugin, installed by
`/plugin install skill-creator@claude-plugins-official`.
