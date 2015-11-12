
Definition pierce := forall (p q: Prop), ((p -> q) -> p) -> p.
Definition lem := forall (p: Prop), p \/ ~ p.
Theorem peirce_equiv_lem : pierce <-> lem.
Proof.  
  unfold pierce, lem.
  firstorder.  

  apply H with (q := ~(p\/~p)).
  tauto.
  destruct (H p).
  assumption.
  tauto.
  

  
  