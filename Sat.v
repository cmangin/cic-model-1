Require Import Lambda.

(** A somehow abstract interface to work with reducibility candidates
    or saturated sets.
 *)

Set Implicit Arguments.

(** * Theory of saturated sets *)

Module Type SAT.
  (** The type of "saturated sets" and basic relations: equality and membership *)
  Parameter SAT : Type.
  Parameter eqSAT : SAT -> SAT -> Prop.
  Parameter inSAT : term -> SAT -> Prop.
  Parameter eqSAT_def : forall X Y,
    eqSAT X Y <-> (forall t, inSAT t X <-> inSAT t Y).
  Definition inclSAT A B := forall t, inSAT t A -> inSAT t B.

  Parameter inSAT_morph : Proper ((@eq term) ==> eqSAT ==> iff) inSAT.

  (** Essential properties of saturated sets :
      - they are sets of SN terms
      - they are closed by head expansion
   *)
  Parameter sat_sn : forall t S, inSAT t S -> sn t.
  Parameter inSAT_exp : forall S u m,
    boccur 0 m = true \/ sn u ->
    inSAT (subst u m) S ->
    inSAT (App (Abs m) u) S.

  (** A term that belongs to all saturated sets (e.g. variables) *)
  Parameter daimon : term.
  Parameter varSAT : forall S, inSAT daimon S.

  (** Closure properties are preserved by head contexts *)
  Parameter inSAT_context : forall u u' v,
    (forall S, inSAT u S -> inSAT u' S) ->
    forall S, inSAT (App u v) S -> inSAT (App u' v) S.

  (** The set of strongly normalizing terms *)
  Parameter snSAT : SAT.
  Parameter snSAT_intro : forall t, sn t -> inSAT t snSAT.

  (** Non-depenent products *)
  Parameter prodSAT : SAT -> SAT -> SAT.
  Parameter prodSAT_morph : Proper (eqSAT ==> eqSAT ==> eqSAT) prodSAT.
  Parameter prodSAT_intro : forall A B m,
    (forall v, inSAT v A -> inSAT (subst v m) B) ->
    inSAT (Abs m) (prodSAT A B).
  Parameter prodSAT_elim : forall A B u v,
    inSAT u (prodSAT A B) ->
    inSAT v A ->
    inSAT (App u v) B.

  (** Intersection *)
  Parameter interSAT : forall A:Type, (A -> SAT) -> SAT.
  Parameter interSAT_morph : forall A A' (F:A->SAT) (G:A'->SAT),
    indexed_relation eqSAT F G ->
    eqSAT (interSAT F) (interSAT G).
  Parameter interSAT_intro : forall A F u,
    A ->
    (forall x:A, inSAT u (F x)) ->
    inSAT u (interSAT F).
  Parameter interSAT_elim : forall A F u,
    inSAT u (interSAT F) ->
    forall x:A, inSAT u (F x).

  Existing Instance inSAT_morph.
  Existing Instance prodSAT_morph.

End SAT.

(** * Instantiating this signature with Girard's reducibility candidates *)

Require Import Can.

Module SatSet <: SAT.

  Definition SAT := {P:term->Prop|is_cand P}.
  Definition inSAT t (S:SAT) := proj1_sig S t.
  Definition eqSAT X Y := forall t, inSAT t X <-> inSAT t Y.
  Lemma eqSAT_def : forall X Y,
    eqSAT X Y <-> (forall t, inSAT t X <-> inSAT t Y).
reflexivity.
Qed.

  Instance inSAT_morph : Proper ((@eq term) ==> eqSAT ==> iff) inSAT.
do 3 red; intros; unfold inSAT.
rewrite H.
exact (H0 y).
Qed.

  Definition inclSAT A B := forall t, inSAT t A -> inSAT t B.

  Global Instance inclSAT_ord : PreOrder inclSAT.
split; red; intros.
 red; trivial.

 red; intros; auto.
Qed.


  Lemma sat_sn : forall t S, inSAT t S -> sn t.
destruct S; simpl; intros.
apply (incl_sn _ i); trivial.
Qed.

  Definition daimon := Ref 0.

  Lemma varSAT : forall S, inSAT daimon S.
destruct S; simpl; intros.
apply var_in_cand with (1:=i).
Qed.

  Lemma inSAT_exp : forall S u m,
    boccur 0 m = true \/ sn u ->
    inSAT (subst u m) S ->
    inSAT (App (Abs m) u) S.
destruct S; simpl; intros.
apply cand_sat with (X:=x); trivial.
Qed.

  Lemma inSAT_context : forall u u' v,
    (forall S, inSAT u S -> inSAT u' S) ->
    forall S, inSAT (App u v) S -> inSAT (App u' v) S.
destruct S; simpl; intros.
apply cand_context with (X:=x) (u:=u); trivial; intros.
apply (H (exist _ X H1)); trivial.
Qed.



  Definition snSAT : SAT := exist _ sn cand_sn.

  Lemma snSAT_intro : forall t, sn t -> inSAT t snSAT.
do 3 red; trivial.
Qed.

  Definition prodSAT (X Y:SAT) : SAT.
(*begin show*)
exists (Arr (proj1_sig X) (proj1_sig Y)).
(*end show*)
apply is_cand_Arr; apply proj2_sig.
Defined.

  Lemma prodSAT_intro : forall A B m,
    (forall v, inSAT v A -> inSAT (subst v m) B) ->
    inSAT (Abs m) (prodSAT A B).
intros (A,A_can) (B,B_can) m in_subst; simpl in *.
apply Abs_sound_Arr; auto.
Qed.

  Lemma prodSAT_elim : forall A B u v,
    inSAT u (prodSAT A B) ->
    inSAT v A ->
    inSAT (App u v) B.
intros (A,A_can) (B,B_can) u v u_in v_in; simpl in *.
red in u_in.
auto.
Qed.

  Instance prodSAT_morph : Proper (eqSAT ==> eqSAT ==> eqSAT) prodSAT.
do 3 red; intros.
destruct x; destruct y; destruct x0; destruct y0;
  unfold prodSAT, eqSAT in *; simpl in *; intros.
apply eq_can_Arr; trivial.
Qed.

  Instance prodSAT_mono : Proper (inclSAT --> inclSAT ++> inclSAT) prodSAT.
do 4 red; intros.
intros u satu.
apply H0.
apply prodSAT_elim with (1:=H1); auto.
Qed.

  Definition interSAT (A:Type) (F:A -> SAT) : SAT :=
    exist _ (Inter A (fun x => proj1_sig (F x)))
      (is_can_Inter _ _ (fun x => proj2_sig (F x))).

  Lemma interSAT_morph : forall A A' (F:A->SAT) (G:A'->SAT),
    indexed_relation eqSAT F G ->
    eqSAT (interSAT F) (interSAT G).
intros A A' F G sim_FG.
unfold eqSAT, interSAT; simpl.
apply eq_can_Inter; trivial.
Qed.

  Lemma interSAT_intro : forall A F u,
    A ->
    (forall x:A, inSAT u (F x)) ->
    inSAT u (interSAT F).
unfold inSAT, interSAT, Inter; simpl; intros.
split; intros; trivial.
apply (incl_sn _ (proj2_sig (F X))); trivial.
Qed.

Lemma interSAT_intro' : forall A (P:A->Prop) F t,
  sn t ->
  (forall x, P x -> inSAT t (F x)) ->
  inSAT t (interSAT (fun p:sig P => F (proj1_sig p))).
split; trivial.
destruct x; simpl.
apply H0; trivial.
Qed.

  Lemma interSAT_elim : forall A F u,
    inSAT u (interSAT F) ->
    forall x:A, inSAT u (F x).
unfold inSAT, interSAT, Inter; simpl; intros.
destruct H; trivial.
Qed.

  Lemma interSAT_mono A (F G:A->SAT):
    (forall x, inclSAT (F x) (G x)) ->
    inclSAT (interSAT F) (interSAT G).
red; intros.
split; intros.
 apply sat_sn in H0; trivial.
apply H.
apply interSAT_elim with (1:=H0).
Qed.

End SatSet.

Export SatSet.

(** Derived facts *)

Instance eqSAT_equiv : Equivalence eqSAT.
split; red; intros.
 rewrite eqSAT_def; reflexivity.
 rewrite eqSAT_def in H|-*; symmetry; trivial.
 rewrite eqSAT_def in H,H0|-*; intros;
   transitivity (inSAT t y); trivial.
Qed.

Lemma interSAT_morph_subset :
  forall A (P Q:A->Prop) (F:sig P->SAT) (G:sig Q->SAT),
  (forall x, P x <-> Q x) ->
  (forall x Px Qx,
   eqSAT (F (exist P x Px)) (G (exist Q x Qx))) ->
  eqSAT (interSAT F) (interSAT G).
intros.
apply interSAT_morph; red; split; intros.
 destruct x; simpl.
 exists (exist Q x (proj1 (H x) p)); auto.

 destruct y; simpl.
 exists (exist P x (proj2 (H x) q)); auto.
Qed.

  Lemma KSAT_intro : forall A t m,
    sn t ->
    inSAT m A ->
    inSAT (App2 K m t) A.
intros.
apply prodSAT_elim with snSAT.
2:apply snSAT_intro; trivial.
apply prodSAT_elim with A; trivial.
apply prodSAT_intro; intros.
unfold subst; simpl subst_rec.
apply prodSAT_intro; intros.
unfold subst; rewrite simpl_subst; trivial.
rewrite lift0; trivial.
Qed.

  Lemma SAT_daimon1 : forall S u,
    sn u ->
    inSAT (App daimon u) S.
destruct S; simpl; intros.
apply (sat1_in_cand 0 x); trivial.
Qed.

(** Dependent product *)
(** The realizability relation of a dependent product.
   It is the intersection of all reducibility candidates {x}F -> {f(x)}G(x)
   when x ranges A. *)
Definition piSAT0 A B (F:A->SAT) (G:A->B->SAT) (f:A->B) :=
  interSAT (fun x => prodSAT (F x) (G x (f x))).

Lemma piSAT0_intro : forall A B F G (f:A->B) t,
  sn t -> (* if A is empty *)
  (forall x u, inSAT u (F x) -> inSAT (App t u) (G x (f x))) ->
  inSAT t (piSAT0 F G f).
unfold piSAT0; intros.
split; intros; trivial.
intros ? ?.
apply H0; trivial.
Qed.

Lemma piSAT0_elim : forall A B F G (f:A->B) x t u,
  inSAT t (piSAT0 F G f) ->
  inSAT u (F x) ->
  inSAT (App t u) (G x (f x)).
intros.
apply interSAT_elim with (x:=x) in H.
apply H; trivial.
Qed.
