/- Remove subtraction and the mirror cannot exist.

   In the max-plus semiring (+) is max and (*) is plus, so the gap equation
       x (*) x = x (+) G
   reads
       2*x = max x G .
   There is never more than one solution, so there is nothing for a mirror to
   exchange. -/

/-- THE MIRROR CANNOT EXIST HERE: the tropical gap equation has at most one
    solution, for every gap. -/
theorem tropical_unique (G x y : Int)
    (hx : 2*x = max x G) (hy : 2*y = max y G) : x = y := by
  omega

/-- The full solution description, so the uniqueness is not vacuous. -/
theorem tropical_solutions (G x : Int) :
    2*x = max x G ↔ ((x = 0 ∧ G ≤ 0) ∨ (2*x = G ∧ 0 < x)) := by
  omega

/-- A gap of every sign is genuinely solvable, so there is something to be
    unique about. -/
theorem tropical_witness_nonpos : (2:Int)*0 = max 0 (-7) := by decide
theorem tropical_witness_pos : (2:Int)*3 = max 3 6 := by decide

/-- And the discriminant that produces the mirror is not even expressible:
    1 + 4G is built from a subtraction the semiring does not have. What
    survives is only the ORDER, and an order cannot be reversed by an
    automorphism that fixes it. -/
theorem tropical_no_second_root (G x y : Int)
    (hx : 2*x = max x G) (hy : 2*y = max y G) (hne : x ≠ y) : False := by
  omega

#print axioms tropical_unique
#print axioms tropical_solutions
#print axioms tropical_no_second_root
