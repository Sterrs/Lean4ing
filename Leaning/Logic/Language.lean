import Leaning.Util.Vector
import Leaning.Util.Set
-- Building up a first-order predicate logic system with equality

-- We have arity given by (funArity : Ω → Nat) (predArity : Π → Nat)
structure Language where
  (Ω Pred : Type) -- Π is not a valid name :(
  funArity : Ω → Nat
  predArity : Pred → Nat

inductive Term (L : Language) where
  | var : String → Term L
  | funApp  : (f : L.Ω) → Vector (Term L) (L.funArity f)  → Term L

inductive Formula (L : Language) where
  | falsehood : Formula L
  | equality : Term L → Term L → Formula L
  | predApp : (p : L.Pred) → Vector (Term L) (L.predArity p) → Formula L
  | impl : Formula L → Formula L → Formula L
  | forAll : String → Formula L → Formula L
