---
name: revise-plan
description: Apply a batch of edit instructions to a plan file, style-sweep every unit the edits landed in, and report which instructions applied. Use when a plan skill has instructions to execute against a draft, and when the user asks to apply a set of edits to a plan without re-deciding them.
---

# revise-plan

Apply edit instructions to one plan file. This skill executes; it
discovers nothing. `writing:sweep-plan` produces the instructions this
skill applies. Write all prose per the communication-style rule. Use
the installed copy at `~/.claude/rules/communication-style.md` if
present, else the plugin's bundled copy at
`${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

## Execution context

Every call runs in a fresh-context general-purpose subagent, in every
caller. The caller spawns that subagent and instructs it to load this
skill. The drift this skill exists to prevent is what the caller's
accumulated context produces.

## Inputs

- **The plan file path.** Required. This skill edits that file in
  place and touches no other file. It never edits an issue surface.
- **The instruction batch.** Required. Each instruction names the plan
  section it targets and the change to make there.

## Boundaries

This skill performs no discovery, no finding verification, and no
acceptance-bar judgment. It does not decide whether an instruction is
worth applying. An instruction it cannot apply comes back unapplied
with the conflict named, and the caller decides what happens next.

## The style authorities

Apply these to every edit, cited rather than restated:

- the communication-style rule, resolved through this plugin's
  installed-else-bundled lookup above
- `writing:write-plan` → "5. Write"

## The edit rules

- A fix that adds a second action to a bullet splits the bullet.
- A fix that adds a third item to an inline series converts the series
  to a vertical list.

## The sweep unit

A style sweep covers the whole unit or section each instruction landed
in, not the changed sentence alone. An instruction lands as a clause,
and the bullet around it carries the clauses every earlier instruction
left.

## The meaning-preservation read-back

After editing, read the result against the input. Confirm that each of
these survives with its meaning unchanged:

- every decision
- every obligation
- every membership rule
- every qualifier
- every `Check:` command

Read back only the units this skill edited. The rest of the plan is
the caller's, and this skill grades none of it.

An edit whose read-back finds changed meaning is reverted. Report it
unapplied, with the conflict named.

## Output

Report two lists:

- the instructions applied
- the instructions left unapplied, each with its conflict named

The revised file is the other output, on disk at the path the caller
gave. Post nothing.
