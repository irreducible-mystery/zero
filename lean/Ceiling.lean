/- The ceiling: |f_n| <= F_n under EVERY sign schedule, and all-plus attains it. -/

theorem step_bound (a b g : Int) (hg : g = 1 ∨ g = -1) :
    (b + g * a).natAbs ≤ a.natAbs + b.natAbs := by
  rcases hg with h | h <;> subst h <;> omega

theorem step_tight (a b : Int) :
    (b + a).natAbs = a.natAbs + b.natAbs ∨ (b - a).natAbs = a.natAbs + b.natAbs := by
  omega

def fib : Nat → Nat
  | 0 => 0
  | 1 => 1
  | n+2 => fib n + fib (n+1)

theorem fib_step (n : Nat) : fib (n+2) = fib n + fib (n+1) := rfl

def run (s : Nat → Int) : Nat → Int × Int
  | 0 => (1, 1)
  | n+1 => ((run s n).2, (run s n).2 + s n * (run s n).1)

theorem run_zero (s : Nat → Int) : run s 0 = (1,1) := rfl
theorem run_succ (s : Nat → Int) (n : Nat) :
    run s (n+1) = ((run s n).2, (run s n).2 + s n * (run s n).1) := rfl

def Signs (s : Nat → Int) : Prop := ∀ n, s n = 1 ∨ s n = -1

/-- THE CEILING. No schedule of unit gaps ever exceeds the Fibonacci numbers. -/
theorem run_bound (s : Nat → Int) (hs : Signs s) (n : Nat) :
    (run s n).1.natAbs ≤ fib (n+1) ∧ (run s n).2.natAbs ≤ fib (n+2) := by
  induction n with
  | zero => rw [run_zero]; exact ⟨by decide, by decide⟩
  | succ k ih =>
    obtain ⟨h1, h2⟩ := ih
    rw [run_succ]
    refine ⟨h2, ?_⟩
    have hb := step_bound (run s k).1 (run s k).2 (s k) (hs k)
    have hf : fib (k+3) = fib (k+1) + fib (k+2) := fib_step (k+1)
    show ((run s k).2 + s k * (run s k).1).natAbs ≤ fib (k+3)
    omega

/-- ALL-PLUS attains it exactly, on both components. -/
def plus : Nat → Int := fun _ => 1

theorem plus_is_fib (n : Nat) :
    (run plus n).1 = (fib (n+1) : Int) ∧ (run plus n).2 = (fib (n+2) : Int) := by
  induction n with
  | zero => rw [run_zero]; exact ⟨rfl, rfl⟩
  | succ k ih =>
    obtain ⟨h1, h2⟩ := ih
    rw [run_succ]
    refine ⟨h2, ?_⟩
    have hf : fib (k+3) = fib (k+1) + fib (k+2) := fib_step (k+1)
    show (run plus k).2 + plus k * (run plus k).1 = ((fib (k+3) : Nat) : Int)
    rw [h1, h2]
    show ((fib (k+2) : Nat) : Int) + 1 * ((fib (k+1) : Nat) : Int) = ((fib (k+3) : Nat) : Int)
    omega

/-- Consequence: the ceiling is ATTAINED, so the bound is sharp. -/
theorem ceiling_sharp (n : Nat) : (run plus n).2.natAbs = fib (n+2) := by
  rw [(plus_is_fib n).2]; simp

theorem plus_is_signs : Signs plus := fun _ => Or.inl rfl

#print axioms step_bound
#print axioms run_bound
#print axioms plus_is_fib
#print axioms ceiling_sharp
