

(* Nat *)
Set Implicit Arguments.

Require Import ZF ZFord ZFcoc ZFind_nat.
Import IZF.

Require Import basic Can Sat SATnat GenRealSN.
Module Lc:=Lambda.
Require Import SN_CC_Real.


(* Ordinals *)

Parameter Ord : trm.

Parameter typ_ord_inv : forall e o i j,
  typ e o Ord ->
  val_ok e i j ->
  isOrd (int i o).
Hint Resolve typ_ord_inv.

Parameter OInfty : trm.

Parameter OSucc : trm -> trm.

Parameter osucc_inv : forall i o k,
  inclSAT (fNAT (cNATi (int i o)) k) (cNATi (int i (OSucc o)) k).

Parameter osucc_inv2 : forall e i j o,
  typ e o Ord ->
  val_ok e i j ->
  int i (OSucc o) \incl osucc (int i o).

(*Parameter OSucc_infty : eq_trm (OSucc OInfty) OInfty.*)

(*
Definition Ord (o:set) := @cst o Lc.K (fun _ _ => eq_refl _) (fun _ _ _ => eq_refl _).
(*
Definition typ_ord_kind : forall e o, typ e (Ord o) kind.
red; simpl; intros.
split; simpl.
 discriminate.

 split; auto 
trivial.
Qed.

Definition typ_ord_ord : forall e o o',
  lt o o' -> typ e (Ord o) (Ord o').
red; simpl; intros; trivial.
Qed.
*)

Definition OSucc : trm -> trm.
intros o; left; exists (fun i => osucc (int i o)) (fun j => tm j o).
 do 2 red; intros.
 rewrite H; reflexivity.

 do 2 red; intros.
 rewrite H; trivial.

 red; intros.
 apply tm_liftable.

 red; intros.
 apply tm_substitutive.
Defined.
*)

Definition Zero : trm.
left; exists (fun _ => ZERO) (fun _ => ZE).
 do 2 red; reflexivity.

 do 2 red; reflexivity.

 red; reflexivity.

 red; reflexivity.
Defined.


Definition Succ (o:trm): trm.
left; exists (fun i => lam (mkTy NAT (realNati (int i o))) SUCC) (fun _ => SU).
 do 2 red; intros.
 apply lam_ext.
  apply mkTy_morph; auto with *.
  intros.
  rewrite H; reflexivity.

  red; intros.
  rewrite H1; reflexivity.

 do 2 red; auto.

 red; reflexivity.

 red; reflexivity.
Defined.


Definition Nati (o:trm) : trm.
left; exists (fun i => mkTy NAT (realNati (int i o)))
  (fun j => tm j o).
 do 3 red; intros.
 apply mkTy_morph; auto with *.
 intros.
 rewrite H; reflexivity.

 do 2 red; intros.
 rewrite H; reflexivity.

 red; intros.
 apply tm_liftable.

 red; intros.
 apply tm_substitutive.
Defined.


Lemma typ_N : forall e o, typ e o Ord -> typ e (Nati o) kind.
red; red; simpl; intros.
split.
 discriminate.

 split.
  red.
  exists List.nil.
  exists (Nati o).
   reflexivity.

   exists (ZERO, daimon).
   simpl; intros.
   rewrite realNati_def.
   exists ZERO_typ.
   apply varSAT.

  apply H in H0.
  apply in_int_sn in H0; trivial.
Qed.

Lemma typ_0 : forall e o, typ e o Ord -> typ e Zero (Nati (OSucc o)).
red; red; simpl; intros.
split.
 discriminate.

 rewrite realNati_def.
 exists ZERO_typ.
 fold ZEROt.
 assert (forall k, inclSAT (fNAT (cNATi (int i o)) k) (cNATi (int i (OSucc o)) k)).
  intro; apply osucc_inv.
 apply H1.
 apply fNAT_ZE.
(* destruct Ord_inv with (1:=H) (2:=H0) as (H1,[H2|H2]).
  rewrite H2.
  apply (@cNATi_incl_cNAT (osucc empty)); auto with *.
  apply cNATi_ZE; auto.

  rewrite (cNATi_morph H2 (reflexivity _)).
  apply cNATi_ZE; trivial.*)
Qed.

Lemma typ_S : forall e o, typ e o Ord ->
   typ e (Succ o) (Prod (Nati o) (lift 1 (Nati (OSucc o)))).
red; red; simpl; intros.
split.
 discriminate.

 apply prod_intro.
  red; intros.
  rewrite H2; reflexivity.

  red; intros; reflexivity.

  red; red; intros.
  split; intros.
   unfold SU.
   clear H0.
   constructor; intros.
   inversion_clear H0.
   inversion_clear H1.
   inversion_clear H0.
   inversion_clear H1.
    inversion_clear H0.
     inversion H1.
     inversion H1.
    inversion_clear H0.
     inversion_clear H1.
      inversion H0.
      inversion H0.
     inversion H1.

   red; intros.
   rewrite realNati_def in H1|-*.
   destruct H1.
   exists (SUCC_typ _ x0).
   assert (int (V.lams 0 (V.shift 1) (V.cons x i)) (OSucc o) == int i (OSucc o)).
    rewrite V.lams0.
    apply int_morph; auto with *.
    red; red; intros.
    unfold V.shift, V.cons; simpl; reflexivity.
   cut (inSAT (Lc.App SU u) (cNATi (int i (OSucc o)) (mkNat (SUCC_typ _ x0)))).
    apply inSAT_morph; trivial.
    apply cNATi_morph; trivial.
    red; reflexivity.
   assert (oo : isOrd (int i o)) by eauto.
   assert (forall k, inclSAT (fNAT (cNATi (int i o)) k) (cNATi (int i (OSucc o)) k)).
    intro; apply osucc_inv.
   apply H3.
   change (mkNat (SUCC_typ x x0)) with (SUCCt (mkNat x0)).
   apply fNAT_SU; trivial.
   rewrite cNATi_ax in H1.
   apply H1 with (1:=fNAT_posti cNATi_posti).
Qed.

Lemma inSAT_exp_sat2 : forall S m u u1 u2,
  Lc.sn u ->
  inSAT (Lc.App (Lc.App (Lc.subst u m) u1) u2) S ->
  inSAT (Lc.App (Lc.App (Lc.App (Lc.Abs m) u) u1) u2) S.
intros (S,(S_sn,S_red,S_exp)) m u u1 u2 snu inS; simpl in *.
revert m u1 u2 inS.
induction snu; intros.
clear H; rename x into u.
assert (snm: Lc.sn m).
 apply Lc.sn_subst with u.
 apply S_sn in inS.
 apply Lc.subterm_sn with (Lc.App (Lc.subst u m) u1); auto with coc.
 apply Lc.subterm_sn with (1:=inS); auto with coc.
revert u1 u2 inS.
induction snm; intros.
clear H; rename x into m.
assert (snu1: Lc.sn u1).
 apply S_sn in inS.
 apply Lc.subterm_sn with (Lc.App (Lc.subst u m) u1); auto with coc.
 apply Lc.subterm_sn with (1:=inS); auto with coc.
revert u2 inS.
induction snu1; intros.
clear H; rename x into u1.
assert (snu2: Lc.sn u2).
 apply S_sn in inS.
 apply Lc.subterm_sn with (1:=inS); auto with coc.
revert inS.
induction snu2; intros.
clear H; rename x into u2.
unfold transp in *.
apply S_exp; intros.
 exact I.
inversion_clear H.
 inversion_clear H4.
  inversion_clear H; auto.
   inversion_clear H4.
   apply H1; trivial.
   apply S_red with (1:=inS); trivial.
   unfold Lc.subst; auto with coc.

   apply H0; trivial.
   apply S_red with (1:=inS); trivial.
   unfold Lc.subst; auto with coc.

  apply H2; trivial.
  apply S_red with (1:=inS); auto with coc.

 apply H3; trivial.
 apply S_red with (1:=inS); auto with coc.
Qed.

Lemma inSAT_exp_sat1 : forall S m u u1,
  Lc.sn u ->
  inSAT (Lc.App (Lc.subst u m) u1) S ->
  inSAT (Lc.App (Lc.App (Lc.Abs m) u) u1) S.
Admitted.

Lemma inSAT_exp_sat : forall S m u,
  Lc.sn u ->
  inSAT (Lc.subst u m) S ->
  inSAT (Lc.App (Lc.Abs m) u) S.
Admitted.

Definition NMATCH f g n :=
  Lc.App2 n f (Lc.App (Lc.Abs (Lc.Abs (Lc.Abs (Lc.App (Lc.Ref 2) (Lc.Ref 1))))) g).

Lemma inSat_NMATCH f g n x S (P:family) :
  inSAT n (fNAT S x) ->
  inSAT f (P ZEROt) ->
  (forall k x', inSAT k (S x') -> inSAT (Lc.App g k) (P (SUCCt x'))) ->
  inSAT (NMATCH f g n) (P x).
intros.
unfold NMATCH.
apply fNAT_def with (1:=H); intros; trivial.
apply inSAT_exp_sat2.
 apply H1 in H2.
 apply (incl_sn _ (proj2_sig (P (SUCCt n0)))) in H2.
 apply Lc.subterm_sn with (1:=H2); auto with coc.

 unfold Lc.subst; simpl.
 apply inSAT_exp_sat1.
  apply (incl_sn _ (proj2_sig (S n0))) in H2; trivial.

  unfold Lc.subst; simpl.
  rewrite Lc.simpl_subst; auto.
  apply inSAT_exp_sat.
   apply (incl_sn _ (proj2_sig (P n0))) in H3; trivial.

   unfold Lc.subst; simpl.
  rewrite Lc.simpl_subst; auto.
  rewrite Lc.simpl_subst; auto.
  do 2 rewrite Lc.lift0.
  auto.
Qed.

Definition NatCase (f g n:trm) : trm.
left; exists (fun i => NATCASE (int i f) (fun n => app (int i g) n) (int i n))
             (fun j => NMATCH (tm j f) (tm j g) (tm j n)).
 do 2 red; intros.
 apply NATCASE_morph.
  rewrite H; reflexivity.

  red; intros.
  rewrite H; rewrite H0; reflexivity.

  rewrite H; reflexivity.

 do 2 red; intros.
 rewrite H; auto.

 red; intros; simpl.
 repeat rewrite tm_liftable; trivial.

 red; intros; simpl.
 repeat rewrite tm_substitutive; trivial.
Defined.



Lemma typ_Ncase : forall e o n f g P,
  typ e o Ord ->
  typ e n (Nati (OSucc o)) ->
  typ e f (App P Zero) ->
  typ e g (Prod (Nati o) (App (lift 1 P) (App (Succ (lift 1 o)) (Ref 0)))) ->
  typ e (NatCase f g n) (App P n).
red; intros.
red in H0; specialize H0 with (1:=H3).
red in H1; specialize H1 with (1:=H3).
red in H2; specialize H2 with (1:=H3).
unfold in_int in H0,H1,H2|-*; simpl in *.
split;[discriminate|].
destruct H0 as (_,H0).
destruct H1 as (_,H1).
destruct H2 as (_,H2).
set (c := int i n) in *; clearbody c.
set (tc := tm j n) in *; clearbody tc; clear n.
set (f0 := int i f) in *; clearbody f0.
set (b0 := tm j f) in *; clearbody b0; clear f.
set (fS := int i g) in *; clearbody fS.
set (bS := tm j g) in *; clearbody bS; clear g.
set (fS' := fun n :set => app fS n) in |-*.
assert (fsm : morph1 fS').
 do 2 red; intros.
 unfold fS'; rewrite H4; reflexivity.
rewrite realNati_def in H0.
destruct H0.
assert (forall x tx,
 (x,tx) \real mkTy NAT (realNati (int i o))  ->
 (app fS x, Lc.App bS tx) \real app (int i P) (SUCC x)).
 intros.
 refine (let H' := prod_elim _ H2 H4 in _).
  red; intros.
  apply ZFcoc.cc_app_morph.
   rewrite H6; reflexivity.

   apply ZFcoc.cc_app_morph; auto with *.
   apply ZFcoc.cc_lam_ext.
    apply El_morph.
    apply mkTy_morph; auto with *; intros.
    rewrite H6; reflexivity.

    red; intros.
    rewrite H8; reflexivity.
 clear H2.
 apply inSAT_val with (3:=H'); try reflexivity.
 apply ZFcoc.cc_app_morph.
  unfold lift; rewrite int_lift_rec_eq.
  apply int_morph; try reflexivity.
  red; red; intros.
  destruct a as [|[|a]]; simpl; reflexivity.

  apply beta_eq with tx; trivial.
   red; intros.
   rewrite H5; reflexivity.

   rewrite realNati_def in H4|-*.
   destruct H4.
   exists x1.
   revert H2; apply inSAT_morph; trivial.
   apply cNATi_morph.
   2:red; reflexivity.
   apply int_cons_lift_eq.
assert (forall x:num, is_cand (fun t => (NATCASE f0 fS' x, t) \real app (int i P) x)).
 destruct x0 as (x0,xnat); simpl; intros.
 intros.
 elim xnat using NAT_ind; intros.
  revert H7; apply is_cand_morph.
  red; intros.
  apply in_ext.
   split; simpl; trivial.
   apply NATCASE_morph; auto with *.

   rewrite H6; reflexivity.

  apply inSAT_CR with b0.
  apply inSAT_val with (3:=H1); try reflexivity.
  rewrite NATCASE_ZERO; reflexivity.

  apply inSAT_CR with (Lc.App bS daimon).
  apply inSAT_val with (fS' n) (app (int i P) (SUCC n)); try reflexivity.
   rewrite NATCASE_SUCC; auto with *.

   apply H4; trivial.
   rewrite realNati_def.
   exists H5; apply varSAT.
pose (F:=fun x => exist _ _ (H5 x) :SAT).
assert (Fm : forall x y, eqnum x y -> eqSAT (F x) (F y)).
 intros.
 unfold F.
 red; simpl; intros.
 apply in_ext.
  split; simpl; trivial.
  apply NATCASE_morph; auto with *.

  red in H6; rewrite H6; reflexivity.
change (inSAT (NMATCH b0 bS tc) ((mkFam F Fm ) (mkNat x))).
apply inSat_NMATCH with (S:=cNATi (int i o)); trivial.
 rewrite cNATi_ax in H0.

 admit.

 simpl.
 apply inSAT_val with (3:= H1); auto with *.
 symmetry; apply NATCASE_ZERO.

 intros; simpl.
 apply inSAT_val with (fS' x') (app (int i P) (SUCC x')); auto with *.
  symmetry; apply NATCASE_SUCC.
  intros.
  rewrite H7; reflexivity.

  apply H4.
  rewrite realNati_def.
  red.
  exists (is_num x').
  destruct x'; trivial.


  rewrite (cNATi_def k o' x') in H7.

     assert (o' \incl int i o).
      apply olts_le.
      revert H0; apply osucc_inv2 with (1:=H)(2:=H3).
     rewrite (cNATi_def m o' n) in H7.
     rewrite (cNATi_def m (int i o) (mkNat (is_num n))).
     destruct H7.
     exists x0; auto.
     destruct n; trivial.
Qed.


  apply H5.
 simpl inSAT; intros.
 (P:=mkFam F Fm) (x:=mkNat x).

rewrite fNAT_def in H4.
apply H4 with (P:=mkFam _ Fm) (f:=b0)
     (g:=Lc.App (Lc.Abs (Lc.Abs (Lc.Abs (Lc.App (Lc.Ref 2) (Lc.Ref 1))))) bS).
 simpl.
 apply inSAT_val with (3:=H1); try reflexivity.
 rewrite NATCASE_ZERO; reflexivity.

 intros.
 simpl.
 apply inSAT_val with (fS' n) (app (int i P) (SUCC n)); try reflexivity.
  rewrite NATCASE_SUCC; auto with *.

  apply inSAT_exp_sat2.
   apply inSAT_sn with (1:=H2).

   unfold Lc.subst; simpl.
   apply inSAT_exp_sat1.
    apply (sat_sn _ _ H7).

    unfold Lc.subst; simpl.
    rewrite Lc.simpl_subst; auto.
    apply inSAT_exp_sat.
     apply (sat_sn _ _ H8).

     unfold Lc.subst; simpl.
     repeat rewrite Lc.simpl_subst; auto.
     repeat rewrite Lc.lift0.
     apply H5.
     rewrite realNati_def.
     red.
     exists (is_num n).
     assert (o' \incl int i o).
      apply olts_le.
      revert H0; apply osucc_inv2 with (1:=H)(2:=H3).
     rewrite (cNATi_def m o' n) in H7.
     rewrite (cNATi_def m (int i o) (mkNat (is_num n))).
     destruct H7.
     exists x0; auto.
     destruct n; trivial.
Qed.


Definition natg :=
  Lc.Abs (Lc.Abs (Lc.Abs
     (Lc.App2 (Lc.Ref 0)
        (Lc.App2 (Lc.Ref 2) (Lc.Ref 1) (Lc.Ref 0))
        (Lc.Abs (Lc.Abs (Lc.App2 (Lc.Ref 4) (Lc.Ref 3) (Lc.Ref 2))))))).

Definition natfix :=
  Lc.Abs
    (Lc.App
       (Lc.Abs (Lc.App (Lc.Ref 1) (Lc.App2 natg (Lc.Ref 0) (Lc.Ref 0))))
       (Lc.Abs (Lc.App (Lc.Ref 1) (Lc.App2 natg (Lc.Ref 0) (Lc.Ref 0))))).

Definition NatFix (O M:trm) : trm.
left.
exists (fun i =>
  NATREC (fun o' f => int (V.cons f (V.cons o' i)) M) (int i O))
  (fun j => Lc.App natfix (Lc.Abs (tm (ilift (I.cons (tm j O) j)) M))).
 admit.
 admit.
 admit.
 admit.
Defined.

Require Import List.
Lemma typ_Fix : forall e O M U,
  typ e O Ord ->
  typ (Prod (Nati (Ref 0)) (App (App (lift 2 U) (Ref 1)) (Ref 0)) :: OSucc O :: e)
    M
    (Prod (Nati (OSucc (Ref 0))) (App (App (lift 3 U) (OSucc (Ref 2))) (Ref 0))) ->
  typ e (NatFix O M) (Prod (Nati O) (App (lift 1 (App U O)) (Ref 0))).
red; red; simpl; intros e O M U tyO tyM i j v_ok.
specialize typ_ord_inv with (1:=tyO) (2:=v_ok); intro Oo.
split.
 discriminate.
set (g := fun o' f :set => int (V.cons f (V.cons o' i)) M) in |-*.
apply inSAT_val with
  (g (int i O) (NATREC g (int i O)))
  (MM.prod (NATi (int i O)) (MM.app (int i U) (int i O)).








rewrite prod_def.
split.
 admit.

 red; intros.
 red; simpl.
 split.
  admit.
 red; intros.
 apply inSAT_val with
   (MM.app (g (int i O) (NATREC g (int i O))) x)
   (MM.app (MM.app (int i U) (int i O)) x).
  admit.
  admit.

  unfold natfix.
 apply inSAT_exp_sat1 .
  admit.
assert (sapp : 
  forall m n u, Lc.subst u (Lc.App m n) = Lc.App (Lc.subst u m) (Lc.subst u n)).
 intros.
 reflexivity.
rewrite sapp.
unfold Lc.subst at 1.
simpl.
 apply inSAT_exp_sat1.
  admit.
 rewrite sapp.
 unfold Lc.subst at 1.
 rewrite simpl_subst.
 rewrite Lc.lift0.
 apply inSAT_exp_sat1.
  admit.
 rewrite <- tm_subst_cons.
red in tyM.
red in tyM.
simpl in tyM.

 unfold Lc.subst; simpl.
simpl.
 unfold ilift at 2.
assert (sapp : 
  forall m n u, Lc.subst u (Lc.App m n) = Lc.App (Lc.subst u m) (Lc.subst u n)).
 intros.
 reflexivity.

 unfold Lc.subst; simpl.
 unfold Lc.lift; simpl.


   red in tyM; specialize tyM with (1:=H3).
   red in tyM; simpl in tyM.
   destruct tyM as (_,tyM).
   rewrite prod_def in tyM.
   destruct tyM as (tyM,_).
   apply eq_elim with (2:=tyM).
   symmetry.
   apply cc_prod_ext.
    admit. (* ... *)

    red; intros.
    do 2 (rewrite split_lift; rewrite int_cons_lift_eq).
    rewrite int_cons_lift_eq.
    admit.

  admit.

  admit.

  admit.

  apply cc_app_morph; auto with *.
  rewrite V.lams0.
  unfold V.shift; simpl.
  apply cc_app_morph; auto with *.
   apply int_morph; auto with *.
   red; red; simpl; reflexivity.

   apply int_morph; auto with *.
   red; red; simpl; reflexivity.

Lemma inSAT_exp_fx : forall x A m u,
  Lc.sn u ->
  (x,Lc.App2 m (Lc.App FX m) (Lc.Abs u)) \real A ->
  (x,Lc.App2 FX m (Lc.Abs u)) \real A. 
Admitted.

assert (val_ok (Prod (Nati (Ref 0)) (App (App (lift 2 U) (Ref 1)) (Ref 0))
           :: OSucc O :: e)
  (V.cons (NATREC g (int i O)) (V.cons (int i O) i))
  (I.cons (Lc.App FX (Lc.Abs (tm (ilift (I.cons (tm j O) j)) M)))
    (I.cons (tm j O) j))).
 admit.
red in tyM; specialize tyM with (1:=H0).
red in tyM; simpl in tyM.
destruct tyM as (_,tyM).
fold (g (int i O) (NATREC g (int i O))) in tyM.
apply prod_elim with (F:=fun x => MM.app (MM.app (int i U) (int i O)) x)
 (dom := mkTy NAT (realNati (int i O))); trivial.
 red; intros.
 rewrite H2; reflexivity.

 


 apply inSAT_exp with daimon.
  admit.

  exact I.

  intros.



  assert
inversion H0.
admit.
  red; simpl.




(* Old style *)

Parameter FX : Lc.term.

Parameter FX_red : forall m u,
  Lc.red1 (Lc.App2 FX m (Lc.Abs u)) (Lc.App2 m (Lc.App FX m) (Lc.Abs u)).

(*
Parameter FX_sat :
  inSAT (Lc.App2 m (Lc.App FX m) (Lc.Abs u)) S ->
  inSAT (Lc.
*)

Definition NatFix (O M:trm) : trm.
left.
exists (fun i =>
  NATREC (fun o' f => int (V.cons f (V.cons o' i)) M) (int i O))
  (fun j => Lc.App FX (Lc.Abs (tm (ilift (I.cons (tm j O) j)) M))).
 admit.
 admit.
 admit.
 admit.
Defined.

Import List.
Lemma typ_Fix : forall e O M U,
  typ e O Ord ->
  typ (Prod (Nati (Ref 0)) (App (App (lift 2 U) (Ref 1)) (Ref 0)) :: OSucc O :: e)
    M
    (Prod (Nati (OSucc (Ref 0))) (App (App (lift 3 U) (OSucc (Ref 2))) (Ref 0))) ->
  typ e (NatFix O M) (Prod (Nati O) (App (lift 1 (App U O)) (Ref 0))).
red; red; simpl; intros e O M U tyO tyM i j v_ok.
specialize typ_ord_inv with (1:=tyO) (2:=v_ok); intro oo.
split.
 discriminate.
rewrite prod_def.
split.
 admit.

 red; intros.
 red; simpl.
 split.
  admit. (* FX M is sn (because nf) *)
 red; intros.
 set (g := fun o' f :set => int (V.cons f (V.cons o' i)) M) in |-*.
 apply inSAT_val with
   (MM.app (g (int i O) (NATREC g (int i O))) x)
   (MM.app (MM.app (int i U) (int i O)) x).
  symmetry.
  apply NATREC_expand with (fun o x => El (MM.app (MM.app (int i U) o) x)); trivial.
   admit. (* g morph *)
   admit. (* U mono *)

   intros.
   unfold g.
   assert (val_ok (Prod (Nati (Ref 0)) (App (App (lift 2 U) (Ref 1)) (Ref 0))
         :: OSucc O :: e) (V.cons f (V.cons o i)) (I.cons daimon (I.cons daimon j))).
    apply vcons_add_var; auto.
     apply vcons_add_var; auto.
     2:admit.
     admit.

     simpl.
     rewrite prod_def.
     split.
      apply eq_elim with (2:=H2).
      apply cc_prod_ext.
       apply eq_intro; intros.
        rewrite El_def.
        exists daimon.
        rewrite realNati_def.
        assert (z \in NAT).
         apply NATi_NAT with o; trivial.
        exists H4.
        apply varSAT.

        rewrite El_def in H3.
        destruct H3.
        rewrite realNati_def in H3.
        destruct H3.
        admit. (* z \in NAT & inSAT x0 (cNATi o) -> z \in NATi o ? *)

       red; intros.
       apply El_morph.
       rewrite split_lift.
       rewrite int_cons_lift_eq.
       rewrite int_cons_lift_eq.
       rewrite H4; reflexivity.

      unfold daimon.
      apply var_in_cand with (X:=Pi (mkTy NAT (realNati o))
     (fun x0 : X =>
      MM.app (MM.app (int (V.cons x0 (V.cons o i)) (lift 2 U)) o) x0)
     (fun x0 : X => MM.app f x0)).
      apply is_cand_pi'.
      intros.
      rewrite split_lift.
      rewrite int_cons_lift_eq.
      rewrite int_cons_lift_eq.
      apply cc_prod_elim with (1:=H2).
      rewrite El_def in H3.
      destruct H3.
      admit. (*again *)

      discriminate.

   red in tyM; specialize tyM with (1:=H3).
   red in tyM; simpl in tyM.
   destruct tyM as (_,tyM).
   rewrite prod_def in tyM.
   destruct tyM as (tyM,_).
   apply eq_elim with (2:=tyM).
   symmetry.
   apply cc_prod_ext.
    admit. (* ... *)

    red; intros.
    do 2 (rewrite split_lift; rewrite int_cons_lift_eq).
    rewrite int_cons_lift_eq.
    admit.

  admit.

  admit. (* again *)

  admit.

Lemma inSAT_exp_fx : forall x A m u,
  (x,Lc.App2 m (Lc.App FX m) (Lc.Abs u)) \real A ->
  (x,Lc.App2 FX m (Lc.Abs u)) \real A. 
Admitted.

assert (val_ok (Prod (Nati (Ref 0)) (App (App (lift 2 U) (Ref 1)) (Ref 0))
           :: OSucc O :: e)
  (V.cons (NATREC g (int i O)) (V.cons (int i O) i))
  (I.cons (Lc.App FX (Lc.Abs (tm (ilift (I.cons (tm j O) j)) M)))
    (I.cons (tm j O) j))).
 admit.
red in tyM; specialize tyM with (1:=H0).
red in tyM; simpl in tyM.
destruct tyM as (_,tyM).
fold (g (int i O) (NATREC g (int i O))) in tyM.
apply prod_elim with (F:=fun x => MM.app (MM.app (int i U) (int i O)) x)
 (dom := mkTy NAT (realNati (int i O))); trivial.
 red; intros.
 rewrite H2; reflexivity.

 


 apply inSAT_exp with daimon.
  admit.

  exact I.

  intros.



  assert
inversion H0.
admit.
  red; simpl.



Lemma prod_intro' : forall dom f F t,
  eq_fun dom F F ->
  f \in ZFcoc.cc_prod (El dom) F ->
  Pi dom F (ZFcoc.cc_app f) t ->
  (f, t) \real prod dom F.
Admitted.

apply prod_intro'.
 red; intros.
 rewrite H2.
 reflexivity.

 admit.
(* eapply NATREC_wt.*)

 red; intros.
red; simpl.
split.
 admit.
red; intros.
red in H; simpl in H.

 apply 

replace (NATREC (fun o' f => int (V.cons f (V.cons o' i)) M) (toOrd (int i O)))
 with (lam (NATi (toOrd (int i O))) (fun x =>
         app (F o NATREC
red; simpl.