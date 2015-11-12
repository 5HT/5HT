import data.nat data.bool data.prod data.list
namespace Exe
open nat bool prod list classical

      structure OK    (A: Type) := mk :: (dat: A)
      structure ERROR (A: Type) := mk :: (dat: A)
      structure IO    (A: Type)
                      (B: Type) := mk :: (eva: A) (dat: B)

      structure Container (A: Type) :=
                mk :: (top: A)
                      (count: nat)

      structure Iterator (A: Type) (Protocol: Type) :=
                mk :: (id:   nat)
                      (next: A)
                      (prev: A)
                      (time: A)
                      (get:    Π A: Type, A → prod → Protocol)
                      (delete: Π A: Type, A → prod → Protocol)
                      (remove: Π A: Type, A → prod → Protocol)
                      (put:    Π A: Type, Container A → Protocol)
                      (add:    Π A: Type, Container A → Protocol)

      check @Iterator.cons

      structure N2O [class] (state    : Type)
                            (protocol : Type) :=
                      mk :: (event    : protocol → state → state)

      structure BPE [class] (state    : Type)
                            (protocol : Type) :=
                      mk :: (action   : protocol → state → state)


end Exe

