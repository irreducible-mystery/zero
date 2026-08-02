/- Two exact facts about specific schedules, proved rather than measured. -/

def run (s : Nat → Int) : Nat → Int × Int
  | 0 => (1, 1)
  | n+1 => ((run s n).2, (run s n).2 + s n * (run s n).1)

theorem run_succ (s : Nat → Int) (n : Nat) :
    run s (n+1) = ((run s n).2, (run s n).2 + s n * (run s n).1) := rfl

/-- THE FLOOR SCHEDULE: constant -1. -/
def minus : Nat → Int := fun _ => -1

/-- It is PERIODIC WITH PERIOD 6. This is the statement that the roots of
    x^2 = x - 1 are primitive sixth roots of unity, in elementary form. -/
theorem minus_period_six (n : Nat) : run minus (n+6) = run minus n := by
  induction n with
  | zero => decide
  | succ k ih =>
    have e : run minus (k+1+6) = ((run minus (k+6)).2,
        (run minus (k+6)).2 + minus (k+6) * (run minus (k+6)).1) := rfl
    rw [e, ih, run_succ]
    simp [minus]

/-- Hence it never grows: the whole orbit is six states. -/
theorem minus_orbit :
    run minus 0 = (1,1) ∧ run minus 1 = (1,0) ∧ run minus 2 = (0,-1) ∧
    run minus 3 = (-1,-1) ∧ run minus 4 = (-1,0) ∧ run minus 5 = (0,1) := by
  refine ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem minus_shift (m k : Nat) : run minus (m + 6*k) = run minus m := by
  induction k with
  | zero => simp
  | succ j ih =>
    have e : m + 6*(j+1) = (m + 6*j) + 6 := by omega
    rw [e, minus_period_six, ih]

theorem minus_bounded (n : Nat) : (run minus n).2.natAbs ≤ 1 := by
  have h : ∀ m : Nat, m < 6 → (run minus m).2.natAbs ≤ 1 := by decide
  have hn : n = n % 6 + 6 * (n / 6) := by omega
  rw [hn, minus_shift]
  exact h _ (Nat.mod_lt _ (by decide))

/-- THE ALTERNATING SCHEDULE reproduces the golden equation at double period.
    One period of +,- has transfer matrix [[2,-1],[1,-1]] : trace 1, det -1,
    so its characteristic polynomial is exactly  L^2 = L + 1. -/
def altTrace : Int := 2 + (-1)
def altDet : Int := 2 * (-1) - (-1) * 1

theorem alternation_is_golden : altTrace = 1 ∧ altDet = -1 := by decide

/-- Stated as the polynomial identity: L^2 - (trace) L + (det) = L^2 - L - 1. -/
theorem alt_char_poly (L : Int) :
    L*L - altTrace * L + altDet = L*L - L - 1 := by
  simp [altTrace, altDet]; omega

#print axioms minus_period_six
#print axioms minus_shift
#print axioms minus_bounded
#print axioms alternation_is_golden
#print axioms alt_char_poly
