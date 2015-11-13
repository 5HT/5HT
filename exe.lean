import data.nat data.bool data.prod data.list
namespace Exe open nat bool prod list classical

      -- basic i/o protocol
      -- storing computation results in separate lists inside application signatures

      structure ok    (A : Type)            := (val: A)
      structure error (A : Type)            := (val: A)
      structure io    (A : Type) (B : Type) := (exe: A) (val: B)
      inductive proto (O : Type) (E : Type) : Type :=
                | ok     : O     → proto O E
                | error  : E     → proto O E
                | io     : O → E → proto O E

      -- high level basic kv storage interface

      structure kv [class] (T K V: Type) :=
                (get : Π (t: T) (k: K) (v: V), T → K → proto V V)
                (put : Π (t: T) (k: K) (v: V), T → K → V → proto V V)

      -- interface for stores with compound keys

      structure indexed [class] (T K V: Type)
        extends kv T K V := (index : Π (t: T) (k: K) (v: V), T → K → proto V V)

      -- table metainfo persistent container state and iterator cursor

      structure table (T: Type) := (tab : T) (attr : list string) (keys : list string)
      structure container       := (top : ℕ) (size : ℕ)
      structure iterator        := (id  : ℕ) (next : ℕ) (prev : ℕ)

      check @table.mk

      -- feed server state

      structure feed [class] (I C K V: Type)
        extends kv I K V := (container : table C)
                            (iterator  : table I)
                            (add : Π (i: I) (v: V), I → V → proto V V)
                            (rem : Π (i: I) (v: V), I → V → proto V V)

      -- process server state

      structure process (docs : Type) (tasks flows events : Type) (P O E : Type)
        extends table P,
                iterator := (env : list docs)
                            (tax : list (prod events (prod tasks flows)))
                            (io  : list (io O E))

      check @process.tab

      -- applications' state and protocol

      structure BPE [class] (S : Type) (P: Type) := 
                (spawn  : P → S)
                (run    : S → P)
                (get    : P → S → S)
                (step   : P → S → S)

      structure N2O [class] (S : Type) (P: Type) :=
                (spawn  : P → S)
                (run    : S → P)
                (get    : P → S → S)
                (handle : P → S → S)

      -- storage's table and result

                check @N2O.rec

      check @feed.add

end Exe

