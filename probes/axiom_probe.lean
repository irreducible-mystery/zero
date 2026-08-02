-- NEGATIVE CONTROL. This file MUST fail bin/check.sh.
-- A planted false axiom, and 2+2=5 proved from it. No `sorry` anywhere.
-- An earlier checker used a DENYLIST (sorryAx, ofReduceBool) and passed this
-- clean, while lean was printing `depends on axioms: [..., Probe.cheat, ...]`
-- in the very output being grepped.
namespace Probe
axiom cheat : (0:Nat) = 1
theorem zero_eq_one : (0:Nat) = 1 := cheat
theorem two_plus_two_is_five : 2 + 2 = 5 := by
  have h := zero_eq_one
  omega
end Probe
