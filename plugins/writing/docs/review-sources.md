# The review's sources

This file mirrors the sources section of `sdlc:theorem-generation`. A
change there is re-synced here by hand.

The skills in this plugin cite this file for the resolution order, the
locator command, the per-source question a critic asks of a plan, the
finding a failing answer yields, the style-guide fallback order, and
the bar a criterion must clear. They restate none of those facts.

On a repo that runs the sdlc plugin, the review that grades the
implementation is the theorem pipeline. It works the sources below in
order. The first source is exempt from the pipeline's stakes bar, it
carries a High severity floor, and its theorems are re-attacked every
round. So the plan's acceptance criteria are the only plan text
that survives into every review round.

## Resolution order

The installed sdlc skill a citation names is the authority for the
cited fact when it is present. This file's own summary of that fact is
the fallback. Read the installed skill first, and select the fallback
silently when the locator returns nothing or the file is absent.

The per-source questions below are this file's own. They are read in
both cases.

### The facts this plugin cites from sdlc

The membership rule: every `sdlc:` citation in this file and under
`plugins/writing/skills`. Known members:

- **What each theorem source means, and the emission bar**, from
  `sdlc:theorem-generation`. Fallback: the source sections and "The
  bar a criterion clears" below.
- **The decision set an issue must settle**, from
  `sdlc:orchestrate-ready` → "The readiness bar". Fallback: "The
  decision set" below.
- **That the pipeline reads each member issue through `/issue-view`**,
  from `sdlc:theorem-generation` → "Workflow". Fallback: "The pipeline
  reads the body" below, which is also where the body-only read this
  plugin builds on that fact is stated and justified as this file's
  own claim.
- **That a criterion theorem is re-attacked every round, and that a
  disposition contradicting the carried record is a declared
  reversal**, from `sdlc:theorem-based-pr-reviewer` → "Declare a
  reversed criterion verdict". Fallback: the same two facts, stated
  here. Moving a criterion under review is one way to make this
  round's disposition contradict the carried record, which is why the
  loop guards a body surface.
- **Who reads the plan**, from `sdlc:issue-developer`. Fallback: the
  reader is an implementation agent or the engineer in that seat.
- **When grooming runs**, from `sdlc:orchestrate-ready`. Fallback:
  grooming is the last step before orchestration, and it reads the
  issue body it rewrites.

### The locator

The locator takes a plugin name and an optional record path. The path
defaults to the harness's install record at
`~/.claude/plugins/installed_plugins.json`:

```bash
jq -r --arg p "<plugin>@" '.plugins | to_entries[] | select(.key | startswith($p)) | .value[0].installPath' <record> | head -n 1
```

The first line wins when more than one marketplace carries the plugin.

The `.value[0].installPath` shape was read against the install
record's own `version` field, which reads `2`. The sibling reader of
the same file is `cc-tools:cc-suggest-topics` → "What it reads".

The sdlc resolution calls the locator with `sdlc` and reads
`<installPath>/skills/theorem-generation/SKILL.md`. An empty result or
a missing file selects the fallback silently. The heading sweep calls
the locator with the plugin a citation names.

## The pipeline reads the body

The pipeline reads each member issue through `/issue-view`. The output
block that `issues:issue-view` → "Output" enumerates carries the issue
body and its fields, and no comment. So the body is the only plan text
the review sees, and whatever in it reads as a criterion is what the
review quotes and grades. No installed skill states that conjunction,
so it is this file's own claim. Check it by reading the two sections
named here.

## The decision set

An issue is ready for orchestration when nothing in it can trigger the
implementer's stop on a design decision the issue does not answer. The
decisions the issue settles in its body:

- Naming.
- Placement in the tree.
- Load mode.
- The fate of content the change subsumes.
- Any structural contract a downstream consumer depends on.

This plugin adds one more: the authority site of any convention, name,
or class the solution introduces.

## The bar a criterion clears

A criterion is falsifiable by a quote from the tree or from a
command's output, and its failure is under-delivery. This is the
emission bar in `sdlc:theorem-generation` → "The emission bar:
falsifiability, then stakes", applied to a plan. An acceptance
criterion clears the stakes half by construction, because the issue
asked for it.

## 1. Acceptance criteria

Mirrors `sdlc:theorem-generation` → "1. Acceptance criteria". Every
criterion of every member issue becomes one theorem, quoted verbatim.

Ask of the plan: does every criterion state a claim the review can
quote and a disprover can refute?

The findings a failing answer yields:

- The plan carries no Acceptance criteria section.
- A criterion is an action, an implementation step, or an exemplar to
  imitate.
- A criterion binds an obligation to a set and states no membership
  rule.
- A criterion carries no `Check:` clause.
- A criterion carries neither a `Pinned by:` clause nor a `Waiver:`
  clause.
- The Outline touches an existing contract and the Invariants
  subsection carries no invariant or waiver naming it.

## 2. PR-body claims

Mirrors `sdlc:theorem-generation` → "2. PR-body claims". Every
load-bearing claim the developer writes into the PR body becomes a
theorem to disprove.

Ask of the plan: can the implementer verify every claim the plan
obliges the PR body to carry?

The finding a failing answer yields: a waiver the implementer cannot
verify. A waiver that names no command and no read hands the
implementer a claim it must assert without evidence.

## 3. Codebase consistency

Mirrors `sdlc:theorem-generation` → "3. Codebase consistency". For
every interface, contract, name, file path, config key, or convention
the diff touches, the review claims that no other consumer or
restatement in the repo still assumes the old behavior.

A **sweep section** is a section that names a fact and the surfaces
that restate it. The sweep-carrying files are the ones
`sdlc:theorem-generation` → "Read global rules first" reads:

- The repo's own `CLAUDE.md` from the worktree root.
- Every on-demand file that `CLAUDE.md` indexes whose trigger the
  change hits.
- The README of every plugin the change touches.

A sweep section warrants a theorem only when the change alters the
fact the section says is mirrored. Touching a file the section names
is not the trigger.

Ask of the plan: for every mirrored fact the plan changes, does Scope
name the surfaces that restate it, and does the Outline carry one
class-level sweep action with a grep-shaped verify command?

The finding a failing answer yields: a mirrored fact the plan changes
whose restating surfaces Scope omits.

## 4. Design shape

Mirrors `sdlc:theorem-generation` → "4. Design shape". The review
claims that the change sits where the codebase already puts this kind
of logic, that it creates no second source of truth, and that it stays
within the union of the member issues' scopes.

Ask of the plan: does the plan settle placement, ownership, and
boundary against its neighbors?

The findings a failing answer yields:

- Placement that contradicts where the codebase keeps that kind of
  logic.
- A second source of truth.
- A convention with no authority site.
- Work that belongs to a neighboring issue.

## 5. Style guides

Mirrors `sdlc:theorem-generation` → "5. Style guides". A style rule
maps to a theorem with no rewriting.

The guides the pipeline reads are the global ones, at
`~/.claude/docs/rules/code-style.md` and
`~/.claude/docs/rules/documentation-style.md`. The installed skill's
list governs when the skill is present. Each guide names its own
Structure contract and its per-repo extension file, and the critic
reads what the guide names.

Ask of the plan: does every outline action satisfy every rule of every
guide it engages?

The finding a failing answer yields: an outline action that violates a
rule heading.

### The fallback per guide

- **The documentation guide.** It falls back to the
  communication-style rule, read through this plugin's existing
  lookup: the installed copy at `~/.claude/rules/communication-style.md`
  if present, else the bundled copy at
  `${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`. Read as rules,
  each `##` section from "Kernel: the inverted pyramid" through
  "Audience calibration" is one rule. The sections before and after
  them are not rules. Waiver: this fallback checks what the review
  does not. Every plan this plugin writes is written under the
  communication-style rule, so a violation is a defect whether or not
  the review catches it.
- **The code guide.** An absent file yields no check. Waiver: the
  plugin ships no backup of the code guide, because a third copy of a
  global file drifts.

Never reconstruct a style rule from memory when its file is absent.
