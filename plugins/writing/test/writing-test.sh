#!/usr/bin/env bash
#
# writing-test.sh -- drive plugins/writing/bin/writing-plan-state against
# a state root of its own: the directory each skill and issue composes
# under XDG_STATE_HOME, every mode, the append-only evidence log, the
# seed from write-plan's state into converge-plan's, and each refusal of
# a repository, a skill, an issue, a file name or a payload.
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

# Each case gets a state root and a staging directory of its own, so no
# case reads a file another one wrote.
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
