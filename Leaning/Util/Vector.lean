-- A vector is like a List, but has a specified number of elements

-- Why is this not in the stdlib?
-- There are other ways to define this, but it needs to be `inductive`
-- to allow constructors of other inductive types to have constructors
-- of the form Vector A n → A
-- TODO: make this Type u instead of Type. This will break my elaboration
-- code for the predicate logic DSL
inductive Vector (α : Type) : Nat → Type where
  | nil  : Vector α 0
  | cons : α → Vector α n → Vector α (n+1)

namespace Vector

private def defaultVector [Inhabited α] : (n : Nat) → (Vector α n)
| .zero => nil
| .succ n => cons default (defaultVector n)

instance vectorInhabited [Inhabited α]: Inhabited (Vector α n) := ⟨defaultVector n⟩

def map (f : α → β) : Vector α n → Vector β n
| nil       => nil
| cons a as => cons (f a) (map f as)

end Vector
