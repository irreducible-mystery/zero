/- Where each named gap BECOMES the critical gap. Kernel-checked by decide. -/

-- CHARACTERISTIC 5: the golden gap G = 1 IS the collision.
theorem disc_vanishes_char5 : (1 : Fin 5) + 4 * 1 = 0 := by decide
theorem golden_is_double_root_char5 : ∀ x : Fin 5, x * x = x + 1 ↔ x = 3 := by decide
theorem char5_root_count :
    (List.filter (fun x : Fin 5 => x * x == x + 1) [0,1,2,3,4]).length = 1 := by decide

-- CHARACTERISTIC 3: the gap G = -1 is the collision.
theorem disc_vanishes_char3 : (1 : Fin 3) + 4 * 2 = 0 := by decide
theorem neg_one_is_double_root_char3 : ∀ x : Fin 3, x * x = x + 2 ↔ x = 2 := by decide

-- CHARACTERISTIC 17: 4 squares to -1, and G = 4 is the collision.
theorem four_is_sqrt_neg_one_char17 : (4 : Fin 17) * 4 = 16 := by decide
theorem sixteen_is_neg_one_char17 : (16 : Fin 17) + 1 = 0 := by decide
theorem disc_vanishes_char17 : (1 : Fin 17) + 4 * 4 = 0 := by decide
theorem i_is_double_root_char17 : ∀ x : Fin 17, x * x = x + 4 ↔ x = 9 := by decide

-- ...and the OTHER square root of -1 is NOT critical. The two differ.
theorem thirteen_is_sqrt_neg_one_char17 : (13 : Fin 17) * 13 = 16 := by decide
theorem disc_nonzero_at_minus_i_char17 : (1 : Fin 17) + 4 * 13 ≠ 0 := by decide
theorem minus_i_splits_char17 :
    (List.filter (fun x : Fin 17 => x * x == x + 13)
      [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]).length = 2 := by decide

-- CHARACTERISTIC 2: the map is additive, no double root ever exists.
theorem char2_additive : ∀ x : Fin 2, x * x + x = 0 := by decide
theorem char2_only_zero_gap_reachable :
    ∀ G : Fin 2, (∃ x : Fin 2, x * x = x + G) ↔ G = 0 := by decide
theorem char2_reachable_gap_has_two_roots :
    (List.filter (fun x : Fin 2 => x * x == x + 0) [0,1]).length = 2 := by decide

-- CONTROL: in characteristic 7 the golden gap has NO roots at all.
theorem char7_golden_has_no_roots : ¬ ∃ x : Fin 7, x * x = x + 1 := by decide
theorem char7_disc_nonzero : (1 : Fin 7) + 4 * 1 ≠ 0 := by decide

#print axioms golden_is_double_root_char5
#print axioms i_is_double_root_char17
#print axioms minus_i_splits_char17
#print axioms char2_only_zero_gap_reachable
#print axioms char7_golden_has_no_roots
