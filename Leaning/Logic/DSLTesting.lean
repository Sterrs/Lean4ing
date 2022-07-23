import Leaning.Logic.DSL

open Lean Elab Meta Elab.Term Parser
namespace PA

inductive PAOperator where
  | zero : PAOperator
  | succ : PAOperator
  | add : PAOperator
  | mul : PAOperator

def langOfPA : Language :=
{
  Ω := PAOperator,
  Pred := Empty,
  funArity := fun f =>
    match f with
    | .zero => 0
    | .succ => 1
    | .add  => 2
    | .mul  => 2,
  predArity := fun _ => 0
}

open PAOperator

local syntax logic_term " + " logic_term : logic_term
local syntax logic_term " * " logic_term : logic_term
local syntax num : logic_term

local macro_rules
  | `(logicTerm $a:logic_term + $b:logic_term) => `(logicTerm add($a, $b))
  | `(logicTerm $a:logic_term * $b:logic_term) => `(logicTerm mul($a, $b))
  -- Pretty dangerous
  | `(logicTerm $n:num) => do
    let n : Nat := n.1.toNat
    let rec mkNum : Nat → MacroM (TSyntax `logic_term)
      | .zero => `(logic_term| zero())
      | .succ k => do `(logic_term| succ($(← mkNum k)))
    `(logicTerm $(← mkNum n))

-- Okay sure but this won't evaluate
#check formula (∀ x) x + 1 = succ(x) in langOfPA
#check formula 1 + 1 = 2 in langOfPA

end PA


section ZF

inductive ZFPredicate where
  | elemOf : ZFPredicate

def langOfZF : Language :=
{
  Ω := Empty,
  Pred := ZFPredicate,
  funArity := fun _ => 0,
  predArity := fun p =>
    match p with
    | .elemOf => 2
}

local syntax logic_term " ∈ " logic_term : logic_formula

open ZFPredicate

local macro_rules
  | `(logicFormula $a:logic_term ∈ $b:logic_term) => `(logicFormula elemOf($a, $b))

def axiomOfExtensionality : Formula langOfZF :=
  logicFormula (∀ x)(∀ y) ((∀ z) z ∈ x <=> z ∈ y) => x = y

def tautology : Formula langOfZF :=
  logicFormula (∀ x) ¬x ∈ x

def axiomOfSeparation : Set (Formula langOfZF) := fun f =>
  ∃ p : Formula langOfZF, f = formula (∀ x)(∃ y)(∀ z) z ∈ y <=> (z ∈ x ∧ {p}) in langOfZF

#reduce axiomOfSeparation

end ZF