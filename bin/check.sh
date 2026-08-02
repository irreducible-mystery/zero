#!/bin/sh
# check.sh — soundness census over EVERY declaration in a Lean file.
#
# HOW THE DECLARATION LIST IS OBTAINED, AND WHY IT CHANGED
#
#   Earlier versions extracted declaration names with an awk regex over the
#   source text. Every version of that regex was wrong, and each was found by
#   planting something false rather than by running it on files that pass:
#
#     1. it read only the `#print axioms` lines the author had written by hand
#        -- 45 of 66 declarations, while the docs claimed "every declaration"
#     2. it matched only `theorem|lemma`, so a `sorry` inside a `def` that no
#        theorem depended on was invisible
#     3. it used a DENYLIST of bad axioms, so a planted `axiom cheat : 0 = 1`
#        and a theorem proving `2 + 2 = 5` from it passed clean
#     4. its allowlist parser required `[` and `]` on the same line, and lean
#        WRAPS long axiom lists, so wrapped lists parsed as empty
#     5. it anchored on `[A-Za-z_]`, which is ASCII. Greek identifiers are
#        ordinary style in Lean mathematics, so `axiom δcheat : 0 = 1` and
#        `theorem δfalse : False` were invisible -- the census reported
#        "4 declarations, 4 audited" on a file with 7, and passed.
#
#   Five regexes, five holes. The regex was not the bug; parsing source text to
#   discover declarations is the bug. Nobody writing a regex can enumerate the
#   identifiers a future author may legally use.
#
#   So the list is no longer parsed. It is ASKED FOR. The census probe imports
#   Lean, appends the file, and walks `env.constants.map₂` -- the declarations
#   this module actually added -- calling `CollectAxioms.collect` on each. The
#   answer comes from the same elaborator that accepted the file. There is no
#   identifier it can spell that this cannot see.
#
# TWO INDEPENDENT GATES, because one gate is one point of failure:
#   (a) the axiom census below, ALLOWLIST not denylist
#   (b) a separate check on lean's own `uses 'sorry'` warning, which does not
#       depend on the census working at all
#
# NOTE: `lean f.lean; echo $?` returns 0 for a file full of `sorry`, and 0 for a
# file with a planted false axiom. Exit status is not a gate and never was.

set -u
command -v lean >/dev/null 2>&1 || { echo "no lean on PATH"; exit 2; }
fail=0

# Permitted axioms; anything else fails. An axiom nobody thought to name cannot
# pass an allowlist, which is the entire point of it being one.
ALLOW='propext|Classical\.choice|Quot\.sound'

echo "=== compile ==="
for f in *.lean; do
    [ -e "$f" ] || continue
    out=$(lean "$f" 2>&1)
    rc=$?
    # GATE (b): independent of the census below.
    sw=$(printf '%s' "$out" | grep -c "uses 'sorry'")
    printf '  %-24s EXIT=%s  sorry-warnings=%s\n' "$f" "$rc" "$sw"
    [ "$rc" -eq 0 ] || fail=1
    [ "$sw" -eq 0 ] || { echo "    ABORT: $f contains a declaration using 'sorry'"; fail=1; }
done

echo
echo "=== axiom census, enumerated by Lean itself over every declaration ==="
tot=0; aud=0
for f in *.lean; do
    [ -e "$f" ] || continue
    probe=$(mktemp /tmp/gapcensus.XXXXXX.lean)
    {
        echo 'import Lean'
        # a corpus file may carry its own imports; they must precede everything.
        grep -E '^[[:space:]]*import[[:space:]]' "$f" 2>/dev/null
        grep -vE '^[[:space:]]*import[[:space:]]' "$f"
        echo
        echo 'open Lean Elab Command in'
        echo 'run_cmd do'
        echo '  let env ← getEnv'
        echo '  for (n, _) in env.constants.map₂.toList do'
        echo '    unless n.isInternal do'
        echo '      let (_, s) := ((CollectAxioms.collect n).run env).run {}'
        echo '      logInfo s!"CENSUS|{n}|{s.axioms.toList.map toString}"'
    } > "$probe"
    out=$(lean "$probe" 2>&1); prc=$?
    rm -f "$probe"

    if [ "$prc" -ne 0 ]; then
        echo "  ABORT: census probe for $f did not compile - NO CENSUS TAKEN"
        printf '%s\n' "$out" | grep 'error:' | head -3 | sed 's/^/    /'
        fail=1; continue
    fi

    lines=$(printf '%s\n' "$out" | grep '^CENSUS|')
    n=$(printf '%s\n' "$lines" | grep -c '^CENSUS|')
    if [ "$n" -eq 0 ]; then
        echo "  ABORT: $f yielded no declarations - refusing to report a vacuous pass"
        fail=1; continue
    fi

    extra=$(printf '%s\n' "$lines" \
            | sed 's/^CENSUS|[^|]*|//; s/^\[//; s/\]$//' \
            | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
            | grep -v '^$' | sort -u \
            | grep -vxE "$ALLOW")

    tot=$((tot+n)); aud=$((aud+n))
    if [ -n "$extra" ]; then
        printf '  %-24s %3s declarations, %3s audited  FORBIDDEN AXIOMS:\n' "$f" "$n" "$n"
        printf '%s\n' "$extra" | sed 's/^/      /'
        fail=1
    else
        printf '  %-24s %3s declarations, %3s audited, axioms within allowlist\n' "$f" "$n" "$n"
    fi
done

echo
echo "  TOTAL: $tot declarations, $aud audited"
exit $fail
