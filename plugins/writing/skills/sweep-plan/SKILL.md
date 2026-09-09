---
name: sweep-plan
description: Sweep a plan for the edits one change forces, or for the style repairs the whole plan needs, and emit them as edit instructions. Use when a plan skill has an accepted fix, a ratified ruling, or a whole-plan style pass to turn into a list of targeted edits, and when the user asks what a change to a plan drags with it.
---

# sweep-plan

Discover the edits a plan needs and emit them as instructions. This
skill writes nothing. `writing:revise-plan` applies what this skill
emits. Write all prose per the communication-style rule. Use the
installed copy at `~/.claude/rules/communication-style.md` if present,
else the plugin's bundled copy at
`${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

## Execution context

Every call runs in a fresh-context general-purpose subagent, in every
caller. The caller spawns that subagent and instructs it to load this
skill. A sweep run in the caller's accumulated context inherits the
assumptions that hid the sibling instances in the first place.

## Inputs

- **The agenda.** Required. It is one of:
  - **One change.** An accepted fix finding, or a ruling the user
    ratified.
  - **The style agenda.** The whole plan, swept against the style
    authorities.
- **The current plan text.** Optional, and passed whenever a plan text
  exists.
- **The ledger's rulings.** Optional, and passed whenever a ledger
  exists.

## Output

A list of edit instructions, plus any question a behavior walk left
unanswered. Each instruction names the plan section it targets and the
change to make there. This skill writes no file and posts nothing.

An unanswered question is never an instruction. The caller routes it:

- `writing:write-plan` routes it to the interview.
- `writing:converge-plan` routes it to the ledger as a discuss item.

## What each caller passes

- **`writing:converge-plan`** passes the round's plan text and the
  ledger's rulings.
- **`writing:write-plan`'s interview seat** passes the ruling and the
  interview's earlier rulings, with no plan text. Its instructions land
  when `write-plan` → "5. Write" drafts the file. In that seat an
  instruction targets the plan-to-be's sections by the fixed section
  names "5. Write" owns.

## The one-change agenda

Enumerate the change's cross-cutting consequences. Look for these
affected surfaces:

- verification commands
- doc files
- scripts
- sibling fields
- scope statements

Run `write-plan` → "Walk each stated behavior" over each behavior the
change alters, before any prose changes. Every answer lands in the
plan at one owning site. A question the walk leaves unanswered leaves
this skill as a question, per "Output".

When the change is a fix, enumerate every other instance of the same
defect class in the plan. Each instance becomes its own instruction.

Emit one instruction per consequence and per instance. A consequence
applied at one site and discovered at five others costs a critique
round per site.

## The style agenda

Sweep the whole plan against the communication-style rule and
`write-plan` → "5. Write". Emit an instruction for each repair the
sweep finds:

- Split a bullet that carries more than one action.
- Convert an inline series of three or more parallel items to a
  vertical list.
- Collapse a site-enumeration bullet into a class-level sweep action
  with a verify command.
- Apply the "Restatements" item from `write-plan`'s self-review.
- Rewrite a mechanism paragraph that restates a sibling contract, per
  the mechanism-restatement reading `write-plan` → "5. Write" owns.

Sweep the whole plan, not the units a prior round touched. Drift
accumulates wherever the loop has edited, and the loop does not record
where that was.
