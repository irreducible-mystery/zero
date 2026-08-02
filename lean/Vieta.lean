/- The two invariants, over the integers. -/

-- x is a root of the gap equation with gap G.
def IsRoot (G x : Int) : Prop := x * x = x + G

-- Vieta, both halves, from nothing.
theorem sum_of_roots (G x y : Int) (hx : IsRoot G x) (hy : IsRoot G y)
    (hne : x ≠ y) : x + y = 1 := by
  unfold IsRoot at hx hy
  have key : (x - y) * (x + y - 1) = 0 := by
    have e : (x - y) * (x + y - 1) = (x*x - y*y) - (x - y) := by
      simp [Int.mul_sub, Int.mul_add, Int.mul_comm]
      omega
    rw [e, hx, hy]; omega
  have hxy : x - y ≠ 0 := by omega
  rcases Int.mul_eq_zero.mp key with h | h
  · exact absurd h hxy
  · omega

theorem product_of_roots (G x y : Int) (hx : IsRoot G x) (hy : IsRoot G y)
    (hne : x ≠ y) : x * y = -G := by
  have hs := sum_of_roots G x y hx hy hne
  unfold IsRoot at hx
  have hy1 : y = 1 - x := by omega
  subst hy1
  have : x * (1 - x) = x - x*x := by simp [Int.mul_sub]
  rw [this, hx]; omega

-- The discriminant IS the squared difference of the roots.
theorem discriminant_is_gap (G x y : Int) (hx : IsRoot G x) (hy : IsRoot G y)
    (hne : x ≠ y) : (x - y) * (x - y) = 1 + 4 * G := by
  have hs := sum_of_roots G x y hx hy hne
  have hp := product_of_roots G x y hx hy hne
  have e : (x - y) * (x - y) = (x + y) * (x + y) - 4 * (x * y) := by
    simp [Int.mul_sub, Int.mul_add, Int.mul_comm]
    omega
  rw [e, hs, hp]; omega

#print axioms sum_of_roots
#print axioms product_of_roots
#print axioms discriminant_is_gap
