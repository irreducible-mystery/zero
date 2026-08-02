# CHANNELS

Where to put a thing you noticed. Four files, four different fates. Pick by
**what you can point at**, never by how bad it feels.

| you have | file | what happens |
|---|---|---|
| a command showing claim ≠ artifact | `ledger/sites.tsv` | counted by class. 2 sites → a mechanism gets built |
| a mechanism that hurt in practice | `ledger/friction.tsv` | counted per gate. 2 friction + 0 field-catches → the gate is a deletion candidate |
| a gate that caught something real | `ledger/events.tsv` | the yield number. this is what keeps a good gate alive |
| a belief that met reality and lost | nowhere yet | write it up. never legislate it |

**On the word "error".** Dropped. It collapses three things with disjoint
remedies and it moralises. Say which one you mean: a **defect** (claim ≠
artifact), a **surprise** (belief lost), **waste** (cost, no artifact), or
**friction** (a mechanism cost you more than it caught). Four concrete words,
no umbrella.

---

## Both arrows

    defect  →  sites.tsv  →  2 sites  →  mechanism built  →  gates.tsv
                                                                 ↓
    STATE.md  ←  counts generated  ←────────────────────────  gate runs
       ↑                                                         ↓
       └────  deletion  ←  2 friction + 0 catches  ←  friction.tsv

The upward arrow existed. **The downward one did not**, and without it
escalation is a ratchet: every defect adds a gate, no gate is ever removed, and
`|G|` rises until verification costs more than the work. This branch is itself
an instance — it took `|G|` from 4 to 8 in the session that wrote the warning.

Thresholds are deliberately the same shape in both directions:

- **escalate** — ≥2 open *sites*, no mechanism → build one
- **delete** — ≥2 *friction*, no field-catch → the gate is a candidate

Both are counted, neither is argued. `verify.sh` check 9 runs the second;
check 10 is its control and proves it fires at 2 and stays silent at 1. A
threshold that never fires is decoration; one that always fires is a ban.

---

## Filing friction

You do not need permission and you do not make a case. Append one row:

    gate_id <TAB> site <TAB> kind

`kind` ∈ `false-positive` `unclear-verdict` `cost` `blocked` `bypassed`.

**No free text.** If it needs a sentence it is not friction, it is a defect —
it belongs in `sites.tsv` where it gets a search key and a sweep.

**`bypassed` is the most valuable row in the repo and the one nobody wants to
write.** A worked-around gate is worse than a deleted one: it still costs, and
it now reports a safety it is not providing. Filing it costs you nothing. Two
of them retire the gate.

---

## What another instance sees

Everything above is `git`-visible and generated into `STATE.md` on every run.
An instance arriving cold does not need anyone to brief it: the open classes,
the gates under friction, and the rules marked `UNENFORCED` are all readable
without asking a party who might be wrong about them.

That is the whole point of the return arrow — **what has become structural is
visible downward without anyone announcing it**, and what is failing in
practice is visible upward without anyone having to be believed.
