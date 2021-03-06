
Require Export basic ZF ZFpairs ZFrelations ZFstable ZFiso.
Require Import ZFgrothendieck.

(** * Impredicativity of props *)

Definition prf_trm := empty.
Definition props := power (singl prf_trm).

Lemma empty_in_props : empty ∈ props.
apply power_intro; intros.
apply empty_ax in H; contradiction.
Qed.

Lemma one_in_props : singl prf_trm ∈ props.
apply power_intro; auto.
Qed.
Hint Resolve empty_in_props one_in_props.

Lemma props_proof_irrelevance x P :
  P ∈ props -> x ∈ P -> x == empty.
intros.
apply singl_elim.
apply power_elim with (1:=H); trivial.
Qed.

Lemma cc_impredicative_prod : forall dom F,
  (forall x, x ∈ dom -> F x ∈ props) ->
  cc_prod dom F ∈ props.
Proof.
intros.
unfold props, prf_trm.
apply power_intro; intros.
apply singl_intro_eq.
rewrite cc_eta_eq with (1:=H0).
apply cc_impredicative_lam.
 do 2 red; intros; apply cc_app_morph; trivial; reflexivity.
intros.
apply props_proof_irrelevance with (F x); auto.
apply cc_prod_elim with (1:=H0); trivial.
Qed.

Lemma cc_impredicative_arr : forall A B,
  B ∈ props ->
  cc_arr A B ∈ props.
intros.
apply cc_impredicative_prod; auto.
Qed.

Lemma cc_forall_intro A B :
  ext_fun A B ->
  (forall x, x ∈ A -> empty ∈ B x) ->
  empty ∈ cc_prod A B.
intros.
rewrite <- cc_impredicative_lam with (dom:=A) (F:= fun _ => empty); auto with *.
apply cc_prod_intro; auto with *.
Qed.

Lemma cc_forall_elim A B x :
  empty ∈ cc_prod A B ->
  x ∈ A ->
  empty ∈ B x.
intros.
setoid_replace empty with (cc_app empty x).
 apply cc_prod_elim with (1:=H); trivial.

 symmetry; apply empty_ext; red; intros.
 rewrite <- couple_in_app in H1.
 apply empty_ax in H1; trivial.
Qed.

Definition cc_exists := sup. 
Hint Unfold cc_exists.


Lemma cc_exists_typ A B :
  ext_fun A B ->
  (forall x, x ∈ A -> B x ∈ props) ->
  cc_exists A B ∈ props.
unfold cc_exists; intros.
apply power_intro; intros.
rewrite sup_ax in H1; trivial.
destruct H1.
apply singl_intro_eq.
apply props_proof_irrelevance with (B x); auto.
Qed.

Lemma cc_exists_intro A B x :
  ext_fun A B -> 
  x ∈ A ->
  empty ∈ B x ->
  empty ∈ cc_exists A B.
unfold cc_exists; intros.
rewrite sup_ax; eauto.
Qed.

Lemma cc_exists_elim A B :
  ext_fun A B ->
  empty ∈ cc_exists A B ->
  exists2 x, x ∈ A & empty ∈ B x.
unfold cc_exists; intros.
rewrite sup_ax in H0; auto.
Qed.


(** * mapping (meta-level) propositions to props back and forth *)

Definition P2p (P:Prop) := cond_set P (singl prf_trm).
Definition p2P p := prf_trm ∈ p.

Instance P2p_morph : Proper (iff ==> eq_set) P2p.
do 2 red; intros; unfold P2p.
apply cond_set_morph; auto with *.
Qed.

Instance p2P_morph : Proper (eq_set ==> iff) p2P.
do 2 red; intros; apply in_set_morph; auto with *.
Qed.

Lemma P2p_typ : forall P, P2p P ∈ props.
unfold P2p; intros.
apply power_intro; intros.
rewrite cond_set_ax in H; destruct H; trivial.
Qed.

Lemma P2p2P : forall P, p2P (P2p P) <-> P.
unfold P2p, p2P; intros.
rewrite cond_set_ax.
split; intros.
 destruct H; trivial.

 split; trivial; apply singl_intro.
Qed.

Lemma p2P2p : forall p, p ∈ props -> P2p (p2P p) == p.
unfold p2P, P2p; intros.
apply eq_intro; intros.
 rewrite cond_set_ax in H0; destruct H0.
 apply singl_elim in H0.
 rewrite H0; trivial.

 rewrite cond_set_ax; split.
  apply power_elim with (1:=H); trivial.

  rewrite props_proof_irrelevance with (1:=H) (2:=H0) in H0; trivial.
Qed.

Lemma P2p_forall A (B:set->Prop) :
   (forall x x', x ∈ A -> x == x' -> (B x <-> B x')) ->
   P2p (forall x, x ∈ A -> B x) == cc_prod A (fun x => P2p (B x)).
intros.
unfold P2p.
apply eq_intro; intros.
 rewrite cond_set_ax in H0; destruct H0.
 apply singl_elim in H0.
 rewrite H0.
 apply cc_forall_intro; intros.
  do 2 red; intros.
  apply cond_set_morph; auto with *.

  rewrite cond_set_ax; split; auto; apply singl_intro.
  
 rewrite cond_set_ax; split; intros.
  apply singl_intro_eq.
  apply props_proof_irrelevance with (2:=H0).
  apply cc_impredicative_prod; intros.
  apply P2p_typ.

  specialize cc_prod_elim with (1:=H0) (2:=H1); intro.
  rewrite cond_set_ax in H2; destruct H2; trivial.
Qed.

Lemma cc_prod_forall A B :
   ext_fun A B ->
   (forall x, x ∈ A -> B x ∈ props) ->
   cc_prod A B == P2p (forall x, x ∈ A -> p2P (B x)).
intros.
rewrite P2p_forall.
 apply cc_prod_ext; auto with *.
 red; intros.
 rewrite p2P2p; auto.
 apply H0; rewrite <- H2; trivial.

 intros.
 apply in_set_morph; auto with *.
Qed.

Lemma cc_arr_imp A B :
   B ∈ props ->
   cc_arr A B == P2p ((exists x, x ∈ A) -> p2P B).
intros; unfold cc_arr; rewrite cc_prod_forall; intros; auto.
apply P2p_morph.
split; intros; eauto with *.
destruct H1; eauto.
Qed.

(** * Classical propositions: we also have a model for classical logic *)

Definition cl_props := subset props (fun P => ~~p2P P -> p2P P).

Lemma cc_cl_impredicative_prod : forall dom F,
  ext_fun dom F ->
  (forall x, x ∈ dom -> F x ∈ cl_props) ->
  cc_prod dom F ∈ cl_props.
Proof.
intros dom F eF H.
rewrite cc_prod_forall; intros; trivial.
 apply subset_intro; intros.
  apply P2p_typ.

  rewrite P2p2P in H0|-*; intros.
  specialize H with (1:=H1).
  apply subset_elim2 in H; destruct H.
  rewrite H; apply H2.
  intro nx; apply H0; intro h; apply nx.
  rewrite <- H; auto.

 specialize H with (1:=H0); apply subset_elim1 in H; trivial.
Qed.

Lemma cl_props_classical P :
  P ∈ cl_props ->
  cc_arr (cc_arr P empty) empty ⊆ P.
red; intros.
unfold cl_props in H; rewrite subset_ax in H.
destruct H as (Pty,(P',eqP,clP)).
rewrite <- eqP in clP; clear P' eqP.
assert (z == empty).
 apply props_proof_irrelevance with (2:=H0).
 apply cc_impredicative_arr.
 apply power_intro; intros.
 apply empty_ax in H; contradiction.
rewrite H; apply clP.
intro nP.
assert (empty ∈ cc_arr P empty).
 apply cc_forall_intro; intros; auto with *.
 elim nP.
 rewrite props_proof_irrelevance with (1:=Pty) (2:=H1) in H1; trivial.
apply empty_ax with (cc_app z empty).
apply cc_arr_elim with (2:=H1); trivial.
Qed.

(** Auxiliary stuff for strong normalization proof: every type
   contains the empty set. 
 *)

(* The operator that adds the empty set to a type. *)
Definition cc_bot x := singl empty ∪ x.

Lemma cc_bot_bot x : empty ∈ cc_bot x. 
apply union2_intro1; apply singl_intro.
Qed.
Lemma cc_bot_intro x z : z ∈ x -> z ∈ cc_bot x.
red; intros.
apply union2_intro2; trivial.
Qed.
Hint Resolve cc_bot_bot cc_bot_intro.

Instance cc_bot_mono : Proper (incl_set==>incl_set) cc_bot.
do 3 red; intros.
apply union2_elim in H0; destruct H0.
 apply union2_intro1; trivial.
 apply union2_intro2; auto.
Qed.

Instance cc_bot_morph : morph1 cc_bot.
unfold cc_bot; do 2 red; intros.
rewrite H; reflexivity.
Qed.

Lemma cc_bot_ax : forall x z,
  z ∈ cc_bot x <-> z == empty \/ z ∈ x.
unfold cc_bot; intros.
split; intros.
 apply union2_elim in H; destruct H; auto.
 apply singl_elim in H; auto.

 destruct H.
  apply union2_intro1; rewrite H; apply singl_intro.

  apply union2_intro2; trivial.
Qed.

Lemma cc_bot_prop :
    forall P, P ∈ props -> cc_bot P ∈ props.
intros.
apply power_intro; intros.
rewrite cc_bot_ax in H0.
destruct H0;[rewrite H0;apply singl_intro|].
apply power_elim with (1:=H); trivial.
Qed.

Lemma cc_bot_nop x :
  empty ∈ x -> cc_bot x == x.
intros.
apply eq_set_ax; split; intros; auto.
apply cc_bot_ax in H0; destruct H0; auto.
rewrite H0; trivial.
Qed.

Lemma cc_bot_cl_prop :
    forall P, P ∈ cl_props -> cc_bot P ∈ cl_props.
intros.
apply subset_intro.
 apply cc_bot_prop.
 apply subset_elim1 in H; auto.

 intros _.
 red; rewrite cc_bot_ax; left; reflexivity.
Qed.

Lemma cc_prod_mt U V :
  ext_fun U V ->
  (forall x, x ∈ U -> empty ∈ V x) ->
  cc_bot (cc_prod U V) == cc_prod U V.
intros Vm Vmt.
unfold cc_bot.
apply eq_intro; intros; auto.
rewrite cc_bot_ax in H; destruct H; trivial.
rewrite H.
assert (cc_lam U (fun _ => empty) == empty).
 apply cc_impredicative_lam; auto with *.
rewrite <- H0.
apply cc_prod_intro; auto with *.
Qed.

Lemma cc_prod_ext_mt U V f :
  ext_fun (cc_bot U) V ->
  empty ∈ V empty ->
  ~ empty ∈ U ->
  f ∈ cc_prod U V ->
  f ∈ cc_prod (cc_bot U) V.
intros.
assert (f == cc_lam (cc_bot U) (cc_app f)).
 apply cc_prod_is_cc_fun in H2.
 apply eq_set_ax; intros z.
 rewrite cc_lam_def.
 2:do 2 red; intros; apply cc_app_morph; auto with *.
 split; intros.
  destruct (H2 _ H3).
  exists (fst z); [apply cc_bot_intro;trivial|].
  exists (snd z); trivial.
  rewrite <- couple_in_app.
  rewrite H4 in H3; trivial.

  destruct H3 as (x,xty,(y,yty,eqc)).
  rewrite eqc.
  rewrite couple_in_app; trivial.
rewrite H3; apply cc_prod_intro; trivial.
 do 2 red; intros; apply cc_app_morph; auto with *.

 intros.
 rewrite cc_bot_ax in H4; destruct H4.
  rewrite cc_app_outside_domain.
  2:apply cc_prod_is_cc_fun in H2; eexact H2.
   apply eq_elim with (V empty); trivial.
   apply H; auto with *.

   rewrite H4; trivial.

 apply cc_prod_elim with (1:=H2); trivial.
Qed.

Definition fbot f x := cond_set (~x==empty) (f x).

Lemma eqf_fbot X f f' :
  ~ empty ∈ X ->
  eq_fun X f f' ->
  eq_fun (cc_bot X) (fbot f) (fbot f').
red; intros.
rewrite cc_bot_ax in H1; destruct H1.
 unfold fbot; rewrite cond_set_mt;[|tauto].
 rewrite H2 in H1; rewrite cond_set_mt;[|tauto].
 reflexivity.

 assert (~x==empty).
  intro h; rewrite h in H1; contradiction.
 unfold fbot; rewrite cond_set_ok; trivial.
 rewrite H2 in H3; rewrite cond_set_ok; trivial.
 apply H0; trivial.
Qed.

Lemma iso_cc_bot X Y f :
  iso_fun X Y f ->
  ~ empty ∈ X ->
  ~ empty ∈ Y ->
  iso_fun (cc_bot X) (cc_bot Y) (fbot f).
unfold fbot.
intros.
assert (fm := iso_funm H).
split; intros.
 do 2 red; intros.
 rewrite H2; reflexivity.

 red; intros.
 apply cc_bot_ax in H2; destruct H2.
  rewrite cond_set_mt; auto.

  rewrite cond_set_ok.
   apply cc_bot_intro.
   apply (iso_typ H); trivial.

   intro h; rewrite h in H2; contradiction.

 rewrite cc_bot_ax in H2,H3.
 destruct H2; [rewrite H2|]; (destruct H3;[rewrite H3|]); try reflexivity.
  rewrite cond_set_mt in H4;[|tauto].
  rewrite cond_set_ok in H4.
   elim H1.
   rewrite H4.
   apply (iso_typ H); trivial.

   intro h; rewrite h in H3; contradiction.

  rewrite cond_set_ok in H4.
   rewrite cond_set_mt in H4;[|tauto].
   elim H1.
   rewrite <- H4.
   apply (iso_typ H); trivial.

   intro h; rewrite h in H2; contradiction.

  rewrite cond_set_ok in H4.
   rewrite cond_set_ok in H4.
    apply (iso_inj H) in H4; trivial.

    intro h; rewrite h in H3; contradiction.
   intro h; rewrite h in H2; contradiction.

 rewrite cc_bot_ax in H2; destruct H2.
  exists empty; auto.
  rewrite cond_set_mt; auto with *.

  destruct (iso_surj H) with y; trivial.
  exists x; auto.
  rewrite cond_set_ok; trivial.
  intro h; rewrite h in H3; contradiction.
Qed.

(** Taking the bottom value out of the domain of a function *)
Definition squash f := subset f (fun c => ~ fst c == empty).

Instance squash_morph : morph1 squash.
do 2 red; intros.
apply subset_morph; auto with *.
Qed.

Lemma squash_ax f z :
  z ∈ squash f <-> z ∈ f /\ ~ fst z == empty.
unfold squash; rewrite subset_ax.
apply and_iff_morphism; auto with *.
split; intros.
 destruct H.
 rewrite H; trivial.

 exists z; auto with *.
Qed.

Lemma squash_eq  A B f :
  ~ empty ∈ A ->
  f ∈ cc_prod (cc_bot A) B ->
  squash f == cc_lam A (cc_app f).
intros.
apply eq_set_ax; intros z.
rewrite squash_ax.
rewrite cc_lam_def.
2:do 2 red; intros; apply cc_app_morph; auto with *.
split; intros.
 destruct H1.
 destruct cc_prod_is_cc_fun with (1:=H0)(2:=H1).
 apply union2_elim in H4; destruct H4.
  apply singl_elim in H4; contradiction.
 exists (fst z); trivial.
 exists (snd z); trivial.
 rewrite <- couple_in_app.
 rewrite H3 in H1; trivial.

 destruct H1 as (x,xty,(y,yty,eqc)).
 rewrite <- couple_in_app in yty.
 rewrite eqc; split; trivial.
 rewrite fst_def; intro h; rewrite h in xty; auto.
Qed.

Lemma squash_typ A B f :
  ext_fun (cc_bot A) B ->
  ~ empty ∈ A ->
  f ∈ cc_prod (cc_bot A) B ->
  squash f ∈ cc_prod A B.
intros.
rewrite squash_eq with (2:=H1); trivial.
apply cc_prod_intro; intros.
 do 2 red; intros; apply cc_app_morph; auto with *.

 do 2 red; intros; apply H; trivial.
 apply cc_bot_intro; trivial.

 apply cc_prod_elim with (1:=H1).
 apply cc_bot_intro; trivial.
Qed.

Lemma squash_beta A B f x :
  ~ empty ∈ A ->
  f ∈ cc_prod (cc_bot A) B ->
  x ∈ A ->
  cc_app (squash f) x == cc_app f x.
intros.
rewrite squash_eq with (2:=H0); trivial.
rewrite cc_beta_eq; auto with *.
do 2 red; intros; apply cc_app_morph; auto with *.
Qed.

Lemma squash_mt A B f :
  ~ empty ∈ A ->
  f ∈ cc_prod (cc_bot A) B ->
  cc_app (squash f) empty == empty.
intros.
apply cc_app_outside_domain with A; trivial.
rewrite squash_eq with (2:=H0); trivial.
apply is_cc_fun_lam.
do 2 red; intros; apply cc_app_morph; auto with *.
Qed.


(** #<a name="EquivTTColl"/># *)
(** * Correspondance between ZF universes and (Coq + TTColl) universes *)

Section Universe.

 (* A grothendieck universe... *)
  Hypothesis U : set.
  Hypothesis Ugrot : grot_univ U.

(*
Section Equiv_TTRepl.

  Hypothesis cc_set : set.
  Hypothesis cc_eq_set : set -> set -> Prop.
  Hypothesis cc_eq_set_morph : Proper (eq_set==>eq_set==>iff) cc_eq_set.
  Hypothesis cc_set_incl_U : cc_set ⊆ U.

Lemma cc_ttrepl A R :
  Proper (eq_set ==> eq_set ==> iff) R ->
  (* A : Ti *)
  A ∈ U ->
  (* type of R + existence assumption *)
  (forall x, x ∈ A -> exists2 y, y ∈ cc_set & R x y) ->
  (forall x y y', x ∈ A -> R x y -> (R x y' <-> cc_eq_set y y')) ->
  (* exists f:A->set, *)
  exists2 f, f ∈ cc_arr A cc_set &
    (* forall x:A, R x (f i) *)
    forall x, x ∈ A -> R x (cc_app f x).

(forall x in A, exists y ∈ A, exists g:y->cc_set, R x (cc_sup y g))

R' x y := (z ∈ y <-> R x z)  (y = ens de cc_set -> ⊆ U)

End Equiv_TTRepl.
*)

Section Equiv_ZF_CIC_TTColl.

(** We assume now that U is a *ZF* universe (not just IZF),
   so it is closed by collection. *)

  Hypothesis coll_axU : forall A (R:set->set->Prop), 
    A ∈ U ->
    (forall x x' y y', in_set x A ->
     eq_set x x' -> eq_set y y' -> R x y -> R x' y') ->
    exists2 B, B ∈ U &
      forall x, in_set x A ->
        (exists2 y, y ∈ U & R x y) ->
        exists2 y, y ∈ B & R x y.

  (* The inductive type of sets (cf Ens.set and
      #<a href="ZFind_w.html##sets">ZFind_w.sets</a>#) and the fact that
      it is included in the universe of its index. *)
  Hypothesis sets : set.
  Hypothesis sets_incl_U : sets ⊆ U.

(** We prove that the model will validate TTColl (Ens.ttcoll).
   This formulation heavily uses the reification of propositions of the model
   as Coq's Prop elements. *)
Lemma cc_ttcoll A R :
  Proper (eq_set ==> eq_set ==> iff) R ->
  (* A : Ti *)
  A ∈ U ->
  (* exists X:Ti, *)
  exists2 X, X ∈ U &
    (* exists f:X->set, *)
    exists2 f, f ∈ cc_arr X sets &
    (* forall x:A, (exists w, R x w) -> exists i:X, R x (f i) *)
    forall x, x ∈ A ->
    (exists2 w, w ∈ sets & R x w) -> exists2 i, i ∈ X & R x (cc_app f i).
intros.
destruct coll_axU with (A:=A) (R:=fun x y => y ∈ sets /\ R x y) as (B,HB);
  trivial.
 intros.
 rewrite <- H2; rewrite <- H3; trivial.

 pose (B':= B ∩ sets).
 exists B'.
  apply G_incl with B; trivial.
  apply inter2_incl1.
 exists (cc_lam B' (fun x => x)).
  apply cc_arr_intro; intros.
   do 2 red; intros; trivial.
   revert H2; apply inter2_incl2.
 intros.
 destruct H1 with (1:=H2) as (y,yB,(ys,yR)).
  destruct H3 as (w,?,?).
  exists w; auto.

  exists y.
   unfold B'; rewrite inter2_def; auto.

   rewrite cc_beta_eq; trivial.
    do 2 red; auto.

    unfold B'; rewrite inter2_def; auto.
Qed.

(** And now using the real connectives of props: *)
Lemma cc_ttcoll' : empty ∈
  (** forall A : U, *)
  cc_prod U (fun A =>
  (** forall R : A->set->Prop, *)
  cc_prod (cc_arr A (cc_arr sets props)) (fun R =>
  (** exists X:U, *)
  cc_exists U (fun X =>
  (** exists g:X->set, *)
  cc_exists (cc_arr X sets) (fun g =>
    (* *forall i:A, *)
    cc_prod A (fun i =>
    (** (exists w:set, R i w) -> *)
    cc_arr (cc_exists sets (fun w => cc_app (cc_app R i) w))
    (** (exists j:X, R i (g j)) *)
           (cc_exists X (fun j => cc_app (cc_app R i) (cc_app g j)))))))).
assert (e1 : Proper (eq_set==>eq_set==>eq_set==>eq_set) (fun R i w => cc_app (cc_app R i) w)).
 do 4 red; intros.
 repeat apply cc_app_morph; trivial.
assert (e2 : Proper (eq_set==>eq_set==>eq_set==>eq_set==>eq_set)
               (fun R g i j => cc_app (cc_app R i) (cc_app g j))).
 do 5 red; intros.
 repeat apply cc_app_morph; trivial.
assert (e3: Proper (eq_set==>eq_set==>eq_set==>eq_set==>eq_set) (fun R X g i =>
    cc_arr (cc_exists sets (fun w => cc_app (cc_app R i) w))
           (cc_exists X (fun j => cc_app (cc_app R i) (cc_app g j))))).
 do 5 red; intros.
 apply cc_arr_morph.
  apply sup_morph; auto with *.
  red; intros; apply e1; trivial.

  apply sup_morph; trivial.
  red; intros; apply e2; trivial.
assert (e4 : Proper (eq_set==>eq_set==>eq_set==>eq_set==>eq_set) (fun A R X g =>
    cc_prod A (fun i =>
    cc_arr (cc_exists sets (fun w => cc_app (cc_app R i) w))
           (cc_exists X (fun j => cc_app (cc_app R i) (cc_app g j)))))).
 do 5 red; intros.
 apply cc_prod_ext; trivial.
 red; intros.
 apply e3; trivial.
assert (e5 : Proper (eq_set==>eq_set==>eq_set==>eq_set) (fun A R X =>
  cc_exists (cc_arr X sets) (fun g =>
    cc_prod A (fun i =>
    cc_arr (cc_exists sets (fun w => cc_app (cc_app R i) w))
           (cc_exists X (fun j => cc_app (cc_app R i) (cc_app g j))))))).
 do 4 red; intros.
 apply sup_morph.
  rewrite H1; reflexivity.

  red; intros; apply e4; trivial.
assert (e6: morph2 (fun A R =>
  cc_exists U (fun X =>
  cc_exists (cc_arr X sets) (fun g =>
    cc_prod A (fun i =>
    cc_arr (cc_exists sets (fun w => cc_app (cc_app R i) w))
           (cc_exists X (fun j => cc_app (cc_app R i) (cc_app g j)))))))).
 do 3 red; intros.
 apply sup_morph; auto with *.
 red; intros; apply e5; trivial.
assert (e7: morph1 (fun A =>
  cc_prod (cc_arr A (cc_arr sets props)) (fun R =>
  cc_exists U (fun X =>
  cc_exists (cc_arr X sets) (fun g =>
    cc_prod A (fun i =>
    cc_arr (cc_exists sets (fun w => cc_app (cc_app R i) w))
           (cc_exists X (fun j => cc_app (cc_app R i) (cc_app g j))))))))).
 do 2 red; intros.
 apply cc_prod_ext.
  rewrite H; reflexivity.
  red; intros; apply e6; trivial.
apply cc_forall_intro; [auto with *|intros A tyA].
apply cc_forall_intro.
 apply morph_is_ext;apply e6; reflexivity.
intros R tyR.
destruct cc_ttcoll with (A:=A) (R:=fun x y => empty ∈ cc_app (cc_app R x) y)
    as (X,tyX,(g,tyg0,Hg)); trivial.
 do 3 red; intros.
 rewrite H; rewrite H0; reflexivity.
assert (tyg : forall j, j ∈ X -> cc_app g j ∈ sets).
 intros.
 apply cc_arr_elim with (1:=tyg0); trivial.
apply cc_exists_intro with X; trivial.
 do 2 red; intros.
 apply e5; auto with *.
apply cc_exists_intro with g; trivial.
 do 2 red; intros.
 apply e4; auto with *.
apply cc_forall_intro.
 do 2 red; intros.
 apply e3; auto with *.
intros i tyi.
apply cc_forall_intro; auto with *.
intros p exw.
destruct Hg with (1:=tyi) as (j,tyj,Hj).
 apply cc_exists_elim.
  do 2 red; intros; apply cc_app_morph; auto with *.

  rewrite props_proof_irrelevance with (2:=exw) in exw; trivial.
   apply cc_exists_typ; intros; auto with *.
    do 2 red; intros; apply e1; auto with *.
   apply cc_arr_elim with sets; trivial.
   apply cc_arr_elim with A; trivial.

 apply cc_exists_intro with j; auto.
 do 2 red; intros; apply e2; auto with *.
Qed.

End Equiv_ZF_CIC_TTColl.

End Universe.

(** Choices implies description:  ∃x. P(x) -> Σx. P(x) *)

Section ChoicesImpliesDescription.

Hypothesis choose : set -> set.
Hypothesis choose_morph : morph1 choose.
Hypothesis choose_ax : forall x, (exists y, y ∈ x) -> choose x ∈ x.

Lemma description_from_choice A P (Pm:Proper (eq_set==>iff) P) : 
  cc_lam (cc_exists A (fun x => P2p (P x))) (fun _ => choose (subset A P)) ∈
  cc_arr (cc_exists A (fun x => P2p (P x))) (subset A P).
apply cc_arr_intro; auto with *.
intros.
apply choose_ax.
apply sup_ax in H.
 destruct H as (y,?,?).
 exists y; apply subset_intro; trivial.
 apply cond_set_ax in H0.
 destruct H0; trivial.

 do 2 red; intros.
 rewrite H1; reflexivity.
Qed.

End ChoicesImpliesDescription.
