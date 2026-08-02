/- The reflexive ladder: where the gap equals something it generates. -/

def IsRoot (G x : Int) : Prop := x * x = x + G

-- (a) THE GAP IS ONE OF ITS OWN ROOTS  <->  G = 0 or G = 2.
theorem gap_is_own_root (G : Int) : IsRoot G G ↔ (G = 0 ∨ G = 2) := by
  unfold IsRoot
  constructor
  · intro h
    have key : G * (G - 2) = 0 := by
      have e : G * (G - 2) = G * G - 2 * G := by simp [Int.mul_sub]; omega
      rw [e, h]; omega
    rcases Int.mul_eq_zero.mp key with h1 | h1
    · exact Or.inl h1
    · exact Or.inr (by omega)
  · intro h; rcases h with h | h <;> subst h <;> decide

-- (b) THE GAP EQUALS ITS OWN DISCRIMINANT  ->  no integer gap does this.
theorem no_gap_equals_discriminant : ¬ ∃ G : Int, G = 1 + 4 * G := by
  intro ⟨G, h⟩; omega

-- (c) THE COLLISION IS UNREACHABLE OVER THE INTEGERS.
--     1 + 4G = 0 has no integer solution: the branch point is not in Z.
theorem branch_point_not_integral : ¬ ∃ G : Int, 1 + 4 * G = 0 := by
  intro ⟨G, h⟩; omega

-- (d) ...and the collision root itself, 2x = 1, is not there either.
theorem collision_root_not_integral : ¬ ∃ x : Int, 2 * x = 1 := by
  intro ⟨x, h⟩; omega

-- (e) THE GAP EQUALS THE DIFFERENCE OF ITS ROOTS  ->  needs G*G = 1+4G,
--     i.e. (G-2)^2 = 5, and 5 is not a square in Z.
theorem five_not_square : ¬ ∃ k : Int, k * k = 5 := by
  intro ⟨k, h⟩
  have hn : k.natAbs * k.natAbs = 5 := by
    have hc := congrArg Int.natAbs h
    rw [Int.natAbs_mul] at hc
    exact hc
  rcases Nat.lt_or_ge k.natAbs 3 with hlt | hge
  · have : k.natAbs = 0 ∨ k.natAbs = 1 ∨ k.natAbs = 2 := by omega
    rcases this with h' | h' | h' <;> rw [h'] at hn <;> omega
  · have h9 : 3 * 3 ≤ k.natAbs * k.natAbs := Nat.mul_le_mul hge hge
    omega

#print axioms gap_is_own_root
#print axioms no_gap_equals_discriminant
#print axioms branch_point_not_integral
#print axioms collision_root_not_integral
#print axioms five_not_square
