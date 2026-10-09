---
name: revise-plan
description: Apply a batch of edit instructions to a plan file, style-sweep every unit the edits landed in, and report which instructions applied. Use when a plan skill has instructions to execute against a draft, and when the user asks to apply a set of edits to a plan without re-deciding them.
---

# revise-plan

Apply edit instructions to one plan file. This skill executes; it
discovers nothing. `writing:sweep-consequences` and
`writing:sweep-style` produce the instructions this skill applies.
Write all prose per the communication-style rule. Use
the installed copy at `~/.claude/rules/communication-style.md` if
present, else the plugin's bundled copy at
`${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

## Execution context

Every call runs in a fresh-context general-purpose subagent, in every
caller. The caller spawns that subagent and instructs it to load this
skill. The drift this skill exists to prevent is what the caller's
accumulated context produces.

## Inputs

- **The plan file.** Required. This skill edits that file in place and
  touches no other file. It never edits an issue surface.
- **The instruction files.** Required. One or more files in the format
  `sweep-consequences` → "Output" owns. Apply every instruction in
  every file.

A caller names each file by path, or by name under a state handle.
Reach a named file per `write-plan` → "Reach the state through the
script": print the plan file into the staging directory, edit the
staged copy, and put it back before you report.

## Boundaries

This skill performs no discovery, no finding verification, and no
acceptance-bar judgment. It does not decide whether an instruction is
worth applying. An instruction it cannot apply comes back unapplied
with the conflict named, and the caller decides what happens next.

This skill applies no instruction that names a `file:line`, a hunk
count, or a parameter position. `write-plan` → "Write for the
implementer" owns these forbidden forms. Such an instruction comes
back unapplied, with the conflict named.

## The style authorities

Apply these to every edit, cited rather than restated:

- the communication-style rule, resolved through this plugin's
  installed-else-bundled lookup above
- `writing:write-plan` → "5. Write"

## The edit rules

- A fix that adds a second action to a bullet splits the bullet.
- A fix that adds a third item to an inline series converts the series
  to a vertical list.

This section owns the restructuring moves. An instruction may
prescribe any of them, and the sweep skills cite this owner rather
than restating them:

- Split a unit.
- Regroup actions.
- Add or rename a header.

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
- every command an Acceptance bullet names

Confirm also that the text this skill wrote carries none of the
forbidden forms "Boundaries" names.

Read back only the units this skill edited. The rest of the plan is
the caller's, and this skill grades none of it.

An edit whose read-back finds changed meaning is reverted. Report it
unapplied, with the conflict named.

## Output

Report these lists:

- the instructions applied
- the instructions left unapplied, each with its conflict named

The revised file is the other output, at the path or under the name
the caller gave. Post nothing.

This section owns the unapplied-instruction resolution rule. The
caller resolves every instruction this skill reports unapplied, before
the caller's own next step. It does one of these:

- Amend the instruction and re-invoke this skill on the same draft.
- Return the conflict to the caller's own caller.

Each applying site cites this owner and adds only its seat-specific
disposition of a conflict that survives both moves.
