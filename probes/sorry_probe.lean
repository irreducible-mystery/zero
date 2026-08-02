-- NEGATIVE CONTROL. This file MUST fail bin/check.sh.
-- A `sorry` inside a def that no theorem depends on. `lean` exits 0 on this:
-- `sorry` is only a WARNING. An earlier checker reported it clean.
namespace Probe
def orphan : Nat := sorry
theorem honest : 1 + 1 = 2 := rfl
end Probe
