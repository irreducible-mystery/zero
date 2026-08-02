/- The identity that forces Re(x) = 1/2 whenever the imaginary part survives.
   This is what turns the mirror into a sphere over a bigger algebra, and what
   makes the sphere ABSENT over the integers. -/

structure H where
  a : Int
  b : Int
  c : Int
  d : Int
  deriving DecidableEq

def hmul (x y : H) : H :=
  ⟨x.a*y.a - x.b*y.b - x.c*y.c - x.d*y.d,
   x.a*y.b + x.b*y.a + x.c*y.d - x.d*y.c,
   x.a*y.c - x.b*y.d + x.c*y.a + x.d*y.b,
   x.a*y.d + x.b*y.c - x.c*y.b + x.d*y.a⟩

def hone : H := ⟨1,0,0,0⟩
def hadd (x y : H) : H := ⟨x.a+y.a, x.b+y.b, x.c+y.c, x.d+y.d⟩
def hsmul (k : Int) (x : H) : H := ⟨k*x.a, k*x.b, k*x.c, k*x.d⟩

/-- Squaring, componentwise. -/
theorem hmul_self (x : H) :
    hmul x x = ⟨x.a*x.a - x.b*x.b - x.c*x.c - x.d*x.d,
                x.a*x.b + x.b*x.a, x.a*x.c + x.c*x.a, x.a*x.d + x.d*x.a⟩ := by
  cases x; simp [hmul, Int.mul_comm]; omega

/-- The factorisation, proved once and reused for each imaginary component. -/
theorem factor (u t : Int) (h : u*t + t*u = t) : (2*u - 1) * t = 0 := by
  have hc : t * u = u * t := Int.mul_comm t u
  have e : (2*u - 1) * t = (u*t + t*u) - t := by
    rw [hc, Int.sub_mul, Int.mul_assoc, Int.one_mul]; omega
  rw [e, h]; omega

/-- THE KEY CONSEQUENCE: every imaginary component t of a solution satisfies
    (2*Re(x) - 1) * t = 0. Either the real part sits at the collision, or the
    component vanishes. -/
theorem imaginary_forced (x : H) (G : Int)
    (h : hmul x x = hadd x (hsmul G hone)) :
    (2*x.a - 1) * x.b = 0 ∧ (2*x.a - 1) * x.c = 0 ∧ (2*x.a - 1) * x.d = 0 := by
  rw [hmul_self] at h
  have hb : x.a*x.b + x.b*x.a = x.b := by
    have := congrArg H.b h; simpa [hadd, hsmul, hone] using this
  have hc : x.a*x.c + x.c*x.a = x.c := by
    have := congrArg H.c h; simpa [hadd, hsmul, hone] using this
  have hd : x.a*x.d + x.d*x.a = x.d := by
    have := congrArg H.d h; simpa [hadd, hsmul, hone] using this
  exact ⟨factor _ _ hb, factor _ _ hc, factor _ _ hd⟩

/-- OVER THE INTEGERS THE COLLISION IS UNREACHABLE (2a = 1 has no solution),
    so the imaginary part must vanish: every integral quaternion solution is
    REAL. The sphere is absent here, not merely unfound. -/
theorem integral_solutions_are_real (x : H) (G : Int)
    (h : hmul x x = hadd x (hsmul G hone)) : x.b = 0 ∧ x.c = 0 ∧ x.d = 0 := by
  obtain ⟨hb, hc, hd⟩ := imaginary_forced x G h
  have hne : 2*x.a - 1 ≠ 0 := by omega
  refine ⟨?_, ?_, ?_⟩
  · rcases Int.mul_eq_zero.mp hb with h' | h'
    · exact absurd h' hne
    · exact h'
  · rcases Int.mul_eq_zero.mp hc with h' | h'
    · exact absurd h' hne
    · exact h'
  · rcases Int.mul_eq_zero.mp hd with h' | h'
    · exact absurd h' hne
    · exact h'

/-- A concrete witness: i itself solves no gap equation over the integers. -/
theorem i_never_solves :
    ¬ ∃ G : Int, hmul ⟨0,1,0,0⟩ ⟨0,1,0,0⟩ = hadd ⟨0,1,0,0⟩ (hsmul G hone) := by
  intro ⟨G, h⟩
  have := congrArg H.b h
  simp [hmul, hadd, hsmul, hone] at this

#print axioms hmul_self
#print axioms factor
#print axioms imaginary_forced
#print axioms integral_solutions_are_real
#print axioms i_never_solves
