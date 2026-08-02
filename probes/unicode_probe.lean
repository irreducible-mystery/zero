-- NEGATIVE CONTROL. This file MUST fail bin/check.sh.
--
-- Greek identifiers are ordinary style in Lean mathematics. The census used to
-- extract declaration names with an awk regex anchored on [A-Za-z_], which is
-- ASCII. Every declaration below was therefore INVISIBLE to it: on a corpus
-- file carrying these three, it reported "4 declarations, 4 audited, axioms
-- within allowlist" and the whole gate exited 0 -- while the file proved False.
--
-- The fix was not a better regex. It was to stop parsing source text and ask
-- Lean for its own environment instead. This probe pins the case.
namespace Uni
axiom δgap_normal : (0:Nat) = 1
theorem δfalse : False := by
  have h := δgap_normal
  simp at h
theorem δtwo_plus_two_is_five : 2 + 2 = 5 := by
  have h := δgap_normal
  simp at h
end Uni
