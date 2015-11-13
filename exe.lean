import data.nat data.bool data.prod data.list
namespace Exe open nat bool prod list classical

      -- basic protocol

      structure ok    (A : Type)            := (val : A)
      structure error (A : Type)            := (val : A)
      structure io    (A : Type) (B : Type) := (exe : A) (val : B)
      inductive proto (O : Type) (E : Type) : Type  :=
                | ok     : O     → proto O E
                | error  : E     → proto O E
                | io     : O → E → proto O E

      -- persistent types

      structure table (T: Type) := (tab : T) (attr : list string) (keys : list string)
      structure container       := (top : ℕ) (size : ℕ)
      structure iterator        := (id  : ℕ) (next : ℕ) (prev : ℕ)
      structure subscription    := (who : ℕ) (whom : ℕ) (how  : Type)
      structure user extends iterator := (names : list string) (surnames : list string)
      structure task  := (name   : string)
      structure event := (name   : string)
      structure flow  := (source : task) (target : task)
      inductive docs  : Type :=
                | subscription : ℕ → ℕ → Type                 → docs
                | user         : list string → list string    → docs
                | process      : list task → list flow → list event → docs → docs 

      -- basic kv store

      structure kv [class] (T : Type) (P : Type) :=
                (get : Π (t : T), T → ℕ    → P)
                (put : Π (t : T), T → docs → P)

      -- extended store with secondary indexes

      structure indexed [class] (T: Type) (P : Type)
        extends kv T P := (index : Π (t : ℕ), list ℕ → list P)

      -- feed server state

      structure feed [class] (C T: Type) (P: Type)
        extends kv T P := (container : table C)
                          (iterator  : table T)
                          (errors    : list (error P))
                          (add       : Π (d: docs), docs → P)
                          (rem       : Π (d: docs), docs → P)

      -- process server state

      structure process (tasks flows events : Type) (S P E : Type)
        extends iterator := (env   : list docs)
                            (feed  : feed container P P)
                            (def   : prod (prod tasks flows) events)
                            (io    : list (io P E))
                            (spawn : P → S)
                            (run   : S → P)
                            (get   : unit → S → S)
                            (act   : P → S → S)

      -- application state and protocol

      structure N2O [class] (S : Type) (P: Type) :=
                (spawn  : P → S)
                (run    : S → P)
                (get    : P → S → S)
                (handle : P → S → S)

      check @process.act
      check @N2O.rec
      check @feed.add
      check @table.mk


end Exe

