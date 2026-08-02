#!/bin/sh
# feedback.sh — the DOWNWARD arrow, and the only flow that shrinks |G|.
#
# sites.tsv reports defects in the corpus and pushes mechanisms UP.
# friction.tsv reports defects in the mechanisms and pushes deletions DOWN.
# Without the second, escalation is a ratchet: |G| only ever rises, and a gate
# that is wrong in practice is permanent because complaining about it is prose.
#
# The two thresholds are deliberately the same shape, opposite directions:
#   escalate:  >= 2 open SITES  and no mechanism   -> build one
#   delete:    >= 2 FRICTION    and no field-catch -> the gate is a candidate
#
# A gate whose entire lifetime record is control-only has never caught anything
# a person was actually trying to do. Paired with friction, that is not a
# suspicion, it is a measurement.
#
# ENFORCES: schema on friction.tsv and events.tsv, gate_id resolvable against
# gates.tsv, kind/outcome from a closed vocabulary. Then computes yield.
set -u
L=${1:-ledger}
fail=0
strip() { grep -v '^#' "$1" 2>/dev/null | grep -v '^[[:space:]]*$'; }

for f in friction events gates; do
    [ -f "$L/$f.tsv" ] || { echo "  ABORT: $L/$f.tsv missing"; exit 1; }
done
GATES=$(strip "$L/gates.tsv" | cut -f1 | sort -u)
[ -n "$GATES" ] || { echo "  ABORT: no gates declared - refusing a vacuous pass"; exit 1; }

echo "  -- friction (local -> mechanism) --"
strip "$L/friction.tsv" | while IFS='	' read -r g s k rest; do
    [ -n "${rest:-}" ] && { echo "  ABORT: too many fields: $g"; exit 1; }
    [ -n "$g" ] && [ -n "$s" ] && [ -n "$k" ] || { echo "  ABORT: empty field: $g $s $k"; exit 1; }
    printf '%s\n' "$GATES" | grep -qx "$g" || { echo "  ABORT: friction names unknown gate '$g'"; exit 1; }
    case "$k" in
        false-positive|unclear-verdict|cost|blocked|bypassed) ;;
        *) echo "  ABORT: unknown kind '$k' on gate '$g'"; exit 1 ;;
    esac
done || fail=1

strip "$L/events.tsv" | while IFS='	' read -r g o rest; do
    [ -n "${rest:-}" ] && { echo "  ABORT: too many fields: $g"; exit 1; }
    printf '%s\n' "$GATES" | grep -qx "$g" || { echo "  ABORT: event names unknown gate '$g'"; exit 1; }
    case "$o" in field-catch|control-only) ;; *) echo "  ABORT: unknown outcome '$o'"; exit 1 ;; esac
done || fail=1
[ "$fail" -eq 0 ] || exit 1

# yield, per gate. computed, never typed.
for g in $GATES; do
    fr=$(strip "$L/friction.tsv" | cut -f1 | grep -cx "$g")
    fc=$(strip "$L/events.tsv" | awk -F'\t' -v G="$g" '$1==G && $2=="field-catch"' | wc -l | tr -d ' ')
    if [ "$fr" -ge 2 ] && [ "$fc" -eq 0 ]; then
        printf '  DELETION CANDIDATE  %-12s friction=%s field-catches=%s\n' "$g" "$fr" "$fc"
        fail=1
    else
        printf '  %-20s friction=%s field-catches=%s\n' "$g" "$fr" "$fc"
    fi
done
exit $fail
