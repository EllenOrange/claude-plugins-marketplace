# claude-plugins-marketplace

Personal Claude Code plugin marketplace (`ellenorange`). Plugins live
under `plugins/<name>/` with a `.claude-plugin/plugin.json` manifest
and skills under `skills/<name>/SKILL.md`.

## Releasing plugin changes

Bump the plugin's `version` in `.claude-plugin/plugin.json` in the
same PR as any change to the plugin's skills, rules, or scripts.
Installed plugins cache by version
(`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`), so a
content change without a version bump can leave installed copies
serving the old cached files after the marketplace updates.

## Markdown

Every Markdown file must pass `npx markdownlint-cli2 <file>` with zero
errors before commit.
