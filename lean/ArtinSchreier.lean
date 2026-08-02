/- Characteristic 2: the gap map becomes ADDITIVE, and the obstruction stops
   being a collision and becomes a PARITY. Built over GF(4) explicitly, since
   Fin 4 is not a field.

   Core Lean derives DecidableEq but not an enumeration, so quantifiers here go
   through an explicit element list whose COMPLETENESS is proved first. -/

inductive F4 | z | o | a | b
  deriving DecidableEq, Repr

open F4

def all : List F4 := [z, o, a, b]

/-- The enumeration is complete: nothing else exists to quantify over. -/
theorem all_complete (x : F4) : x ∈ all := by cases x <;> simp [all]

def add : F4 → F4 → F4
  | z, y => y      | y, z => y
  | o, o => z      | o, a => b      | o, b => a
  | a, o => b      | a, a => z      | a, b => o
  | b, o => a      | b, a => o      | b, b => z

/-- Multiplication with a*a = b, i.e. a^2 = a + 1. -/
def mul : F4 → F4 → F4
  | z, _ => z      | _, z => z
  | o, y => y      | y, o => y
  | a, a => b      | a, b => o
  | b, a => o      | b, b => a

/-- Every non-zero element is invertible: it really is a field. -/
theorem F4_units :
    (all.all (fun x => x == z || all.any (fun y => mul x y == o))) = true := by decide

/-- THE GAP MAP. phi(x) = x*x + x. -/
def phi (x : F4) : F4 := add (mul x x) x

/-- IT IS ADDITIVE - Frobenius minus identity. All sixteen pairs. -/
theorem phi_additive :
    (all.all (fun x => all.all (fun y =>
      phi (add x y) == add (phi x) (phi y)))) = true := by decide

/-- Its kernel is exactly the prime field {0, 1}. -/
theorem phi_kernel :
    (all.all (fun x => (phi x == z) == (x == z || x == o))) = true := by decide

/-- EXACTLY HALF the gaps are reachable. -/
theorem half_reachable :
    (all.filter (fun G => all.any (fun x => phi x == G))).length = 2 := by decide

/-- Each reachable gap has EXACTLY TWO roots. -/
theorem two_roots_each :
    (all.filter (fun x => phi x == z)).length = 2 ∧
    (all.filter (fun x => phi x == o)).length = 2 := by decide

/-- AND NO GAP EVER HAS A DOUBLE ROOT. There is no branch point here at all -
    the obstruction is a parity, not a collision. -/
theorem no_double_root :
    (all.all (fun G => (all.filter (fun x => phi x == G)).length != 1)) = true := by
  decide

/-- The two unreachable gaps, named. -/
theorem unreachable :
    (all.any (fun x => phi x == a)) = false ∧
    (all.any (fun x => phi x == b)) = false := by decide

#print axioms all_complete
#print axioms F4_units
#print axioms phi_additive
#print axioms phi_kernel
#print axioms half_reachable
#print axioms two_roots_each
#print axioms no_double_root
#print axioms unreachable
