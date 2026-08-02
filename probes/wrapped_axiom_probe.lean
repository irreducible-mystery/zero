-- NEGATIVE CONTROL. This file MUST fail bin/check.sh.
--
-- Lean WRAPS long axiom lists across lines:
--     'Zz.evil' depends on axioms: [Zz.CheatOne...,
--      Zz.CheatTwo...]
-- The allowlist parser originally used a per-line sed requiring '[' and ']' on
-- the SAME line. It therefore extracted NOTHING from any wrapped list, and a
-- forbidden axiom reachable only through a wrapped list was invisible.
--
-- The bug was masked: axioms declared in the same file are probed individually,
-- and their own one-line output is short enough to parse. Move the axiom out of
-- the extractor's reach and the bypass is clean.
--
-- This probe pins the wrapped-output case so it stays tested rather than
-- remembered.
namespace Zz
axiom CheatOneWithAnExtremelyLongIdentifierNameToForceTheOutputToWrapAcrossLines : (0:Nat) = 1
axiom CheatTwoWithAnExtremelyLongIdentifierNameToForceTheOutputToWrapAcrossLines : (1:Nat) = 2
theorem evil : (0:Nat) = 1 := by
  have h2 := CheatTwoWithAnExtremelyLongIdentifierNameToForceTheOutputToWrapAcrossLines
  exact CheatOneWithAnExtremelyLongIdentifierNameToForceTheOutputToWrapAcrossLines
end Zz
