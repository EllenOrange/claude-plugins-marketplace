#!/usr/bin/env bash
#
# writing-test.sh -- drive plugins/writing/bin/writing-plan-state against
# a state root of its own: the directory each skill and issue composes
# under XDG_STATE_HOME, every mode, the append-only evidence log, the
# seed from write-plan's state into converge-plan's, the ledger's guard
# on repo-derived rulings and the seed's reopening of one, and each
# refusal of a repository, a skill, an issue, a file name or a payload,
# and the exit status of each read or write the filesystem refuses.
#
# Needs bash and the POSIX utilities. Reaches no network.
#
# Usage: writing-test.sh    (exit 0 when every case passes)

set -uo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$TEST_DIR/../bin/writing-plan-state"
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/writing-test.XXXXXX")"
trap 'rm -rf "$SANDBOX"' EXIT
FAILURES=0

# check <actual> <expected> <label>: prints PASS when the two are equal,
# and otherwise prints both and counts a failure.
check() {
  if [ "$1" = "$2" ]; then
    echo "PASS  $3"
  else
    echo "FAIL  $3"
    echo "      expected: $2"
    echo "      actual:   $1"
    FAILURES=$((FAILURES + 1))
  fi
}

# check_contains <actual> <needle> <label>: as check, but passes when
# <actual> holds <needle> anywhere.
check_contains() {
  case "$1" in
    *"$2"*) echo "PASS  $3" ;;
    *)
      echo "FAIL  $3"
      echo "      expected to contain: $2"
      echo "      actual:              $1"
      FAILURES=$((FAILURES + 1))
      ;;
  esac
}

# new_case <name>: starts the case <name> with a state root and a
# staging directory of its own, so no case reads a file another one
# wrote.
new_case() {
  CASE="$SANDBOX/$1"
  mkdir -p "$CASE/state" "$CASE/stage"
  export XDG_STATE_HOME="$CASE/state"
}

# state <skill> <args...>: runs the script for issue 42 of h.example/o/r,
# leaving the exit status in RC, stdout in OUT and stderr in ERR.
state() {
  skill=$1
  shift
  OUT=$("$STATE" --repo h.example/o/r --skill "$skill" --issue 42 "$@" 2>"$CASE/err" </dev/null)
  RC=$?
  ERR=$(cat "$CASE/err")
}

# state_planted <kind> <target> <skill> <args...>: runs the script as
# state does, after planting at the staging path the run composes for
# <target> an empty directory when <kind> is dir. When <kind> is
# locked-file it plants an empty file there instead and then makes
# <target>'s directory read-only.
# The script is exec'd from the shell that plants, so it runs under the
# PID the staging path names. A plant that fails exits 99.
state_planted() {
  kind=$1
  target=$2
  skill=$3
  shift 3
  OUT=$(bash -c '
    case "$1" in
      dir) mkdir -- "$2.partial-$$" || exit 99 ;;
      locked-file) { : >"$2.partial-$$" && chmod 555 "${2%/*}"; } || exit 99 ;;
    esac
    shift 2
    exec "$@"
  ' _ "$kind" "$target" "$STATE" --repo h.example/o/r --skill "$skill" --issue 42 "$@" \
    2>"$CASE/err" </dev/null)
  RC=$?
  ERR=$(cat "$CASE/err")
}

# dir_of <skill>: prints the directory the script composes for <skill>
# on issue 42 of h.example/o/r under the current case's state root.
dir_of() {
  printf '%s\n' "$XDG_STATE_HOME/writing/h.example/o/r/$1-42"
}

# stage <name> <text>: writes <text> and a newline to <name> in the
# current case's staging directory, for a --from to name.
stage() {
  printf '%s\n' "$2" >"$CASE/stage/$1"
}

# --- the composed directory --------------------------------------------

new_case init
state write-plan --mode init
check "$RC" "0" "init: exit 0"
check "$([ -d "$(dir_of write-plan)" ] && echo made || echo absent)" "made" \
  "init: the directory sits under XDG_STATE_HOME/writing/<host>/<owner>/<repo>/<skill>-<issue>"
check "$([ -f "$(dir_of write-plan)/evidence.md" ] && [ ! -s "$(dir_of write-plan)/evidence.md" ] && echo empty || echo other)" \
  "empty" "init: evidence.md starts empty"
stage rec "a record"
state write-plan --mode append --file evidence.md --from "$CASE/stage/rec"
state write-plan --mode init
check "$(cat "$(dir_of write-plan)/evidence.md")" "a record" "init: a second init keeps the evidence log"

new_case url
OUT=$("$STATE" --repo https://h.example/o/r/ --skill converge-plan --issue 7 --mode init 2>&1)
check "$?:$OUT" "0:" "url: the form gh repo view prints is accepted"
check "$([ -d "$XDG_STATE_HOME/writing/h.example/o/r/converge-plan-7" ] && echo made || echo absent)" "made" \
  "url: it composes the same directory as <host>/<owner>/<repo>"

new_case default-root
OUT=$(unset XDG_STATE_HOME; HOME="$CASE/home" "$STATE" --repo h.example/o/r --skill write-plan --issue 42 --mode init 2>&1)
check "$?:$OUT" "0:" "default root: exit 0 with XDG_STATE_HOME unset"
check "$([ -d "$CASE/home/.local/state/writing/h.example/o/r/write-plan-42" ] && echo made || echo absent)" "made" \
  "default root: the state falls back to \$HOME/.local/state"

# --- put, print, append, list -------------------------------------------

new_case put-print
stage draft.md "first draft"
state write-plan --mode put --file draft.md --from "$CASE/stage/draft.md"
check "$RC" "0" "put: exit 0"
state write-plan --mode print --file draft.md
check "$RC:$OUT" "0:first draft" "print: returns the stored file"
stage draft.md "second draft"
state write-plan --mode put --file draft.md --from "$CASE/stage/draft.md"
state write-plan --mode print --file draft.md
check "$OUT" "second draft" "put: replaces the file whole"
check "$(ls -a "$(dir_of write-plan)" | grep -c partial)" "0" "put: leaves no staging file behind"
: >"$CASE/stage/empty.md"
state write-plan --mode put --file core-batch.md --from "$CASE/stage/empty.md"
check "$RC" "0" "put: an empty instruction file is stored"
state write-plan --mode print --file ledger.md
check "$RC" "3" "print: a file the directory lacks exits 3"
check_contains "$ERR" "write-plan-42 holds no ledger.md" "print: the refusal names the file"

new_case append
stage r1 "record one"
stage r2 "record two"
state converge-plan --mode append --file evidence.md --from "$CASE/stage/r1"
state converge-plan --mode append --file evidence.md --from "$CASE/stage/r2"
state converge-plan --mode print --file evidence.md
check "$OUT" "record one
record two" "append: records land after the ones before them"
stage e "replacement"
state converge-plan --mode put --file evidence.md --from "$CASE/stage/e"
check "$RC" "2" "append: evidence.md is never replaced by put"
state converge-plan --mode print --file evidence.md
check "$OUT" "record one
record two" "append: a refused put leaves the log as it was"
: >"$CASE/stage/none"
state converge-plan --mode append --file evidence.md --from "$CASE/stage/none"
check "$RC" "2" "append: an empty payload is refused"

new_case list
state converge-plan --mode list
check "$RC:$OUT" "0:" "list: a directory not yet made lists nothing"
state converge-plan --mode init
stage s "snapshot"
state converge-plan --mode put --file snapshot-1.md --from "$CASE/stage/s"
state converge-plan --mode put --file batch-1.md --from "$CASE/stage/s"
state converge-plan --mode list
check "$OUT" "batch-1.md
evidence.md
snapshot-1.md" "list: names every file, one per line"

# --- seed ----------------------------------------------------------------

new_case seed
state converge-plan --mode seed
check "$RC" "3" "seed: no write-plan state exits 3"
check "$([ -e "$(dir_of converge-plan)" ] && echo made || echo absent)" "absent" \
  "seed: nothing to seed creates no directory"
stage ledger.md "the ledger"
stage rec "the record"
stage draft.md "the draft"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
state write-plan --mode append --file evidence.md --from "$CASE/stage/rec"
state write-plan --mode put --file draft.md --from "$CASE/stage/draft.md"
state converge-plan --mode seed
check "$RC" "0" "seed: exit 0"
state converge-plan --mode print --file ledger.md
check "$OUT" "the ledger" "seed: copies the ledger"
state converge-plan --mode print --file evidence.md
check "$OUT" "the record" "seed: copies the evidence log"
state converge-plan --mode print --file draft.md
check "$RC" "3" "seed: copies no draft"
stage more "a later record"
state converge-plan --mode append --file evidence.md --from "$CASE/stage/more"
state write-plan --mode print --file evidence.md
check "$OUT" "the record" "seed: a later append lands in the copy alone"
state converge-plan --mode seed
check "$RC" "2" "seed: a converge-plan ledger already present is refused"
state write-plan --mode seed
check "$RC" "2" "seed: --skill write-plan is refused"

new_case seed-over-records
stage ledger.md "the ledger"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
stage rec "a converge record"
state converge-plan --mode append --file evidence.md --from "$CASE/stage/rec"
state converge-plan --mode seed
check "$RC" "2" "seed: converge-plan evidence records already present are refused"
state converge-plan --mode print --file evidence.md
check "$OUT" "a converge record" "seed: a refused seed leaves the records as they were"

new_case seed-after-init
stage ledger.md "the ledger"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
state converge-plan --mode init
state converge-plan --mode seed
check "$RC" "0" "seed: an empty evidence log left by init does not block the seed"

# A seed killed between its two renames leaves write-plan's evidence.md
# copied and no ledger.md, and one killed mid-stage leaves a staging file.
new_case seed-interrupted
stage ledger.md "the ledger"
stage rec "the record"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
state write-plan --mode append --file evidence.md --from "$CASE/stage/rec"
mkdir -p "$(dir_of converge-plan)"
cp "$(dir_of write-plan)/evidence.md" "$(dir_of converge-plan)/evidence.md"
printf 'half a led' >"$(dir_of converge-plan)/ledger.md.partial-99999"
stage more "a later write-plan record"
state write-plan --mode append --file evidence.md --from "$CASE/stage/more"
state converge-plan --mode seed
check "$RC" "0" "seed: an interrupted seed's leftovers do not block a later seed"
state converge-plan --mode print --file evidence.md
check "$OUT" "the record
a later write-plan record" "seed: the later seed copies write-plan's current evidence log"
state converge-plan --mode print --file ledger.md
check "$OUT" "the ledger" "seed: the later seed lands the ledger"
state converge-plan --mode list
check "$OUT" "evidence.md
ledger.md" "seed: an interrupted seed's staging file is no file of the state"
check "$(ls -A "$(dir_of converge-plan)")" "evidence.md
ledger.md
ledger.md.partial-99999" "seed: the later seed leaves an interrupted seed's staging file in place"
check "$(cat "$(dir_of converge-plan)/ledger.md.partial-99999")" "half a led" \
  "seed: the later seed does not write to an interrupted seed's staging file"

# A seed that fails to stage leaves nothing a later seed is refused on.
new_case seed-failed
stage ledger.md "the ledger"
stage rec "the record"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
state write-plan --mode append --file evidence.md --from "$CASE/stage/rec"
mkdir -p "$(dir_of converge-plan)"
chmod 555 "$(dir_of converge-plan)"
state converge-plan --mode seed
check "$RC" "2" "seed: a seed that cannot stage exits 2"
chmod 755 "$(dir_of converge-plan)"
check "$(ls -A "$(dir_of converge-plan)")" "" "seed: a failed seed leaves no file behind"
state converge-plan --mode seed
check "$RC" "0" "seed: a failed seed does not block a later seed"
state converge-plan --mode print --file ledger.md
check "$OUT" "the ledger" "seed: the seed after a failure lands the ledger"

# --- a write that cannot stage -------------------------------------------

# A put whose rename into place fails exits 2, as a failed copy does, and
# removes its staging file.
new_case put-rename-fails
stage draft.md "the draft"
mkdir -p "$(dir_of write-plan)/draft.md"
chmod 555 "$(dir_of write-plan)/draft.md"
state write-plan --mode put --file draft.md --from "$CASE/stage/draft.md"
check "$RC" "2" "stage: a put whose rename fails exits 2"
chmod 755 "$(dir_of write-plan)/draft.md"
check "$(ls -A "$(dir_of write-plan)" | grep -c partial)" "0" \
  "stage: a put whose rename fails leaves no staging file behind"

# A seed whose ledger rename fails exits 2, and keeps that status when the
# EXIT trap cannot remove the staging file either. The planted staging
# file and the evidence.md init leaves let the seed write with its
# directory read-only, so only the rename and the removal fail.
new_case seed-rename-fails
stage ledger.md "the ledger"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
state converge-plan --mode init
state_planted locked-file "$(dir_of converge-plan)/ledger.md" converge-plan --mode seed
chmod 755 "$(dir_of converge-plan)"
check "$RC" "2" "stage: a seed whose ledger rename and staging removal fail exits 2"
check_contains "$ERR" "could not remove staging file $(dir_of converge-plan)/ledger.md.partial-" \
  "stage: a seed whose staging removal fails names the staging file"
check "$([ -e "$(dir_of converge-plan)/ledger.md" ] && echo landed || echo absent)" "absent" \
  "stage: a seed whose ledger rename fails lands no ledger.md"

# A staging path the EXIT trap cannot remove does not replace the
# refusal's 2 with the removal's status.
new_case seed-staging-unremovable
stage ledger.md "the ledger"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
mkdir -p "$(dir_of converge-plan)"
state_planted dir "$(dir_of converge-plan)/ledger.md" converge-plan --mode seed
check "$RC" "2" "stage: a seed that can neither stage nor remove its staging path exits 2"
check_contains "$ERR" "could not stage" "stage: a seed that cannot stage says so"
check_contains "$ERR" "could not remove staging file" \
  "stage: a seed that cannot remove its staging path says so"

# --- a write the filesystem refuses ---------------------------------------

# A regular file where the composed directory belongs fails the mkdir of
# every mode that makes the directory, and each exits 2.
new_case mkdir-fails
stage x "x"
stage ledger.md "the ledger"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
mkdir -p "$(dirname "$(dir_of converge-plan)")"
: >"$(dir_of converge-plan)"
state converge-plan --mode init
check "$RC" "2" "filesystem: an init that cannot make its directory exits 2"
state converge-plan --mode put --file draft.md --from "$CASE/stage/x"
check "$RC" "2" "filesystem: a put that cannot make its directory exits 2"
state converge-plan --mode append --file evidence.md --from "$CASE/stage/x"
check "$RC" "2" "filesystem: an append that cannot make its directory exits 2"
state converge-plan --mode seed
check "$RC" "2" "filesystem: a seed that cannot make its directory exits 2"
check_contains "$ERR" "could not make" "filesystem: a failed mkdir says so"

# A read-only directory with no evidence.md fails the empty log init and
# seed would create, and each exits 2.
new_case evidence-create-fails
mkdir -p "$(dir_of write-plan)" "$(dir_of converge-plan)"
stage ledger.md "the ledger"
cp "$CASE/stage/ledger.md" "$(dir_of write-plan)/ledger.md"
chmod 555 "$(dir_of converge-plan)"
state converge-plan --mode init
check "$RC" "2" "filesystem: an init that cannot create evidence.md exits 2"
state converge-plan --mode seed
check "$RC" "2" "filesystem: a seed that cannot create evidence.md exits 2"
chmod 755 "$(dir_of converge-plan)"
check "$(ls -A "$(dir_of converge-plan)")" "" "filesystem: a seed that cannot create evidence.md leaves no file"

# An append whose target cannot be written exits 2.
new_case append-fails
stage rec "a record"
mkdir -p "$(dir_of write-plan)/notes.md"
state write-plan --mode append --file notes.md --from "$CASE/stage/rec"
check "$RC" "2" "filesystem: an append that cannot write its target exits 2"
check_contains "$ERR" "could not append" "filesystem: a failed append says so"

# A print whose file cannot be read exits 2.
new_case print-fails
stage draft.md "the draft"
state write-plan --mode put --file draft.md --from "$CASE/stage/draft.md"
chmod 000 "$(dir_of write-plan)/draft.md"
state write-plan --mode print --file draft.md
chmod 644 "$(dir_of write-plan)/draft.md"
check "$RC" "2" "filesystem: a print that cannot read its file exits 2"
check_contains "$ERR" "could not print" "filesystem: a failed print says so"

# A ledger the guard cannot read refuses the write rather than pass it.
new_case ledger-unreadable
stage ledger.md "- Which retry count? [Discuss]"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
chmod 000 "$(dir_of write-plan)/ledger.md"
state write-plan --mode append --file ledger.md --from "$CASE/stage/ledger.md"
check "$RC" "2" "filesystem: an append whose ledger cannot be read exits 2"
state converge-plan --mode seed
check "$RC" "2" "filesystem: a seed whose source ledger cannot be read exits 2"
chmod 644 "$(dir_of write-plan)/ledger.md"
check_contains "$ERR" "could not read" "filesystem: an unreadable ledger is named"

# A seed that cannot read write-plan's ledger is refused before
# evidence.md lands, so it leaves no copy of the evidence log behind.
new_case seed-ledger-unreadable
stage ledger.md "the ledger"
stage rec "the record"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
state write-plan --mode append --file evidence.md --from "$CASE/stage/rec"
chmod 000 "$(dir_of write-plan)/ledger.md"
state converge-plan --mode seed
chmod 644 "$(dir_of write-plan)/ledger.md"
check "$RC" "2" "filesystem: a seed that cannot read write-plan's ledger exits 2"
check_contains "$ERR" "could not read $(dir_of write-plan)/ledger.md" \
  "filesystem: a seed that cannot read write-plan's ledger names it"
check "$([ -e "$(dir_of converge-plan)/evidence.md" ] && echo landed || echo absent)" "absent" \
  "filesystem: a seed that cannot read write-plan's ledger lands no evidence.md"

# A converge-plan evidence.md the seed cannot read refuses the seed and
# is left as it was, rather than read as empty and overwritten.
new_case seed-evidence-unreadable
stage ledger.md "the ledger"
stage rec "the record"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
state write-plan --mode append --file evidence.md --from "$CASE/stage/rec"
stage own "a converge record"
state converge-plan --mode append --file evidence.md --from "$CASE/stage/own"
chmod 000 "$(dir_of converge-plan)/evidence.md"
state converge-plan --mode seed
chmod 644 "$(dir_of converge-plan)/evidence.md"
check "$RC" "2" "filesystem: a seed that cannot read converge-plan's evidence.md exits 2"
check_contains "$ERR" "could not read $(dir_of converge-plan)/evidence.md" \
  "filesystem: a seed that cannot read converge-plan's evidence.md names it"
check "$(cat "$(dir_of converge-plan)/evidence.md")" "a converge record" \
  "filesystem: a seed that cannot read converge-plan's evidence.md leaves it untouched"
check "$([ -e "$(dir_of converge-plan)/ledger.md" ] && echo landed || echo absent)" "absent" \
  "filesystem: a seed that cannot read converge-plan's evidence.md lands no ledger.md"

# A write-plan evidence.md the seed cannot read is named as unreadable,
# whether or not converge-plan already holds records, rather than read as
# a log that lacks them or failed on as a copy that could not stage.
new_case seed-source-evidence-unreadable
stage ledger.md "the ledger"
stage rec "the record"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
state write-plan --mode append --file evidence.md --from "$CASE/stage/rec"
chmod 000 "$(dir_of write-plan)/evidence.md"
state converge-plan --mode seed
chmod 644 "$(dir_of write-plan)/evidence.md"
check "$RC" "2" "filesystem: a seed that cannot read write-plan's evidence.md exits 2"
check_contains "$ERR" "could not read $(dir_of write-plan)/evidence.md" \
  "filesystem: a seed that cannot read write-plan's evidence.md names it"
check "$([ -e "$(dir_of converge-plan)/evidence.md" ] && echo landed || echo absent)" "absent" \
  "filesystem: a seed that cannot read write-plan's evidence.md lands no evidence.md"

new_case seed-source-evidence-unreadable-over-records
stage ledger.md "the ledger"
stage rec "the record"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
state write-plan --mode append --file evidence.md --from "$CASE/stage/rec"
state converge-plan --mode append --file evidence.md --from "$CASE/stage/rec"
chmod 000 "$(dir_of write-plan)/evidence.md"
state converge-plan --mode seed
chmod 644 "$(dir_of write-plan)/evidence.md"
check "$RC" "2" "filesystem: a seed over records that cannot read write-plan's evidence.md exits 2"
check_contains "$ERR" "could not read $(dir_of write-plan)/evidence.md" \
  "filesystem: a seed over records that cannot read write-plan's evidence.md names it"
check "$(cat "$(dir_of converge-plan)/evidence.md")" "the record" \
  "filesystem: a seed over records that cannot read write-plan's evidence.md leaves them untouched"

# --- the ledger's repo-derived rulings -----------------------------------

new_case ledger-put
state write-plan --mode init
stage rec "- profile-cards: FetchStoryDetail reads the author row
  loadAuthors is called with the story's author"
state write-plan --mode append --file evidence.md --from "$CASE/stage/rec"
stage ledger.md "- One author row, one clock. [Repo-derived] The cards project from one loadAuthors read."
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
check "$RC" "2" "ledger: a repo-derived ruling with no Derivation: field is refused"
check_contains "$ERR" "- One author row, one clock. [Repo-derived]" "ledger: the refusal names the entry"
check "$([ -e "$(dir_of write-plan)/ledger.md" ] && echo written || echo absent)" "absent" \
  "ledger: a refused put writes no ledger"
stage ledger.md "- One author row. [Repo-derived] The cards share one read.
  Derivation: as FetchStoryDetail does."
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
check "$RC" "2" "ledger: a derivation with no Evidence: or Command: check is refused"
stage ledger.md "- One author row. [Repo-derived] The cards share one read.
  Derivation: FetchStoryDetail reads the author row through loadAuthors.
  Evidence: - profile-cards: FetchStoryDetail reads the author row"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
check "$RC" "0" "ledger: a derivation citing an evidence.md record is accepted"
stage ledger.md "- One author row. [Repo-derived] The cards share one read.
  Derivation: FetchStoryDetail reads the author row through loadAuthors.
  Evidence: - a record nobody appended"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
check "$RC" "2" "ledger: an Evidence: field naming no evidence.md line is refused"
stage ledger.md "- Pin the SDK. [Repo-derived] The plan builds on sdk 4.2.0.
  Derivation: the registry's latest release.
  Command: npm view sdk version
  Output: 4.2.0"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
check "$RC" "0" "ledger: a derivation recording its command and output is accepted"
stage ledger.md "- Rename the field. [User-ratified] It is called budget.
- Which retry count? [Discuss]"
state write-plan --mode put --file ledger.md --from "$CASE/stage/ledger.md"
check "$RC" "0" "ledger: user-ratified and discuss entries need no derivation"

new_case ledger-append
state write-plan --mode init
stage head "- Pin the SDK. [Repo-derived] The plan builds on sdk 4.2.0."
state write-plan --mode append --file ledger.md --from "$CASE/stage/head"
check "$RC" "2" "ledger: an append leaving a ruling with no derivation is refused"
check "$([ -e "$(dir_of write-plan)/ledger.md" ] && echo written || echo absent)" "absent" \
  "ledger: a refused append writes nothing"
stage whole "- Pin the SDK. [Repo-derived] The plan builds on sdk 4.2.0.
  Derivation: the registry's latest release.
  Command: npm view sdk version
  Output: 4.2.0"
state write-plan --mode append --file ledger.md --from "$CASE/stage/whole"
check "$RC" "0" "ledger: an append of a whole ruling is accepted"
state write-plan --mode append --file ledger.md --from "$CASE/stage/head"
check "$RC" "2" "ledger: the append is judged by the ledger it leaves"

new_case ledger-seed
stage ledger.md "# Rulings

- One author row, one clock. [Repo-derived] The cards project from one loadAuthors read.

- Pin the SDK. [Repo-derived] The plan builds on sdk 4.2.0.
  Derivation: the registry's latest release.
  Command: npm view sdk version
  Output: 4.2.0"
# The fixture holds a repo-derived ruling with no derivation, which the put
# guard refuses, so it is copied into write-plan's directory directly.
mkdir -p "$(dir_of write-plan)"
cp "$CASE/stage/ledger.md" "$(dir_of write-plan)/ledger.md"
state converge-plan --mode seed
check "$RC:$OUT" "0:- One author row, one clock. [Repo-derived] The cards project from one loadAuthors read." \
  "seed: prints each repo-derived ruling it reopened"
state converge-plan --mode print --file ledger.md
check "$OUT" "# Rulings

- One author row, one clock. [Discuss] The cards project from one loadAuthors read.
  Reopened: seeded as repo-derived with no checkable derivation

- Pin the SDK. [Repo-derived] The plan builds on sdk 4.2.0.
  Derivation: the registry's latest release.
  Command: npm view sdk version
  Output: 4.2.0" "seed: reopens a ruling with no derivation as a discuss item and keeps the rest"
printf '%s\n' "$OUT" >"$CASE/stage/seeded.md"
state converge-plan --mode put --file ledger.md --from "$CASE/stage/seeded.md"
check "$RC" "0" "seed: the reopened ledger passes the put guard"

# --- refusals ------------------------------------------------------------

new_case refusals
for bad in 'o/r' 'a/b/c/d' '/h/o/r' 'h//o/r' 'http://h.example/o/r' 'https://h.example/o' \
  'h.example/../r' 'h.example/./r' 'h.example/o/r x' 'h.example/o/$r'; do
  OUT=$("$STATE" --repo "$bad" --skill write-plan --issue 42 --mode init 2>&1)
  check "$?" "2" "refusal: --repo \`$bad\` is refused"
done
check "$(find "$XDG_STATE_HOME" -mindepth 1 | wc -l | tr -d ' ')" "0" "refusal: a refused repository writes no state"

OUT=$("$STATE" --skill write-plan --issue 42 --mode init 2>&1)
check "$?" "2" "refusal: a missing --repo is refused"
state critique-plan --mode init
check "$RC" "2" "refusal: an unknown skill is refused"
OUT=$("$STATE" --repo h.example/o/r --skill write-plan --issue 4x --mode init 2>&1)
check "$?" "2" "refusal: a non-numeric issue is refused"
state write-plan --mode frob
check "$RC" "2" "refusal: an unknown mode is refused"
stage x "x"
for bad in '../ledger.md' 'a/b.md' '.hidden' 'a b.md'; do
  state write-plan --mode put --file "$bad" --from "$CASE/stage/x"
  check "$RC" "2" "refusal: --file \`$bad\` is refused"
done
state write-plan --mode put --file draft.md
check "$RC" "2" "refusal: put without --from is refused"
state write-plan --mode put --file draft.md --from "$CASE/stage/missing"
check "$RC" "2" "refusal: a --from naming no file is refused"
state write-plan --mode print --file draft.md --from "$CASE/stage/x"
check "$RC" "2" "refusal: print takes no --from"
state write-plan --mode init --file draft.md
check "$RC" "2" "refusal: init takes no --file"
check "$(find "$XDG_STATE_HOME" -mindepth 1 | wc -l | tr -d ' ')" "0" "refusal: no refusal writes state"

echo
if [ "$FAILURES" -eq 0 ]; then
  echo "all passed"
else
  echo "$FAILURES failed"
  exit 1
fi
