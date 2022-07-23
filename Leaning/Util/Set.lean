-- Some `Set` theory, this is Lean's version of set theory, not real set theory
import Leaning.Util.Notation

def Set (α : Type u) := α → Prop

instance : Mem α (Set α) := ⟨fun a S => S a⟩
