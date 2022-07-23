
class SemanticallyEntail (α : Type u) (β : Type v) where
  entail : α → β → Prop

infix:50 " ⊨ " => SemanticallyEntail.entail

class SyntacticallyEntail (α : Type u) (β : Type v) where
  entail : α → β → Prop

infix:50 " ⊢ " => SyntacticallyEntail.entail

