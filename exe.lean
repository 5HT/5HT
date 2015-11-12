import data.nat data.bool data.prod data.list
namespace Exe open nat bool prod list classical

      structure TIME  (A: Type) := mk :: (tim: A)
      structure OK    (A: Type) := mk :: (dat: A)
      structure ERROR (A: Type) := mk :: (dat: A)
      structure IO    (A: Type)
                      (B: Type) := mk :: (eva: A) (dat: B)

      inductive PROTO (O : Type) : Type :=
                | ok     : OK    O    → PROTO O
                | error  : ERROR O    → PROTO O
                | io     : IO    O O  → PROTO O

      structure BPE [class] (S : Type) (P: Type) :=
                (spawn  : S → S)
                (run    : S → S)
                (get    : P → S → S)
                (action : P → S → S)

      structure N2O [class] (S  : Type) (P: Type) :=
                (spawn  : S → S)
                (run    : S → S)
                (get    : P → S → S)
                (event  : P → S → S)

                check @N2O.rec

      structure KV [class] (T K V: Type) :=
                mk :: (get: T → K → V)
                      (set: T → K → V)

      structure KVS (T K V: Type) extends KV T K V :=
                mk :: (add: T → K → V)
                      (rem: T → K → V)

      structure Container [class] (A: Type) :=
                mk :: (top: A)
                      (count: nat)

      structure Iterator [class] (A T: Type) :=
                mk :: (id:   nat)
                      (next: A)
                      (prev: A)
                      (time: TIME nat)
                      (cons: Π A: Type, A → Container A → Container A)

      structure ITER [class] (A: Type) :=
                      (T: Type)
                      (id:   nat)
                      (next: A)
                      (prev: A)
                      (time: T)
                      (cons: Π A: Type, A → Container A → Container A)

      check ITER.rec
      check @Iterator.cons

end Exe

