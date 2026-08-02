# LEDGER

Add-only. See something, add a line, move on. Do not edit or delete lines.
Do not write prose here. If it needs a paragraph it goes somewhere else.

---

## What this is for

**Object.** A corpus of Lean declarations, and the gates that check it.

**Goal.** A stranger can verify every claim in this repo without trusting
anyone who made it.

**Optimized for.** Verified artifacts per unit of Kelly's attention. Not per
token — attention is the scarce input and the one that has been burning.

An artifact counts as verified when `sh bin/verify.sh` exits 0 in a stranger's
hands, on their machine, after a clone. Nothing else counts.

---

## Three kinds of error

They are separated because **the remedies are disjoint**, not because some are
worse. Do not classify when you write a line — the witness classifies it.

| | what it is | remedy |
|---|---|---|
| **defect** | a claim diverges from an artifact, and a command shows it | structural: remove the freedom, or gate it |
| **surprise** | a belief met reality and lost | record it. never legislate it. this is the point of the work |
| **waste** | cost spent, no artifact produced | delete a component. do not add a gate |

Confusing waste for defect is how a gate gets added where a component should
have been deleted.

**Architecture is derived, not declared.** `git blame` on the site says who
wrote it. Nobody has to guess whether an error was "human" or "AI", and nobody
would guess right — an instance cannot see upstream of its own context.

The distinction still matters, because it changes what works:

- **AI-authored sites**: no persistence, so no norm, rule, or warning can bind.
  The instance that would have heeded it is gone. **Structural only.**
- **Human-authored sites**: norms can work, because the author persists and
  updates.
- **Interface sites**: exist only in the coupling. A loose sentence reaching an
  expensive step with no checkpoint. Remedy is at the boundary — the expensive
  step takes input only from a written interpretation, never from raw prose.

---

## Cost and benefit

**Defect.** Cost = spend before it was caught, plus every site it reached in
the meantime. Benefit = zero at one site; at two or more it has earned a
mechanism. **One site is an incident. Two sites is a class.**

**Surprise.** Expensive and usually worth it. Never counted against anyone.

**Waste.** Pure cost, zero benefit, and the only category with no detector.
Recorded so it can be seen in aggregate later.

---

## The line

```
date | class | site | key | cost
```

- **class** — short slug. **Reuse an existing one if it fits.** That reuse is
  the entire pattern-detection mechanism.
- **site** — `file:line`. Where the defect lives, not where you noticed it.
- **key** — a command that finds other instances. `grep -rn 'pattern'`.
  **Required.** A class with no key cannot be swept, so its other sites stay
  invisible and closing it buys less than it appears to.
- **cost** — rough. minutes or tokens, before the catch. Guess; don't measure.

No severity. No category. No blame. No narrative. If you are writing sentences
you are in the wrong file.

---

## What the system does, with no judgment

1. Count **distinct sites** per class — not occurrences. For an AI-authored
   site, recurrence is architecturally guaranteed and carries no information;
   surface area does.
2. **≥ 2 sites → surface for escalation.**
3. **Escalation requires a mechanism *and* a key.** No proposed machine → not
   ready. No way to enumerate the other sites → stays local, however real.
4. Mechanism preference, in order: **(1) remove the degree of freedom**
   (generate it, derive it, ask the system that knows) **(2) reject at a gate**.
   The repo is 2-for-2 on (1) holding and 6-for-6 on (2) needing patches.
   A warning is not a mechanism.
5. **A class is closed by a sweep, not a fix.** When a mechanism lands, run the
   key across the tree, close every site or record the ones left open with a
   reason. A fix at one site closes nothing.

---

## Two rules

1. **Not having written the thing.** Whoever wrote it does not test it, does
   not certify it, does not write its negative control. Reporting needs no
   trust; certifying needs someone else.
2. **A class is closed by a sweep, not a fix.**

That is all of them. Anything that wants to be a third rule is a mechanism
proposal and goes through escalation.

---

## Entries

| date | class | site | key | cost |
|---|---|---|---|---|
| 2026-08-01 | vacuous-pass | bin/check.sh (extractor matched nothing) | `grep -n 'continue\|-eq 0 \]' bin/*.sh` | ~1h |
| 2026-08-01 | vacuous-pass | bin/check.sh (no declarations yielded) | same | — |
| 2026-08-01 | vacuous-pass | bin/verify.sh (no probes found) | same | — |
| 2026-08-01 | text-parse-for-names | bin/check.sh:extract (awk `[A-Za-z_]`) | `grep -rn '\[A-Za-z' bin/` | ~3h |
| 2026-08-02 | text-parse-for-names | bin/report.sh:69 (`[A-Za-z]*\.lean`) | same | ~20m |
| 2026-08-02 | gate-name-overclaims | bin/verify.sh check 3 — says "generated not typed", asserts "regeneration deterministic" | compare each gate's printed name to what it tests | ~10m |
| 2026-08-02 | gate-name-overclaims | bin/verify.sh check 2 — says "probes rejected", asserts "files exit nonzero" | same | ~10m |
| 2026-08-02 | gate-name-overclaims | bin/check.sh gate (b) — says "catches sorry", asserts "lean printed the string" | same | — |
| 2026-08-02 | pass-credited-to-wrong-gate | claimed check 2 accepted a hollow probe; check 3 was catching it | rerun each attack from a clean tree, name the gate that fires | ~15m |
| 2026-08-02 | vacuous-pass | bin/check.sh:51,65 — empty `lean/` gives `TOTAL: 0 declarations, 0 audited`, exit 0 | `grep -rn 'continue$\|-eq 0 \]' bin/*.sh` | ~2m |
| 2026-08-02 | pass-credited-to-wrong-gate | empty corpus: check 1 "positive control" prints PASS; only check 3 rings | rerun from a clean tree, name the gate that fires | ~2m |

**vacuous-pass**: 3 sites. **text-parse-for-names**: 2 sites, mechanism landed
(Lean enumerates its own environment), sweep incomplete.
**gate-name-overclaims**: 3 sites, mechanism proposed (probes declare a failure
signature), sweep not run. **pass-credited-to-wrong-gate**: 2 sites — promoted
from incident to class.

**Found by running the keys, first use.** The `vacuous-pass` key pointed at
`bin/check.sh:51,65` and a 4th site fell out in two minutes: with `lean/` empty
the census prints `TOTAL: 0 declarations, 0 audited` and exits 0, and check 1 —
named "positive control" — prints PASS. That second observation is what
promoted `pass-credited-to-wrong-gate` to a class.

**One defect in a key, found the same way.** The `text-parse-for-names` key
returns 4 hits and all 4 are comments describing the dead bug. A key that
matches its own postmortem never goes quiet, so the class can never be shown
closed. Keys need to exclude comments, or classes need a closed-date that
suppresses them.
