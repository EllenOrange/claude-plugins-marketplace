# The review's sources

This file holds, for each source the review that grades the
implementation works, the question a critic asks of a plan and the
finding a failing answer yields. It defines no source. The sections
below follow the order the review works the sources in.

## The review reads the body

The review reads each issue it grades through the issue view, which
carries the issue body and its fields and no comment. The body is the
only plan text the review sees. A plan that lives only in a comment
reaches no review round.

## Acceptance criteria

Ask of the plan: does every Acceptance bullet state one claim the
review can quote verbatim and a disprover can refute against the diff?

A failing answer yields: a criterion the review cannot grade, which
fails the Acceptance item of the readiness bar.

## PR-body claims

Ask of the plan: can the implementer verify every claim the plan
obliges the PR body to carry?

A failing answer yields: a claim the implementer must assert without
evidence. A claim that names no command and no read is one.

## Codebase consistency

Ask of the plan, for every fact it changes that the repo restates in
code or instruction Markdown: does the plan carry an outcome or a
criterion that no restatement of the old fact survives?

A failing answer yields: a changed fact whose restatements the plan
leaves to go stale.

## Design shape

Ask of the plan: does it settle where the change sits, which file owns
each fact it adds, and where its work ends and a neighboring issue's
begins?

A failing answer yields one of these findings:

- Placement that contradicts where the codebase keeps that kind of
  logic.
- A second source of truth.
- A convention with no file that owns it.
- Work that belongs to a neighboring issue.
