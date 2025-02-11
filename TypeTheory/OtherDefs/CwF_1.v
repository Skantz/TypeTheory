
(**

 Ahrens, Lumsdaine, Voevodsky, 2015

  Contents:

    - Definition of a category with families
    - Proof that reindexing forms a pullback

  The definition is based on Pitts, *Nominal Presentations of the Cubical Sets
  Model of Type Theory*, Def. 3.1: 
  http://www.cl.cam.ac.uk/~amp12/papers/nompcs/nompcs.pdf (page=9)

  This file is very similar to [TypeTheory.OtherDefs.CwF_Pitts]; the main difference is that here the functor of types is bundled into an actual functor, whereas in [CwF_Pitts], it is split up componentwise. 
*)

Require Import UniMath.Foundations.Sets.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.opp_precat.
Require Import UniMath.CategoryTheory.limits.pullbacks.
Require Import TypeTheory.Auxiliary.CategoryTheoryImports.
Require Import TypeTheory.Auxiliary.Auxiliary.
Require Import TypeTheory.Auxiliary.CategoryTheory.
Require Import TypeTheory.Auxiliary.SetsAndPresheaves.

Local Open Scope precat.

(** * A "preview" of the definition *)

Module Record_Preview.

Reserved Notation "C ⟨ Γ ⟩" (at level 60).
Reserved Notation "C ⟨ Γ ⊢ A ⟩" (at level 60).
Reserved Notation "A [[ γ ]]" (at level 40).
Reserved Notation "a ⟦ γ ⟧" (at level 40).
Reserved Notation "Γ ∙ A" (at level 35).
Reserved Notation "'π' A" (at level 20).
Reserved Notation "'ν' A" (at level 15).
Reserved Notation "γ ♯ a" (at level 25).
(*
Record cwf_record : Type := {
  C : category ;
  Ty : functor C HSET     where "C ⟨ Γ ⟩" := (Ty Γ) ;
  term : ∏ Γ : C, pr1hSet (Ty Γ) → UU     where "C ⟨ Γ ⊢ A ⟩" := (term Γ A) ;
(*  rtype : ∏ {Γ Γ' : C} (A : pr1hSet (Ty Γ)) (γ : Γ' --> Γ), pr1hSetC⟨Γ'⟩ where "A [[ γ ]]" := (rtype A γ) ; *)
  rterm : ∏ {Γ Γ' : C} {A : C⟨Γ⟩} (a : C⟨Γ⊢A⟩) (γ : Γ' --> Γ), 
          C⟨Γ'⊢ A[[γ]]⟩   where "a ⟦ γ ⟧" := (rterm a γ) ;
  reindx_type_id : ∏ Γ (A : C⟨Γ⟩), A [[identity Γ]] = A ;
  reindx_type_comp : ∏  {Γ Γ' Γ''} (γ : Γ' --> Γ) (γ' : Γ'' --> Γ') (A : C⟨Γ⟩), 
          A [[γ';;γ]] 
          =  
          A[[γ]][[γ']] ;
  reindx_term_id : ∏ Γ (A : C⟨Γ⟩) (a : C⟨Γ⊢A⟩), 
          a⟦identity Γ⟧ 
          =
          transportf (λ B, C⟨Γ ⊢ B⟩) (! (reindx_type_id _ _)) a ;
  reindx_term_comp : ∏ {Γ Γ' Γ''} (γ : Γ' --> Γ) (γ' : Γ'' --> Γ') {A : C⟨Γ⟩} (a : C⟨Γ⊢A⟩),
          a⟦γ';;γ⟧ 
          =
          transportf (λ B, C⟨Γ'' ⊢ B⟩) (!(reindx_type_comp  _ _ _ )) (a⟦γ⟧⟦γ'⟧) ;
  comp_obj : ∏ Γ (A : C⟨Γ⟩), C where "Γ ∙ A" := (comp_obj Γ A) ;
  proj_mor : ∏ Γ (A : C⟨Γ⟩), Γ ∙ A --> Γ where "'π' A" := (proj_mor _ A) ;
  gen_element : ∏ Γ (A : C⟨Γ⟩), C⟨Γ∙A ⊢ A[[π _ ]]⟩ where "'ν' A" := (gen_element _ A) ;
  pairing : ∏ Γ (A : C⟨Γ⟩) Γ' (γ : Γ' --> Γ)(a : C⟨Γ'⊢ A[[γ]]⟩), Γ' --> Γ∙A 
     where "γ ♯ a" := (pairing _ _ _  γ a) ;
  cwf_law_1 : ∏ Γ (A : C ⟨Γ⟩) Γ' (γ : Γ' --> Γ) (a : C⟨Γ'⊢ A[[γ]]⟩), 
          (γ ♯ a) ;; (π _) 
          = 
          γ ;
  cwf_law_2 : ∏ Γ (A : C ⟨Γ⟩) Γ' (γ : Γ' --> Γ) (a : C⟨Γ'⊢ A[[γ]]⟩),
          transportf (λ ι, C⟨Γ'⊢ A [[ι]]⟩) (cwf_law_1 Γ A Γ' γ a)
             (transportf (λ B, C⟨Γ'⊢ B⟩) (!reindx_type_comp (π _ )(γ ♯ a) _ )
                ((ν A) ⟦γ ♯ a⟧))
          = 
          a
}.
*)
End Record_Preview.


(** * Type and terms of a [CwF] *)

(* Note: in the end, we define not pre-cwfs but cwfs, assuming an underlying _category_ with homsets.  But for the “data” stages of the definition, we just take an underlying precategory. *)

(** 
 A [cwf] comes with types, written [C⟨Γ⟩], 
   and terms [C⟨Γ ⊢ A⟩] 
*)


Definition tt_structure (C : precategory) :=
  ∑ f : functor C^op HSET, ∏ c : C, pr1hSet (f c) → UU.


Definition type {C : precategory} (TT : tt_structure C) : C → hSet := functor_on_objects (pr1 TT).

Notation "C ⟨ Γ ⟩" := (type C Γ) (at level 60).
  (* \< and \> in Agda input method *)

Definition term {CC : precategory} (C : tt_structure CC) : ∏ Γ : CC, C⟨Γ⟩ → UU := pr2 C.

Notation "C ⟨ Γ ⊢ A ⟩" := (term C Γ A) (at level 60).
  (* \<, \>, and \|- or \vdash *)

(** * Reindexing of types [A[γ]] and terms [a⟦γ⟧] along a morphism [γ : Γ' --> Γ] *)

Definition rtype {CC : precategory} {C : tt_structure CC}
  : ∏ {Γ Γ' : CC} (A : C⟨Γ⟩) (γ : Γ' --> Γ), C⟨Γ'⟩.
Proof.
  intros Γ Γ' A γ.
  apply (# (pr1 C) γ A).
Defined.

Definition reindx_structure {CC : precategory}(C : tt_structure CC) := 
(*  ∑ (rtype : ∏ {Γ Γ' : CC} (A : C⟨Γ⟩) (γ : Γ' --> Γ), C⟨Γ'⟩), *)
        ∏ (Γ Γ' : CC) (A : C⟨Γ⟩) (a : C⟨Γ⊢A⟩) (γ : Γ' --> Γ), C⟨Γ'⊢rtype A γ⟩.

Definition tt_reindx_struct (CC : precategory) : UU 
 :=
   ∑ C : tt_structure CC, reindx_structure C.

Coercion tt_from_tt_reindx CC (C : tt_reindx_struct CC) : tt_structure _ := pr1 C.
Coercion reindx_from_tt_reindx CC (C : tt_reindx_struct CC) : reindx_structure _ := pr2 C.

(*
Definition rtype {CC : precategory}{C : tt_reindx_struct CC} 
  : ∏ {Γ Γ' : CC} (A : C⟨Γ⟩) (γ : Γ' --> Γ), C⟨Γ'⟩ 
:= 
   pr1 (pr2 C).
*)

Notation "A [[ γ ]]" := (rtype A γ) (at level 40).

Definition rterm {CC : precategory}{C : tt_reindx_struct CC}  
  : ∏ {Γ Γ' : CC} {A : C⟨Γ⟩}  (a : C⟨Γ⊢A⟩) (γ : Γ' --> Γ), C⟨Γ'⊢ A [[γ]] ⟩ 
:= 
    (pr2 C).

Notation "a ⟦ γ ⟧" := (rterm a γ) (at level 40).

(** *  Reindexing laws *)

(** Reindexing for types *)
Definition reindx_laws_type {CC : precategory}(C : tt_reindx_struct CC) : UU :=
    (∏ Γ (A : C⟨Γ⟩), A [[identity Γ]] = A) ×
    (∏ Γ Γ' Γ'' (γ : Γ' --> Γ) (γ' : Γ'' --> Γ') (A : C⟨Γ⟩), A [[γ';;γ]] = A[[γ]][[γ']]). 

Definition reindx_laws_type_proof {CC : precategory} (C : tt_reindx_struct CC)
  : reindx_laws_type C.
Proof.
  split.
  - intro. apply toforallpaths, (functor_id (pr1 (pr1 C))).
  - do 5 intro. apply toforallpaths, (functor_comp (pr1 (pr1 C))).
Defined.

(** Reindexing for terms needs transport along reindexing for types *) 
Definition reindx_laws_terms {CC : precategory} (C : tt_reindx_struct CC) 
    :=
    let T:=reindx_laws_type_proof C in
    (∏ Γ (A : C⟨Γ⟩) (a : C⟨Γ⊢A⟩), a⟦identity Γ⟧ = 
          transportf (λ B, C⟨Γ ⊢ B⟩) (!pr1 T _ _) a) ×
    (∏ Γ Γ' Γ'' (γ : Γ' --> Γ) (γ' : Γ'' --> Γ') (A : C⟨Γ⟩) (a : C⟨Γ⊢A⟩),
            a⟦γ';;γ⟧ = 
          transportf (λ B, C⟨Γ'' ⊢ B⟩) (!pr2 T _ _ _ _ _ _ )  (a⟦γ⟧⟦γ'⟧)).
          
(** Package of reindexing for types and terms *)
(* Note: in fact the reindexing laws for types are already packaged into the functor structure, so [reindx_laws] is just an alias for [reindx_laws_terms], given for consistency with other versions of CwF’s. TODO: is this useful/necessary? *)
Definition reindx_laws {CC : precategory} (C : tt_reindx_struct CC)  : UU := 
          reindx_laws_terms C.
     
Definition reindx_type_id {CC : precategory} {C : tt_reindx_struct CC} 
  : ∏ Γ (A : C⟨Γ⟩), A [[identity Γ]] = A 
:= 
  (pr1 (reindx_laws_type_proof C)).

Definition reindx_type_comp {CC : precategory} {C : tt_reindx_struct CC} 
(*    (T : reindx_laws C)  *)
   {Γ Γ' Γ''} (γ : Γ' --> Γ) (γ' : Γ'' --> Γ') (A : C⟨Γ⟩) 
  : A [[γ';;γ]] = A[[γ]][[γ']]
:=
   pr2 (reindx_laws_type_proof C) _ _ _ _ _ _ .

Definition reindx_term_id {CC : precategory} {C : tt_reindx_struct CC}
   (T : reindx_laws C) 
  : ∏ Γ (A : C⟨Γ⟩) (a : C⟨Γ⊢A⟩), a⟦identity Γ⟧ = 
          transportf (λ B, C⟨Γ ⊢ B⟩) (! (reindx_type_id _ _ ) ) a 
:= pr1 T.

Definition reindx_term_comp {CC : precategory} {C : tt_reindx_struct CC}
    (T : reindx_laws C) 
  : ∏ {Γ Γ' Γ''} (γ : Γ' --> Γ) (γ' : Γ'' --> Γ') {A : C⟨Γ⟩} (a : C⟨Γ⊢A⟩),
            a⟦γ';;γ⟧ = 
          transportf (λ B, C⟨Γ'' ⊢ B⟩) (! (reindx_type_comp  _ _ _ ) )  (a⟦γ⟧⟦γ'⟧) 
:= 
   (pr2 T).
    

(** * Comprehension structure *)

(** ** Comprehension object and projection *)

Definition comp_1_struct {CC : precategory} (C : tt_reindx_struct CC) : UU 
:=
  ∏ Γ (A : C⟨Γ⟩), ∑ ΓA, ΓA --> Γ.


Definition tt_reindx_comp_1_struct (CC : precategory) : UU 
  := 
     ∑ C : tt_reindx_struct CC, comp_1_struct C.

Coercion tt_reindx_from_tt_reindx_comp_1 (CC : precategory) (C : tt_reindx_comp_1_struct CC) 
  : tt_reindx_struct _ := pr1 C.

Definition comp_obj {CC : precategory} {C : tt_reindx_comp_1_struct CC} (Γ : CC) (A : C⟨Γ⟩) 
  : CC 
:=  (pr1 (pr2 C Γ A)).
Notation "Γ ∙ A" := (comp_obj Γ A) (at level 35).
  (* \. in Adga mode *)

Definition proj_mor {CC : precategory} {C : tt_reindx_comp_1_struct CC}
      {Γ : CC} (A : C⟨Γ⟩) 
  : Γ ∙ A  --> Γ 
:= (pr2 (pr2 C Γ A)).

Notation "'π' A" := (proj_mor A) (at level 20).

(** ** Generic element and pairing *)
Definition comp_2_struct {CC : precategory} (C : tt_reindx_comp_1_struct CC) : UU
:= 
   ∏ Γ (A : C⟨Γ⟩), 
     C⟨(Γ∙A) ⊢ (A [[π A]]) ⟩ × 
     (∏ Γ' (γ : Γ' --> Γ) (a : C⟨Γ'⊢A[[γ]]⟩), Γ' --> Γ∙A).

Definition tt_reindx_type_struct (CC : precategory) : UU 
:=
   ∑ C : tt_reindx_comp_1_struct CC, comp_2_struct C.

Coercion tt_reindx_comp_1_from_tt_reindx_comp (CC : precategory) (C : tt_reindx_type_struct CC) 
  : tt_reindx_comp_1_struct _ := pr1 C.


Definition gen_elem  {CC : precategory} {C : tt_reindx_type_struct CC} 
    {Γ : CC} (A : C⟨Γ⟩) 
  : C⟨Γ∙A  ⊢ A[[π _ ]]⟩ 
 := 
   pr1 (pr2 C Γ A).

Notation "'ν' A" := (gen_elem A) (at level 15).

Definition pairing  {CC : precategory} {C : tt_reindx_type_struct CC} 
    {Γ : CC} {A : C⟨Γ⟩} {Γ'} (γ : Γ' --> Γ) (a : C⟨Γ'⊢A[[γ]]⟩) 
  : Γ' --> Γ∙A  
:= pr2 (pr2 C Γ A) Γ' γ a.

Notation "γ ♯ a" := (pairing γ a) (at level 25).
  (* \# in Adga mode *)
 

(** ** Laws satisfied by the comprehension structure *)

Definition comp_laws_1_2  {CC : precategory} {C : tt_reindx_type_struct CC} 
   (L : reindx_laws C) : UU := 
   ∏ Γ (A : C ⟨Γ⟩) Γ' (γ : Γ' --> Γ) (a : C⟨Γ'⊢ A[[γ]]⟩),
        ∑ h : (γ ♯ a) ;; (π _ ) = γ,
           transportf (λ ι, C⟨Γ'⊢ A [[ι]]⟩) h   
             (transportf (λ B, C⟨Γ'⊢ B⟩) (!reindx_type_comp  (π _ )(γ ♯ a) _ )
               ((ν _ ) ⟦γ ♯ a⟧)) = a.

Definition comp_law_3  {CC : precategory} {C : tt_reindx_type_struct CC}
     (L : reindx_laws C) : UU 
:= 
   ∏ Γ (A : C ⟨Γ⟩) Γ' Γ'' (γ : Γ' --> Γ) (γ' : Γ'' --> Γ') (a : C⟨Γ'⊢ A[[γ]]⟩),
    γ' ;; (γ ♯ a) 
    =  
    (γ' ;; γ) ♯ (transportf (λ B, C⟨Γ''⊢ B⟩) (!reindx_type_comp γ γ' _ ) (a⟦γ'⟧)).

Definition comp_law_4  {CC : precategory} {C : tt_reindx_type_struct CC}
    (L : reindx_laws C) : UU
:=
   ∏ Γ (A : C⟨Γ⟩), π A ♯ ν A = identity _ . 



(* Note: the restriction now from categories to precategories is deliberate — we are insisting that cwf’s have hom-sets. *)
Definition cwf_laws {CC : category} (C : tt_reindx_type_struct CC) 
   :=
    (∑ T : reindx_laws C,
       (comp_laws_1_2 T × comp_law_3 T × comp_law_4 T)) ×
    (∏ Γ (A : C⟨Γ⟩), isaset (C⟨Γ⊢ A⟩)). 

(** * Definition of category with families *)
(** A category with families [cwf] is 
  - a category
  - with type-and-term structure 
  - with reindexing 
  - with comprehension structure
  - satisfying the comprehension laws
  - where types and terms are hsets
*)


Definition cwf_struct (CC : category) : UU 
  := ∑ C : tt_reindx_type_struct CC, cwf_laws C.

(** * Various access functions to the components *)
(** Also a few generalizations are proved, providing variants with 
    generalized proofs of identity of types, terms (which form hsets) 
*)

Coercion cwf_data_from_cwf_struct (CC : category) (C : cwf_struct CC)
  : tt_reindx_type_struct CC
  := pr1 C.

Coercion cwf_laws_from_cwf_struct (CC : category) (C : cwf_struct CC)
  : cwf_laws C
  := pr2 C.

Coercion reindx_laws_from_cwf_struct (CC : category) (C : cwf_struct CC)
  : reindx_laws C
  := pr1 (pr1 (pr2 C)).

Definition cwf_comp_laws {CC : category} (C : cwf_struct CC)
  : (comp_laws_1_2 C × comp_law_3 C × comp_law_4 C)
  := pr2 (pr1 (pr2 C)).

Definition cwf_types_isaset {CC : category} (C : cwf_struct CC) Γ : isaset (C⟨Γ⟩)
  := setproperty (C⟨Γ⟩).

Definition cwf_terms_isaset  {CC : category} (C : cwf_struct CC) : ∏ Γ A, isaset (C⟨Γ ⊢ A⟩)
  :=  (pr2 (pr2 C)).


Definition cwf_law_1 {CC : category} (C : cwf_struct CC) 
  Γ (A : C ⟨Γ⟩) Γ' (γ : Γ' --> Γ) (a : C⟨Γ'⊢ A[[γ]]⟩)
  : (γ ♯ a) ;; (π _) = γ
  :=  pr1 (pr1 (cwf_comp_laws C) Γ A Γ' γ a).

Definition cwf_law_2 {CC : category} (C : cwf_struct CC) 
  Γ (A : C ⟨Γ⟩) Γ' (γ : Γ' --> Γ) (a : C⟨Γ'⊢ A[[γ]]⟩)
  : transportf (λ ι, C⟨Γ'⊢ A [[ι]]⟩) (cwf_law_1 C Γ A Γ' γ a)
    (transportf (λ B, C⟨Γ'⊢ B⟩) (!reindx_type_comp (π _)(γ ♯ a) _ ) 
      ((ν A) ⟦γ ♯ a⟧))
    = a
  := pr2 ((pr1 (cwf_comp_laws C)) Γ A Γ' γ a).

Definition cwf_law_2_gen {CC : category} (C : cwf_struct CC) 
  Γ (A : C ⟨Γ⟩) Γ' (γ : Γ' --> Γ) (a : C⟨Γ'⊢ A[[γ]]⟩)
  :  ∏ (p : (A [[π A]]) [[γ ♯ a]] = A [[γ ♯ a;; π A]]) (p0 : γ ♯ a;; π A = γ),
   transportf (λ ι : Γ' --> Γ, C ⟨ Γ' ⊢ A [[ι]] ⟩) p0
     (transportf (λ B : C ⟨ Γ' ⟩, C ⟨ Γ' ⊢ B ⟩) p (ν A ⟦ γ ♯ a ⟧)) = a.
Proof.
  intros p p'.
  etrans; [ | apply cwf_law_2].
  match goal with | [ |- _ = transportf _ ?p1 _ ] => assert (T : p' = p1) end. 
  { apply homset_property. }
  rewrite T; clear T. apply maponpaths.
  match goal with | [ |- _ = transportf _ ?p1 _ ] => assert (T : p = p1) end.
  { apply (cwf_types_isaset C). }
  rewrite T; apply idpath.
Qed.  

Definition cwf_law_3 {CC : category} (C : cwf_struct CC) : comp_law_3 C
  :=  pr1 (pr2 (cwf_comp_laws C)).

Definition cwf_law_3_gen {CC : category} (C : cwf_struct CC) 
  (Γ : CC) (A : C ⟨ Γ ⟩) (Γ' Γ'' : CC) (γ : Γ' --> Γ) (γ' : Γ'' --> Γ')
  (a : C ⟨ Γ' ⊢ A [[γ]] ⟩) (p : (A [[γ]]) [[γ']] = A [[γ';; γ]]):
   γ';; γ ♯ a =
   (γ';; γ) ♯ transportf (λ B : C ⟨ Γ'' ⟩, C ⟨ Γ'' ⊢ B ⟩) p (a ⟦ γ' ⟧).
Proof.
  etrans. apply cwf_law_3.
  apply maponpaths.
  match goal with |[|- transportf _ ?e _ = _ ] => assert (T : e = p) end.
  { apply (cwf_types_isaset C). }
  rewrite T; apply idpath.
Qed.

Definition cwf_law_4 {CC : category} (C : cwf_struct CC) : comp_law_4 C
  := pr2 (pr2 (cwf_comp_laws C)).

Ltac imp := apply impred; intro.

Lemma isPredicate_cwf_laws (CC : category)
: isPredicate (@cwf_laws CC).
Proof.
  intros T.
  apply isofhlevelsn.
  intro H.
  set (X:= tpair _ T H : cwf_struct CC).
  apply (isofhleveltotal2).
  - apply isofhleveltotal2.
    + apply isofhleveltotal2;
      intros; repeat imp; apply (cwf_terms_isaset X).
    + intros.
      repeat (apply isofhleveldirprod); repeat imp;
        try apply homset_property.
      apply (isofhleveltotal2 1).
      * apply homset_property.
      * intros. apply (cwf_terms_isaset X).
  - intros.
    repeat (apply isofhleveldirprod).
    do 2 imp. apply isapropisaset.
Qed.
    

(** * Lemmas about CwFs, in particular that reindexing forms pullback *)

Section CwF_lemmas.

Generalizable Variable CC.
Context `{C : cwf_struct CC}.

Lemma map_to_comp_as_pair_cwf {Γ} {A : C⟨Γ⟩} {Γ'} (f : Γ' --> Γ∙A)
  :   (f ;; π A) ♯ (transportb _ (reindx_type_comp _ _ _) ((gen_elem A)⟦f⟧))
      = 
      f.
Proof.
  sym.
  etrans.
  apply (!id_right _ ).
  etrans.
  refine (maponpaths (fun g => f ;; g) (!cwf_law_4 _ _ _)).
  apply cwf_law_3.
Qed.




Lemma retype_term_pi {Γ} {A A' : C ⟨ Γ ⟩ } (p : A = A') (t : C ⟨ Γ ∙ A ⊢ A [[π A]]⟩ ) :
  transportf (λ B : C ⟨Γ⟩, C ⟨ Γ ∙ A ⊢ B [[π A]]⟩) p t
  =
  transportf (term C (Γ ∙  A)) (maponpaths (λ x : C⟨Γ⟩, x [[π A]]) p) t.
Proof.
  destruct p.
  apply idpath.
Defined.

Lemma pairing_mapeq {Γ} {A : C⟨Γ⟩} {Γ'} (f f' : Γ' --> Γ) (e : f = f')
                     (a : C ⟨ Γ' ⊢ A [[f]] ⟩)
  : f ♯ a
    = 
    f' ♯ (transportf (fun B => C⟨Γ' ⊢ B⟩ ) (maponpaths _ e) a).
Proof.
  destruct e. apply idpath.
Qed.

Lemma pairing_mapeq_gen {Γ} {Γ'} (f f' : Γ' --> Γ) {A : C⟨Γ⟩} (a : C ⟨ Γ' ⊢ A [[f]] ⟩) 
         (e : f = f') (p : A [[f]] = A [[f']])
  : f ♯ a
    = 
    f' ♯ (transportf (fun B => C⟨Γ' ⊢ B⟩ ) p a).
Proof.
  assert (T : p = (maponpaths _ e)).
  { apply (cwf_types_isaset C). }
  rewrite T.
  apply pairing_mapeq.
Qed.

Lemma rterm_typeeq {Γ} {A A': C⟨Γ⟩} (e : A = A') {Γ'} (f : Γ' --> Γ) (x : C ⟨ Γ ⊢ A ⟩)
  : transportf _ (maponpaths (fun b => b[[f]]) e) (x⟦f⟧)
    = (transportf _ e x) ⟦f⟧.
Proof.
  destruct e. apply idpath.
Qed.

Lemma transportf_rtype_mapeq {Γ} {A : C⟨Γ⟩} {Γ'} (f f' : Γ' --> Γ) (e : f = f')
                     (t : C ⟨ Γ' ⊢ A[[f]] ⟩)
  : transportf (fun g => C ⟨ Γ' ⊢ A[[g]] ⟩) e t
  = transportf _ (maponpaths (fun g => A[[g]]) e) t.
Proof.
  apply functtransportf.
Qed.

Lemma rterm_mapeq {Γ} {A : C⟨Γ⟩} {Γ'} {f f' : Γ' --> Γ} (e : f = f') (t : C ⟨ Γ ⊢ A ⟩)
  : t ⟦ f ⟧
  = transportb _ (maponpaths (fun g => A[[g]]) e) (t ⟦ f'⟧ ).
Proof.
  destruct e. apply idpath.
Qed.

(* A slightly odd statement, but very often useful.
   
   TODO: consider naming!
   TODO: try to use in proofs, instead of [transport_f_f] *)
Lemma term_typeeq_transport_lemma {Γ} {A A' A'': C ⟨ Γ ⟩} (e : A = A'') (e' : A' = A'')
  (x : C ⟨ Γ ⊢ A ⟩) (x' : C ⟨ Γ ⊢ A' ⟩)
  : transportf _ (e @ !e') x = x'
  -> transportf _ e x = transportf _ e' x'.
Proof.
  apply transportf_comp_lemma.
Qed.

Lemma term_typeeq_transport_lemma_2 {Γ} {A : C ⟨ Γ ⟩} (e : A = A)
  {x x' : C ⟨ Γ ⊢ A ⟩}
  : x = x'
  -> transportf _ e x = x'.
Proof.
  apply transportf_comp_lemma_hset.
  apply cwf_types_isaset.
Qed.

Lemma reindx_term_comp' {Γ Γ' Γ''} (γ : Γ' --> Γ) (γ' : Γ'' --> Γ') {A} (a : C ⟨ Γ ⊢ A ⟩)
  : transportf _ (reindx_type_comp _ _ _) (a ⟦ γ' ;; γ ⟧)
  = ((a ⟦ γ ⟧) ⟦ γ' ⟧).
Proof.
  eapply pathscomp0.
    apply maponpaths, (reindx_term_comp C).
  rew_trans_@.
  apply term_typeeq_transport_lemma_2. 
  apply idpath.
Qed.

(* TODO: consider giving this instead of current [cwf_law_2] ? *)
Definition cwf_law_2' Γ (A : C ⟨ Γ ⟩) Γ' (γ : Γ' --> Γ) (a : C ⟨ Γ' ⊢ A[[γ]] ⟩)
  : (ν A) ⟦γ ♯ a⟧
  = transportf _ (reindx_type_comp _ _ _)
      (transportb _ (maponpaths (fun g => A[[g]]) (cwf_law_1 _ _ _ _ _ _))
        a). 
Proof.
  eapply pathscomp0.
  2: { apply maponpaths, maponpaths. exact (cwf_law_2 _ _ _ _ γ a). }
  apply pathsinv0.
  rew_trans_@.
  etrans. apply maponpaths, transportf_rtype_mapeq.
  rew_trans_@.
  (* TODO: try simplyfying with [term_typeeq_transport_lemma] *)
  refine (@maponpaths _ _ (fun e => transportf _ e _) _ (idpath _) _).
  apply cwf_types_isaset.
Qed.

Definition pairing_transport  {Γ} {A A' : C⟨Γ⟩} (e : A = A')
  {Γ'} (γ : Γ' --> Γ) (a : C ⟨Γ'⊢A[[γ]]⟩)
: (γ ♯ a) ;; idtoiso (maponpaths (fun (B : C⟨Γ⟩) => Γ∙B) e)
= (γ ♯ (transportf (fun B => C ⟨ Γ' ⊢ B [[γ]] ⟩) e a)).
Proof.
  destruct e; simpl.
  apply id_right.
Defined.

Definition q_cwf {Γ} (A : C ⟨ Γ ⟩ ) {Γ'} (f : Γ' --> Γ)
  : (comp_obj  Γ' (A[[f]])) --> (Γ ∙ A).
Proof.
  set (T:= @pairing _ C).
  apply T with (γ := π _ ;; f).
  refine (transportb (term C (Γ' ∙ (A [[f]])) ) (reindx_type_comp _ _ A) _).
  apply gen_elem.
Defined.

Definition dpr_q_cwf 
  {Γ} (A : C ⟨ Γ ⟩)
  {Γ'} (f : Γ' --> Γ)
: (q_cwf A f) ;; (π A) = (π (A[[f]])) ;; f.
Proof.
  unfold q_cwf.
  apply cwf_law_1.
Qed.


Lemma rterm_univ {Γ} {A : C ⟨ Γ ⟩} {Γ'} (f : Γ' --> Γ)
  : ν (A[[f]])
   = transportf _ (reindx_type_comp _ _ _)
       (transportf _ (maponpaths (fun g => A[[g]]) (dpr_q_cwf A f))
         (transportb _ (reindx_type_comp _ _ _)
            ((ν A)⟦q_cwf A f⟧))).
Proof.
  sym.
  rew_trans_@.
  etrans.
  - apply maponpaths.
    apply cwf_law_2'.
  - rew_trans_@.
    apply term_typeeq_transport_lemma_2.
    apply idpath.
Qed.

(** The biggest work is in showing that the square of dependent projections/reindexings is a pullback.  

We split this up into several lemmas: 

- construction of the pullback pairing function; 
- proof that projections applied to the pairing recover the original maps; 
- and proof that the pairing map is the unique such map. 

*)

Definition dpr_q_pbpairing_cwf_aux
  {Γ} (A : C ⟨ Γ ⟩)
  {Γ'} (f : Γ' --> Γ)
  {X} (h : X --> Γ ∙ A) (k : X --> Γ') (H : h ;; π A = k ;; f)
: C ⟨ X ⊢ (A [[f]]) [[k]] ⟩
:= (transportf _ (reindx_type_comp _ _ _)
      (transportf (fun g => C ⟨ X ⊢ A[[g]] ⟩) H
        (transportf _ (!reindx_type_comp _ _ _)
          ((ν A)⟦h⟧)))).

Definition dpr_q_pbpairing_commutes
  {Γ} (A : C ⟨ Γ ⟩)
  {Γ'} (f : Γ' --> Γ)
  {X} (h : X --> Γ ∙ A) (k : X --> Γ') (H : h ;; π A = k ;; f)
  (hk := @pairing _ C Γ' (A[[f]]) X k (dpr_q_pbpairing_cwf_aux A f h k H))
: (hk ;; q_cwf A f = h) × (hk ;; π (A[[f]]) = k).
Proof.
  split. 2: { apply cwf_law_1. }
  unfold q_cwf.
  etrans.
  2: { apply map_to_comp_as_pair_cwf. }
  etrans.
    apply cwf_law_3.
  assert ((k ♯ (dpr_q_pbpairing_cwf_aux A f h k H)) ;; (π (A [[f]]) ;; f) 
          = h ;; π A) as e1.
    eapply pathscomp0. apply assoc.
    refine (_ @ !H).
    apply (maponpaths (fun g => g ;; f)).
    apply cwf_law_1.
  eapply pathscomp0. apply (pairing_mapeq _ _ e1).
  apply maponpaths.
  eapply pathscomp0. apply transport_f_f.
  eapply pathscomp0. apply maponpaths. refine (! rterm_typeeq _ _ _).
  eapply pathscomp0. apply transport_f_f.
  eapply pathscomp0. apply maponpaths, cwf_law_2'.
  rew_trans_@.
  eapply pathscomp0. apply maponpaths, transportf_rtype_mapeq.
  repeat (eapply pathscomp0; [ apply transport_f_f | ]).
  refine (maponpaths (fun e => transportf _ e _) _).
  apply cwf_types_isaset.
Qed.

Definition dpr_q_pbpairing_cwf
  {Γ} (A : C ⟨ Γ ⟩)
  {Γ'} (f : Γ' --> Γ)
  {X} (h : X --> Γ ∙ A) (k : X --> Γ') (H : h ;; π A = k ;; f)
: ∑ (hk : X --> Γ' ∙ (A[[f]])),
    ( hk ;; q_cwf A f = h
    × hk ;; π (A[[f]]) = k).
Proof.
  exists (@pairing _ C Γ' (A[[f]]) X k (dpr_q_pbpairing_cwf_aux A f h k H)).
  apply dpr_q_pbpairing_commutes.
Defined.

Definition dpr_q_pbpairing_cwf_mapunique
  {Γ} (A : C⟨Γ⟩)
  {Γ'} (f : Γ' --> Γ)
  {X} {h : X --> Γ ∙ A} {k : X --> Γ'} (H : h ;; π A = k ;; f)
  (hk : X --> Γ' ∙ (A [[f]]))
  (e2 : hk ;; q_cwf A f = h)
  (e1 : hk ;; π (A[[f]]) = k)
: hk = pr1 (dpr_q_pbpairing_cwf A f h k H).
Proof.
  eapply pathscomp0.
    eapply pathsinv0. apply map_to_comp_as_pair_cwf.
  eapply pathscomp0.
    apply (pairing_mapeq _ _ e1 _).
  simpl. apply maponpaths.
  eapply pathscomp0.
    apply maponpaths, maponpaths.
    eapply (maponpaths (fun t => t ⟦hk⟧)).
    apply rterm_univ.
  eapply pathscomp0.
    apply maponpaths, maponpaths. 
    eapply pathscomp0.
      symmetry. apply rterm_typeeq.
    apply maponpaths.
    eapply pathscomp0.
      symmetry. apply rterm_typeeq.
    apply maponpaths.
    eapply pathscomp0.
      symmetry. apply rterm_typeeq.
    apply maponpaths.
    symmetry. apply reindx_term_comp'.
  apply term_typeeq_transport_lemma.
  repeat (eapply pathscomp0; [ apply transport_f_f |]).
  eapply pathscomp0.
    apply maponpaths, (rterm_mapeq e2).
  eapply pathscomp0. apply transport_f_f.
  eapply pathscomp0.
  2: { symmetry. apply transportf_rtype_mapeq. }
  repeat apply term_typeeq_transport_lemma. 
  apply term_typeeq_transport_lemma_2.
  apply idpath.
Qed.

Definition dpr_q_pbpairing_cwf_unique
  {Γ} (A : C⟨Γ⟩)
  {Γ'} (f : Γ' --> Γ)
  {X} (h : X --> Γ ∙ A) (k : X --> Γ') (H : h ;; π A = k ;; f)
  (t : ∑ hk : X --> Γ' ∙ (A [[f]]),
       (hk ;; q_cwf A f = h) × (hk ;; π (A[[f]]) = k))
: t = dpr_q_pbpairing_cwf A f h k H.
Proof.
  destruct t as [hk [e2 e1] ]. 
  unshelve refine (@total2_paths_f _ _ (tpair _ hk (tpair _ e2 e1)) _ 
    (dpr_q_pbpairing_cwf_mapunique A f H hk e2 e1) _).
  unshelve refine (total2_paths_f _ _); apply homset_property.
Qed.

Lemma is_pullback_reindx_cwf : ∏ (Γ : CC) (A : C⟨Γ⟩) (Γ' : CC) 
   (f : Γ' --> Γ),
   isPullback (dpr_q_cwf A f).
Proof.
  intros.
  apply make_isPullback; try assumption.
  intros e h k H.
  exists (dpr_q_pbpairing_cwf _ _ h k H).
  apply dpr_q_pbpairing_cwf_unique.
Defined.
  
End CwF_lemmas.
