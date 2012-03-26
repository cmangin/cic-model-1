
Require Export ZF.

(* ordered pairs *)

(* 1- untyped operations *)

Definition couple x y := pair (singl x) (pair x y).

Instance couple_morph : morph2 couple.
unfold couple; do 3 red; intros.
rewrite H; rewrite H0; reflexivity.
Qed.

Lemma union_couple_eq : forall a b, union (couple a b) == pair a b. 
Proof.
intros; unfold couple in |- *; symmetry  in |- *.
apply union_ext; intros.
 elim pair_elim with (1 := H0); intro y_eq;  rewrite y_eq in H.
   rewrite (singl_elim _ _ H); auto.
  trivial.
 elim pair_elim with (1 := H); intro.
  exists (singl a); auto.
    apply singl_intro_eq; auto.
  exists (pair a b); auto.
Qed.

Definition fst p := union (subset (union p) (fun x => singl x ∈ p)).

Instance fst_morph : morph1 fst.
unfold fst; do 2 red; intros.
apply union_morph.
apply subset_morph; intros.
 apply union_morph; trivial.
 split; intro.
   rewrite <- H; trivial.
   rewrite H; trivial.
Qed.

Lemma fst_def : forall x y, fst (couple x y) == x.
Proof.
unfold fst, couple in |- *; intros.
transitivity (union (singl x)).
 apply union_morph.
   apply singl_ext; intros.
  apply subset_intro.
   apply union_intro with (singl x).
    apply singl_intro.
    auto.
   auto.
  elim subset_elim2 with (1 := H); intros.
    rewrite <- H0 in H1.
    clear H0 x0.
    elim pair_elim with (1 := H1); intros.
   apply singl_inj; trivial.
   assert (x ∈ singl z).
    rewrite H0; auto.
     rewrite (singl_elim _ _ H2); reflexivity.
 apply union_singl_eq.
Qed.

Definition snd p :=
  union (subset (union p) (fun z => pair (fst p) z == union p)).

Instance snd_morph : morph1 snd.
Proof.
unfold snd; do 2 red; intros.
apply union_morph.
apply subset_morph; intros.
 apply union_morph; trivial.

 red; intros.
 rewrite H; reflexivity.
Qed.

Lemma snd_def : forall x y, snd (couple x y) == y.
Proof.
intros; unfold snd in |- *.
transitivity (union (singl y)).
 apply union_morph.
   apply singl_ext; intros.
  apply subset_intro.
    rewrite union_couple_eq.
     auto.
    rewrite fst_def.
     symmetry  in |- *.
     apply union_couple_eq.
  elim subset_elim2 with (1 := H); intros.
  rewrite H0.   
  rewrite fst_def in H1.
  rewrite union_couple_eq in H1.
  apply pair_inv in H1; destruct H1.
   destruct H1; auto.

   destruct H1.
   rewrite H2; trivial.
 apply union_singl_eq.
Qed.

Lemma couple_injection : forall x y x' y',
  couple x y == couple x' y' -> x == x' /\ y == y'.
intros.
split.
 rewrite <- (fst_def x y);rewrite H; rewrite fst_def; reflexivity.
 rewrite <- (snd_def x y);rewrite H; rewrite snd_def; reflexivity.
Qed.

(* 2- typing *)

Definition prodcart A B :=
  subset (power (power (A ∪ B)))
    (fun x => exists2 a, a ∈ A & exists2 b, b ∈ B & x == couple a b).

Instance prodcart_mono :
  Proper (incl_set ==> incl_set ==> incl_set) prodcart.
unfold prodcart; red; intros A A' H B B' H0 z H1.
specialize subset_elim1 with (1:=H1); intro.
elim subset_elim2 with (1:=H1); clear H1; intros.
destruct H3.
destruct H4.
apply subset_intro.
 apply power_mono with (2:=H2).
 apply power_mono.
 apply union2_mono; trivial.

 exists x0; auto.
 exists x1; auto.
 rewrite H1; trivial.
Qed.

Instance prodcart_morph : morph2 prodcart.
Proof.
unfold prodcart; do 3 red; intros.
apply subset_morph; intros.
 rewrite H;  rewrite H0; reflexivity.

 split; intros.
  destruct H2 as (a, inA, (b, inB, eqx)).
  exists a.
   rewrite <- H; trivial.

   exists b; trivial.
   rewrite <- H0; trivial.
  destruct H2 as (a, inA, (b, inB, eqx)).
  exists a.
   rewrite H; trivial.

   exists b; trivial.
   rewrite H0; trivial.
Qed.

Lemma couple_intro :
  forall x y A B, x ∈ A -> y ∈ B -> couple x y ∈ prodcart A B.
Proof.
intros.
unfold couple, prodcart in |- *.
apply subset_intro.
 apply power_intro; intros.
   apply power_intro; intros.
   elim pair_elim with (1 := H1); intros.
    rewrite H3 in H2.
      apply union2_intro1.
      rewrite (singl_elim _ _ H2); trivial.
    rewrite H3 in H2.
      elim pair_elim with (1:=H2); intro z0_eq; rewrite z0_eq.
      apply union2_intro1; trivial.
      apply union2_intro2; trivial.
 exists x; trivial.
 exists y; trivial.
 reflexivity.
Qed.

Lemma fst_typ : forall p A B, p ∈ prodcart A B -> fst p ∈ A.
Proof.
unfold prodcart in |- *; intros.
elim subset_elim2 with (1 := H); intros.
destruct H1 as (a, inA, (b, inB, eqp)).
 rewrite <- H0 in eqp.
 rewrite eqp.
 rewrite fst_def; trivial.
Qed.

Lemma snd_typ : forall p A B, p ∈ prodcart A B -> snd p ∈ B.
Proof.
unfold prodcart in |- *; intros.
elim subset_elim2 with (1 := H); intros.
destruct H1 as (a, inA, (b, inB, eqp)).
 rewrite <- H0 in eqp.
 rewrite eqp.
 rewrite snd_def; trivial.
Qed.

Lemma surj_pair :
  forall p A B, p ∈ prodcart A B -> p == couple (fst p) (snd p).
Proof.
intros.
unfold prodcart in H.
elim subset_elim2 with (1 := H); intros.
destruct H1 as (a, inA, (b, inB, eqp)).
 rewrite <- H0 in eqp.
 rewrite eqp.
 rewrite fst_def.
 rewrite snd_def; reflexivity.
Qed.

(* dependent pairs *)

Definition sigma A B :=
  subset (prodcart A (sup A B)) (fun p => snd p ∈ B (fst p)).

Instance sigma_morph : Proper (eq_set ==> (eq_set ==> eq_set) ==> eq_set) sigma.
unfold sigma; do 3 red; intros.
apply subset_morph.
 apply prodcart_morph; trivial.
 apply sup_morph; trivial.
 red; intros; auto.

 red; intros.
 apply in_set_morph; auto with *.
Qed.

Lemma sigma_ext : forall A A' B B',
  A == A' ->
  (forall x x', x ∈ A -> x == x' -> B x == B' x') ->
  sigma A B == sigma A' B'.
unfold sigma; intros.
assert (peq : sup A B == sup A' B').
 apply union_morph.
 apply replf_morph; trivial.

apply subset_ext; intros.
 apply subset_intro.
  rewrite peq; rewrite H; trivial.

  rewrite (H0 (fst x) (fst x)); trivial.
  rewrite H; apply fst_typ with (1:=H1).
  reflexivity.

  specialize subset_elim1 with (1:=H1); intros.
   rewrite <- peq; rewrite <- H; trivial.

  elim subset_elim2 with (1:=H1); intros.
  exists x0; trivial.
  rewrite <- (H0 (fst x0) (fst x0)); trivial; try reflexivity.
  rewrite <- H2.
  specialize subset_elim1 with (1:=H1); intro.
  apply fst_typ with (1:=H4).
Qed.

Lemma sigma_nodep : forall A B,
  prodcart A B == sigma A (fun _ => B).
intros.
apply eq_intro; intros.
 generalize (fst_typ _ _ _ H); intro.
 generalize (snd_typ _ _ _ H); intro.
 apply subset_intro; trivial.
 rewrite (surj_pair _ _ _ H).
 apply couple_intro; trivial.
 apply union_intro with B; trivial.
 apply replf_intro with (fst z); auto with *.
 do 2 red; reflexivity.

 apply subset_elim1 in H.
 generalize (fst_typ _ _ _ H); intro.
 generalize (snd_typ _ _ _ H); intro.
 rewrite (surj_pair _ _ _ H).
 apply couple_intro; trivial.
 apply union_elim in H1; destruct H1.
 rewrite replf_ax in H2; auto with *.
 2:do 2 red; reflexivity.
 destruct H2.
 rewrite <- H3; trivial.
Qed.

Lemma couple_intro_sigma :
  forall x y A B, 
  ext_fun A B ->
  x ∈ A -> y ∈ B x -> couple x y ∈ sigma A B.
intros; unfold sigma.
apply subset_intro.
 apply couple_intro; trivial.
 rewrite sup_ax; eauto.

 rewrite <- (H x (fst(couple x y))); trivial.
  rewrite snd_def; trivial.
  rewrite fst_def; reflexivity.
Qed.

Lemma fst_typ_sigma : forall p A B, p ∈ sigma A B -> fst p ∈ A.
Proof.
unfold sigma in |- *; intros.
specialize subset_elim1 with (1 := H); intros.
apply fst_typ with (1:=H0).
Qed.

Lemma snd_typ_sigma : forall p y A B,
  ext_fun A B ->
  p ∈ sigma A B -> y == fst p -> snd p ∈ B y.
intros.
unfold sigma in H0.
elim subset_elim2 with (1:=H0); intros.
rewrite H2.
rewrite (H y (fst x)); trivial.
 specialize subset_elim1 with (1 := H0); intros.
 rewrite H1; apply fst_typ with (1:=H4).

 rewrite H1; rewrite H2; reflexivity.
Qed.

Lemma sigma_mono : forall A A' B B',
  ext_fun A B ->
  ext_fun A' B' ->
  A ⊆ A' ->
  (forall x x', x ∈ A -> x == x' -> B x ⊆ B' x') ->
  sigma A B ⊆ sigma A' B'.
red; intros.
rewrite (surj_pair _ _ _ (subset_elim1 _ _ _ H3)).
apply couple_intro_sigma; trivial.
 apply fst_typ_sigma in H3; auto.

 apply (H2 (fst z)); auto with *.
  apply fst_typ_sigma in H3; auto.

  apply snd_typ_sigma with (2:=H3); auto with *.
Qed.
