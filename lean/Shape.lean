/- Where the solution set changes SHAPE rather than size, and the reflexive
   condition that singles out the golden gap. -/

def IsRoot (G x : Int) : Prop := x * x = x + G

/-- THE GOLDEN GAP IS THE ONE THAT EQUALS THE SUM OF WHAT IT PRODUCES.
    The sum of two distinct roots is 1 for every gap, so demanding that the
    gap equal that sum has exactly one answer. -/
theorem gap_eq_sum_iff (G x y : Int) (hx : IsRoot G x) (hy : IsRoot G y)
    (hne : x ≠ y) : (G = x + y) ↔ G = 1 := by
  unfold IsRoot at hx hy
  have key : (x - y) * (x + y - 1) = 0 := by
    have e : (x - y) * (x + y - 1) = (x*x - y*y) - (x - y) := by
      simp [Int.mul_sub, Int.mul_add, Int.mul_comm]; omega
    rw [e, hx, hy]; omega
  have hxy : x - y ≠ 0 := by omega
  have hs : x + y = 1 := by
    rcases Int.mul_eq_zero.mp key with h | h
    · exact absurd h hxy
    · omega
  constructor <;> intro h <;> omega

/-- SHAPE CHANGE. Over Z/2 the equation x*x = x has exactly ONE solution set
    shape; over Z/8 the number of square roots of 1 is FOUR, not two, so the
    same algebraic condition describes a different-sized set. -/
theorem sq_one_Fin2 :
    (List.filter (fun z : Fin 2 => z * z == 1) [0,1]).length = 1 := by decide
theorem sq_one_Fin3 :
    (List.filter (fun z : Fin 3 => z * z == 1) [0,1,2]).length = 2 := by decide
theorem sq_one_Fin8 :
    (List.filter (fun z : Fin 8 => z * z == 1)
      [0,1,2,3,4,5,6,7]).length = 4 := by decide

/-- THE CORRECTION THE KERNEL FORCED. I claimed the gap equation inherits the
    four-root shape over Z/8. It does not: `decide` refused it. The gap
    equation's root count over Z/8 is 2 or 0 - exactly as over a domain -
    because x*x - x factors as x*(x-1) with the two factors coprime. The
    four-root shape belongs to x*x = 1, a DIFFERENT equation. -/
def gapRoots8 (G : Fin 8) : Nat :=
  (List.filter (fun x : Fin 8 => x * x == x + G) [0,1,2,3,4,5,6,7]).length

theorem gap_root_counts_Fin8 :
    gapRoots8 0 = 2 ∧ gapRoots8 1 = 0 ∧ gapRoots8 2 = 2 ∧ gapRoots8 3 = 0 ∧
    gapRoots8 4 = 2 ∧ gapRoots8 5 = 0 ∧ gapRoots8 6 = 2 ∧ gapRoots8 7 = 0 := by
  decide

/-- So over Z/8 the gap equation NEVER exceeds the degree bound, even though the
    ring is not a domain and x*x = 1 does exceed it there. -/
theorem gap_never_exceeds_degree_Fin8 : ∀ G : Fin 8, gapRoots8 G ≤ 2 := by decide

/-- Exactly half the gaps are reachable, and every reachable one has two roots:
    the same PARITY structure characteristic 2 shows, appearing again at 8. -/
theorem half_the_gaps_reachable_Fin8 :
    (List.filter (fun G : Fin 8 => gapRoots8 G != 0) [0,1,2,3,4,5,6,7]).length = 4 := by
  decide

#print axioms gap_eq_sum_iff
#print axioms sq_one_Fin8
#print axioms gap_root_counts_Fin8
#print axioms gap_never_exceeds_degree_Fin8
#print axioms half_the_gaps_reachable_Fin8
