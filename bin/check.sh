#!/bin/sh
# check.sh - compile every file standalone AND census EVERY declaration.
#
# The census is INJECTED, not read from the file. An earlier version reported
# only the `#print axioms` lines the author happened to write, which covered
# 45 of 66 declarations while the README claimed "every declaration". That
# claim was false and a cold reader caught it. This version extracts every
# declaration name and probes it, and ABORTS if it cannot.
#
# 2026-08-01: the version after THAT one still said "EVERY declaration" while
# matching only `theorem|lemma`. A `sorry` inside a `def` that no theorem
# depends on was therefore invisible: on a planted probe, `lean` emitted only
# `warning: declaration uses 'sorry'` and exited 0, and this script printed
# "1 declarations, 1 audited, sorryAx/native: 0". Two fixes below:
#   (a) extract def/abbrev/instance/structure/example as well as theorem/lemma;
#   (b) an independent GATE on lean's own "declaration uses 'sorry'" warning,
#       which catches holes in anonymous declarations that have no name to probe.
# (b) does not depend on (a) being complete, which is the point of having it.
set -u
# core Lean only: these files have no imports, so no LEAN_PATH is needed.
command -v lean >/dev/null 2>&1 || { echo "no lean on PATH"; exit 2; }
fail=0

extract() {
    awk '
      /^[[:space:]]*namespace[[:space:]]+/ { ns[++d]=$2; next }
      /^[[:space:]]*end[[:space:]]+/       { if (d>0 && $2==ns[d]) d--; next }
      {
        line=$0
        sub(/^[[:space:]]*/,"",line)
        sub(/^@\[[^]]*\][[:space:]]*/,"",line)
        while (line ~ /^(private|protected|noncomputable|partial|unsafe)[[:space:]]+/)
          sub(/^(private|protected|noncomputable|partial|unsafe)[[:space:]]+/,"",line)
        if (line ~ /^(theorem|lemma|def|abbrev|instance|structure|example|axiom)[[:space:]]+[A-Za-z_]/) {
          n=line; sub(/^[a-z]+[[:space:]]+/,"",n); sub(/[^A-Za-z_0-9.'"'"'].*/,"",n)
          if (n=="") next
          p=""; for (i=1;i<=d;i++) p = p ns[i] "."
          print p n
        }
      }' "$1"
}

echo "=== compile ==="
for f in *.lean; do
    [ -e "$f" ] || continue
    out=$(lean "$f" 2>&1)
    rc=$?
    # GATE (b): lean exits 0 on `sorry` -- it is only a warning. Catch it here,
    # independently of whether the name-based census below reaches the decl.
    sw=$(printf '%s' "$out" | grep -c "uses 'sorry'")
    printf '  %-24s EXIT=%s  sorry-warnings=%s\n' "$f" "$rc" "$sw"
    [ "$rc" -eq 0 ] || fail=1
    [ "$sw" -eq 0 ] || { echo "    ABORT: $f contains a declaration using 'sorry'"; fail=1; }
done

echo
echo "=== axiom census, injected over EVERY declaration ==="
tot=0; aud=0
for f in *.lean; do
    [ -e "$f" ] || continue
    names=$(extract "$f" | sort -u)
    [ -z "$names" ] && continue
    n=$(printf '%s\n' "$names" | wc -l | tr -d ' ')
    probe=$(mktemp /tmp/gapcensus.XXXXXX.lean)
    { sed 's/^#print axioms.*//' "$f"; echo
      for nm in $names; do printf '#print axioms %s\n' "$nm"; done ; } > "$probe"
    out=$(lean "$probe" 2>&1); rm -f "$probe"
    if printf '%s' "$out" | grep -q 'error:'; then
        echo "  ABORT: census probe for $f did not compile - NO CENSUS TAKEN"
        printf '%s\n' "$out" | grep 'error:' | head -3 | sed 's/^/    /'
        fail=1; continue
    fi
    a=$(printf '%s' "$out" | grep -c "depends on axioms\|does not depend on any axioms")
    if [ "$n" -ne "$a" ]; then
        echo "  ABORT: $f has $n declarations but $a were audited"
        fail=1; continue
    fi
    tot=$((tot+n)); aud=$((aud+a))
    # ALLOWLIST, not denylist. Only these three are permitted; ANY other axiom
    # fails, including ones nobody thought to name.
    #
    # 2026-08-02: this was a denylist -- grep -c for sorryAx|ofReduceBool. A file
    # containing `axiom cheat : (0:Nat) = 1` and a theorem `2+2=5` proved from it
    # passed with "2 declarations, 2 audited, sorryAx/native: 0" and EXIT 0,
    # while lean itself was printing `depends on axioms: [propext, Attack.cheat,
    # Quot.sound]` in the very output being grepped. A denylist cannot enumerate
    # what an author may invent. `axiom` was also missing from the extractor.
    # NB: lean WRAPS long axiom lists across lines --
    #   'X' depends on axioms: [A.Very.Long.Name,
    #    B.Another.Long.Name]
    # An earlier version used a per-line sed requiring '[' and ']' on the SAME
    # line, so it extracted NOTHING from any wrapped list and forbidden axioms
    # were invisible. That was masked only because axioms declared in the same
    # file get probed individually and their own short output does fit one line.
    # Newlines are collapsed to spaces BEFORE extraction so wrapping cannot hide
    # anything.
    extra=$(printf '%s\n' "$out" | tr '\n' ' ' \
            | grep -o 'depends on axioms: \[[^]]*\]' \
            | sed 's/.*\[//; s/\]//' \
            | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
            | grep -v '^$' | sort -u \
            | grep -vxE 'propext|Classical\.choice|Quot\.sound')
    if [ -n "$extra" ]; then
        printf '  %-24s %3s declarations, %3s audited  FORBIDDEN AXIOMS:\n' "$f" "$n" "$a"
        printf '%s\n' "$extra" | sed 's/^/      /'
        fail=1
    else
        printf '  %-24s %3s declarations, %3s audited, axioms within allowlist\n' "$f" "$n" "$a"
    fi
done
echo
echo "  TOTAL: $tot declarations, $aud audited"
[ "$tot" -eq "$aud" ] || { echo "  MISMATCH"; fail=1; }
exit $fail
