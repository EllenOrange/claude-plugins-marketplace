---
name: sweep-style
description: Sweep a whole plan against the style authorities and emit the repairs as edit instructions. Use when a plan skill has a whole-plan style pass to turn into a list of targeted edits, and when the user asks to sweep a plan for style.
---

# sweep-style

Discover the style repairs a whole plan needs and emit them as
instructions. This skill writes nothing. `writing:revise-plan` applies
what this skill emits. Write all prose per the communication-style
rule. Use the installed copy at
`~/.claude/rules/communication-style.md` if present, else the plugin's
bundled copy at `${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

The sibling skill `writing:sweep-consequences` carries the
consequence agenda.

## Execution context

Every call runs in a fresh-context general-purpose subagent on the
Opus model, in every caller. The caller spawns that subagent, names
the model inline, and instructs it to load this skill. This section is
the owning statement of the model choice, and every spawn site cites
it.

A sweep run in the caller's accumulated context inherits the
assumptions that hid the sibling instances in the first place.

## Inputs

- **The plan text, by path.** Required. This skill sweeps the whole
  plan, so a plan text always exists when it runs.

## Output

A list of edit instructions. Each instruction names the plan section
it targets and the change to make there. This skill writes no file and
posts nothing.

An instruction may prescribe a restructuring move. `revise-plan` →
"The edit rules" owns those moves.

This skill emits instructions only and no questions. Waiver: the
behavior walk that raises a question runs only under the consequence
agenda, so this skill has nothing to route.
`sweep-consequences` → "Output" owns the routing of a sweep question.

## What each caller passes

- **`writing:converge-plan`** passes the consolidation pass's fresh
  draft by path.
- **`writing:write-plan`'s style-pipeline seat** passes the draft by
  path.

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
