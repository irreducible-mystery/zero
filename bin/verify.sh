#!/bin/sh
# verify.sh — the gate. Run this; it is the whole contract.
#
# Four things must hold. Any one failing exits non-zero.
#
#   1. the corpus passes the census      (positive control)
#   2. EVERY probe is rejected           (negative control -- a passing probe
#                                         means the alarm is broken, which is
#                                         the failure mode that keeps recurring)
#   3. STATE.md regenerates identically  (no hand-typed numbers can survive)
#   4. no stray .lean outside lean/ and probes/
#
# (2) is the one that matters. A checker that has only ever been run on files
# that pass has no evidence behind it. Three separate holes in this project's
# checker were found by planting something false and watching it not ring:
#   * a `sorry` in a def that no theorem depended on
#   * an axiom outside the denylist
#   * declarations the extractor never matched, so were never probed at all
#
# (3) is what makes a wrong count unrepresentable rather than merely discouraged.

set -u
export PATH="/root/.elan/bin:$PATH"
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 2
fail=0
command -v lean >/dev/null 2>&1 || { echo "FAIL: no lean on PATH"; exit 2; }

echo "== 1. corpus census (positive control) =="
if ( cd lean && sh ../bin/check.sh ); then
    echo "   PASS"
else
    echo "   FAIL: corpus did not pass its own census"; fail=1
fi

echo
echo "== 2. negative controls (every probe MUST be rejected) =="
n=0
for p in probes/*.lean; do
    n=$((n+1)); b=$(basename "$p")
    d=$(mktemp -d); cp "$p" "$d/"; cp bin/check.sh "$d/"
    ( cd "$d" && sh check.sh >/dev/null 2>&1 ); prc=$?
    rm -rf "$d"
    if [ "$prc" -ne 0 ]; then
        printf '   %-24s rejected (exit %s)  PASS\n' "$b" "$prc"
    else
        printf '   %-24s ACCEPTED (exit 0)   FAIL -- the gate is broken\n' "$b"
        fail=1
    fi
done
[ "$n" -eq 0 ] && { echo "   FAIL: no probes found. A gate with no negative control is not a gate."; fail=1; }

echo
echo "== 3. STATE.md is generated, not typed =="
tmp=$(mktemp)
sh bin/report.sh > "$tmp" 2>/dev/null
# the timestamp and wall-clock legitimately differ run to run; everything else
# must be byte-identical. strip only those two lines from both sides.
strip() { grep -v '^Generated: ' "$1" | grep -v '^| Census wall clock'; }
if [ ! -f STATE.md ]; then
    echo "   FAIL: STATE.md missing. run: sh bin/report.sh > STATE.md"; fail=1
elif strip "$tmp" > /tmp/.a && strip STATE.md > /tmp/.b && diff -u /tmp/.b /tmp/.a >/dev/null; then
    echo "   PASS: committed STATE.md matches a fresh generation"
else
    echo "   FAIL: STATE.md differs from a fresh generation --"
    echo "         either the corpus changed or someone edited it by hand."
    strip "$tmp" > /tmp/.a; strip STATE.md > /tmp/.b
    diff -u /tmp/.b /tmp/.a | head -40 | sed 's/^/         /'
    fail=1
fi
rm -f "$tmp" /tmp/.a /tmp/.b

echo
echo "== 4. no stray .lean outside lean/ and probes/ =="
stray=$(find . -name '*.lean' -not -path './lean/*' -not -path './probes/*' -not -path './.git/*')
if [ -z "$stray" ]; then echo "   PASS"; else echo "$stray" | sed 's/^/   FAIL: stray /'; fail=1; fi

echo
if [ "$fail" -eq 0 ]; then echo "ALL GATES PASS"; else echo "GATES FAILED"; fi
exit $fail
