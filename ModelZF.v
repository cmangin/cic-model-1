Require Import basic.
Require Import Sublogic.
Require Import Models GenModelSyntax.
Require Import ZF ZFcoc.

(** Set-theoretical model of the Calculus of Constructions in IZF *)

(** * Instantiation of the abstract model of CC *)

Module CCM <: CC_Model.

Definition X := set.
Definition inX : X -> X -> Prop := in_set.
Definition eqX : X -> X -> Prop := eq_set.
Definition eqX_equiv : Equivalence eqX := eq_set_equiv.
Notation "x ∈ y" := (inX x y).
Notation "x == y" := (eqX x y).

Lemma in_ext: Proper (eqX ==> eqX ==> iff) inX.
Proof in_set_morph.

Definition props : X := props.
Definition app : X -> X -> X := cc_app.
Definition lam : X -> (X -> X) -> X := cc_lam.
Definition prod : X -> (X -> X) -> X := cc_prod.

Definition eq_fun (x:X) (f1 f2:X->X) :=
  forall y1 y2, y1 ∈ x -> y1 == y2 -> f1 y1 == f2 y2.

Lemma lam_ext :
  forall x1 x2 f1 f2,
  x1 == x2 ->
  eq_fun x1 f1 f2 ->
  lam x1 f1 == lam x2 f2.
Proof.
intros.
apply cc_lam_ext; intros; trivial.
Qed.

Lemma app_ext:
  forall x1 x2 : X, x1 == x2 ->
  forall x3 x4 : X, x3 == x4 ->
  app x1 x3 == app x2 x4.
Proof cc_app_morph.

Lemma prod_ext :
  forall x1 x2 f1 f2,
  x1 == x2 ->
  eq_fun x1 f1 f2 ->
  prod x1 f1 == prod x2 f2.
Proof.
intros.
apply cc_prod_ext; intros; trivial.
Qed.

Lemma prod_intro : forall dom f F,
  eq_fun dom f f ->
  eq_fun dom F F ->
  (forall x, x ∈ dom -> f x ∈ F x) ->
  lam dom f ∈ prod dom F.
Proof cc_prod_intro.

Lemma prod_elim : forall dom f x F,
  eq_fun dom F F ->
  f ∈ prod dom F ->
  x ∈ dom ->
  app f x ∈ F x.
Proof fun dom f x F _ H H0 => cc_prod_elim dom f x F H H0.


Lemma impredicative_prod : forall dom F,
  eq_fun dom F F ->
  (forall x, x ∈ dom -> F x ∈ props) ->
  prod dom F ∈ props.
Proof fun dom F _ => cc_impredicative_prod dom F.

Lemma beta_eq:
  forall dom F x,
  eq_fun dom F F ->
  x ∈ dom ->
  app (lam dom F) x == F x.
Proof cc_beta_eq.

End CCM.

(** * Instantiating the generic model construction *)

Module BuildModel := MakeModel(CCM).

Import BuildModel T J R.

Lemma El_int_arr T U i :
  int (Prod T (lift 1 U)) i == cc_arr (int T i) (int U i).
simpl.
apply cc_prod_ext.
 reflexivity.

 red; intros.
 rewrite simpl_int_lift.
 rewrite lift0_term; reflexivity.
Qed.
(** Subtyping *)

(*
Definition sub_typ_covariant : forall e U1 U2 V1 V2,
  U1 <> kind ->
  eq_typ e U1 U2 ->
  sub_typ (U1::e) V1 V2 ->
  sub_typ e (Prod U1 V1) (Prod U2 V2).
intros.
apply sub_typ_covariant; trivial.
intros.
unfold eqX, lam, app.
unfold inX in H2.
unfold prod, ZFuniv_real.prod in H2; rewrite El_def in H2.
apply cc_eta_eq in H2; trivial.
Qed.
*)

(** Universes *)
(*
Lemma cumul_Type : forall e n, sub_typ e (type n) (type (S n)).
red; simpl; intros.
red; intros.
apply ecc_incl; trivial.
Qed.

Lemma cumul_Prop : forall e, sub_typ e prop (type 0).
red; simpl; intros.
red; intros.
apply G_trans with props; trivial.
 apply (grot_succ_typ gr).

 apply (grot_succ_in gr).
Qed.
*)


(** The model in ZF implies the consistency of CC *)

Require Import Term Env.
Require Import TypeJudge.
Load "template/Library.v".

Lemma cc_consistency : forall M M', ~ eq_typ nil M M' FALSE.
Proof.
unfold FALSE; red in |- *; intros.
specialize BuildModel.int_sound with (1 := H); intro.
destruct H0 as (H0,_).
red in H0; simpl in H0.
setoid_replace (CCM.prod CCM.props (fun x => x)) with empty in H0.
 eapply empty_ax; apply H0 with (i:=fun _ => empty).
 red; intros.
 destruct n; discriminate.

 apply empty_ext; red; intros.
 assert (empty ∈ props) by
   (unfold props; apply empty_in_power).
 specialize cc_prod_elim with (1:=H1) (2:=H2); intro.
 apply empty_ax with (1:=H3).
Qed.

(*begin hide*)
Module TypChoice (C : Choice_Sig CoqSublogicThms IZF).

Import C.
Import BuildModel.
Import CCM.
Import T J R.

Require Import ZFrepl.

Definition CH_spec a f1 f2 z :=
     a == empty /\ z == app f2 (lam empty (fun _ => empty))
  \/ (exists w, w ∈ a) /\ z == app f1 (choose a).

Parameter CH_spec_u : forall a f1 f2, uchoice_pred (CH_spec a f1 f2).

Definition CH : term.
left; exists (fun i => uchoice (CH_spec (i 3) (i 1) (i 0))).
admit.
Defined.

(* forall X, X + (X->False) is inhabited *)
Lemma typ_choice :
  typ
    ((*f1*)Prod (Prod (*X*)(Ref 2) (Prod prop (Ref 0))) (*P*)(Ref 2) ::
     (*f2*)Prod (*X*)(Ref 1) (*P*)(Ref 1) ::
     (*P*)kind::(*X*)kind::nil)
    CH (*P*)(Ref 2).
red; simpl; intros.
generalize (H 0 _ (eq_refl _)); simpl; unfold V.lams, V.shift; simpl; intros.
generalize (H 1 _ (eq_refl _)); simpl; unfold V.lams, V.shift; simpl; intros.
clear H.
set (P := i 2) in *; clearbody P.
set (Y := i 3) in *; clearbody Y.
generalize (uchoice_def _ (CH_spec_u Y (i 1) (i 0))).
set (w := uchoice (CH_spec Y (i 1) (i 0))) .
clearbody w; unfold CH_spec; intros.
destruct H.
 destruct H.
 rewrite H2.
 refine (prod_elim _ _ _ _ _ H0 _).
  admit.
 apply eq_elim with (prod empty (fun _ => prod props (fun P=>P))).
  apply prod_ext.
   auto with *.

   red; reflexivity.
 apply prod_intro; intros.
  admit.
  admit.
 elim empty_ax with x; trivial.

 destruct H.
 rewrite H2.
 refine (prod_elim _ _ _ _ _ H1 _).
  admit.
 apply choose_ax; trivial.
Qed.

End TypChoice.
(*end hide*)