import Lean
import Leaning.Logic.Language

-- Attempt to make a DSL for Formulae, using recursive macros

open Lean Elab Meta Elab.Term Parser

declare_syntax_cat logic_term

syntax ident : logic_term
-- Notation for inserting lean code in place of a `Term`
syntax "{" term "}" : logic_term
-- Notation for function symbol application
syntax "{"term"}("logic_term,*")" : logic_term
-- Notation for function application, when function symbol has
-- simple Lean name
syntax ident"("logic_term,*")" : logic_term
syntax "(" logic_term ")" : logic_term

syntax "logicTerm " logic_term : term

-- This function turns a list of logic terms into a vector of the correct length
private def toVec : List (TSyntax `logic_term) → MacroM (TSyntax `term)
  | []      => `(Vector.nil)
  | x :: xs => do `(Vector.cons (logicTerm $x) $(← toVec xs))

-- macro_rules converts Syntax to Syntax
macro_rules
  | `(logicTerm $i:ident) => `(Term.var $(Syntax.mkStrLit i.getId.toString))
  | `(logicTerm { $t:term }) => `($t)
  | `(logicTerm ( $l:logic_term )) => `(logicTerm $l)
  | `(logicTerm $i:ident($l:logic_term,*)) => `(logicTerm {$i}($l,*))
  | `(logicTerm { $t:term }($l:logic_term,*)) => do `(Term.funApp $t $(← toVec l.getElems.data))

-- Not really what we want to be possible tbh, probably not super hard to fix
#check logicTerm x.y

declare_syntax_cat logic_formula

syntax "⊥" : logic_formula
syntax logic_term "=" logic_term : logic_formula
-- Notation for predicate symbol application
syntax "{"term"}("logic_term,*")" : logic_formula
syntax ident"("logic_term,*")" : logic_formula
-- Need to make sure this is right-associative
syntax logic_formula "=>" logic_formula : logic_formula
-- Brackets for clarity... are they needed?
syntax "(∀" ident ")" logic_formula : logic_formula
-- Allow bracketing at will
syntax "(" logic_formula ")" : logic_formula
syntax "{" term "}" : logic_formula

syntax "logicFormula " logic_formula : term

macro_rules
  | `(logicFormula ⊥) => `(Formula.falsehood)
  | `(logicFormula $x:logic_term = $y:logic_term) => `(Formula.equality (logicTerm $x) (logicTerm $y))
  | `(logicFormula {$t:term}($l:logic_term,*)) => do `(Formula.predApp $t $(← toVec l.getElems.data))
  | `(logicFormula $i:ident($l:logic_term,*)) => `(logicFormula {$i}($l,*))
  | `(logicFormula $a => $b) => `(Formula.impl (logicFormula $a) (logicFormula $b))
  | `(logicFormula (∀ $i:ident) $l:logic_formula) =>
    `(Formula.forAll $(Syntax.mkStrLit i.getId.toString) (logicFormula $l))
  | `(logicFormula ($l:logic_formula)) => `(logicFormula $l)
  | `(logicFormula {$t:term}) => `($t)

-- That's it for the basics, but we might as well also add in some quality-of-life macros

syntax "formula " logic_formula " in " term : term

macro_rules
  | `(formula $l in $t:term) => `((logicFormula $l : Formula $t))

syntax "¬" logic_formula : logic_formula
syntax logic_formula "∨" logic_formula : logic_formula
syntax logic_formula "∧" logic_formula : logic_formula
syntax logic_formula "<=>" logic_formula : logic_formula
syntax "(∃" ident ")" logic_formula : logic_formula

macro_rules
  | `(logicFormula ¬$p) => `(logicFormula $p => ⊥)
  | `(logicFormula $p ∨ $q) => `(logicFormula (¬$p) => $q)
  | `(logicFormula $p ∧ $q) => `(logicFormula ¬($p => ¬$q))
  | `(logicFormula $p <=> $q) => `(logicFormula ($p => $q) ∧ ($q => $p))
  | `(logicFormula (∃ $i:ident) $p) => `(logicFormula ¬(∀ $i) ¬$p)
