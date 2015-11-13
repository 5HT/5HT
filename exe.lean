import data.nat data.bool data.prod data.list
namespace Exe open nat bool prod list classical

      -- basic protocol

      structure ok    (A: Type)           := (val: A)
      structure error (A: Type)           := (val: A)
      structure io    (A: Type) (B: Type) := (exe: A) (val: B)
      inductive proto (O: Type) (E: Type) :=
                                          | ok: O → proto O E
                                          | error: E → proto O E
                                          | io: O → E → proto O E

      -- simple documents

      structure task            := (name: string)
      structure event           := (name: string)
      structure flow            := (source: task) (target: task)
      structure subscription    := (who: ℕ) (whom: ℕ) (how: Type)

      -- metainfo

      structure table (T: Type) := (tab: T) (attr: list string) (keys: list string)
      structure id_seq          := (thing: string) (id: ℕ)

      -- all registered documents

      inductive docs  :=
                      | subscription: ℕ → ℕ → Type → docs
                      | user: list string → list string → docs
                      | process: list task → list flow → list event → docs → docs

      -- store
 
      structure kv [class] (T : Type) (P : Type) :=
                (get: Π (t: T), T → ℕ    → P)
                (put: Π (t: T), T → docs → P)

      structure indexed [class] (T: Type) (P : Type)
        extends kv T P := (index : Π (t : ℕ), list ℕ → list P)

      -- persistent traversable

      structure container                             := (id: ℕ) (top: ℕ) (size: ℕ)
      structure iterator (T: Type) extends kv T T     := (type: T) (feed: container) (id: ℕ) (next: ℕ) (prev: ℕ)
      structure user     (T: Type) extends iterator T := (names: list string) (surnames: list string)

      -- feed server state

      structure feed [class] (T: Type) (S: Type) 
        extends iterator T,
                container := (errors    : list (error S))
                             (add       : Π (d: docs), docs → S)
                             (remove    : Π (d: docs), docs → S)

      -- process server state

      structure process (tasks flows events : Type) (S P E : Type)
        extends iterator P := (env: list docs)
                              (container: container)
                              (feed_id: ℕ)
                              (taxonomy: prod (prod tasks flows) events)
                              (io: list (io P E))
                              (spawn: P → S)
                              (run:   S → P)
                              (retrive: unit → S → S)
                              (action:     P → S → S)

      -- application state and protocol

      structure N2O [class] (S : Type) (P: Type) :=
                (spawn  : P → S)
                (run    : S → P)
                (get    : P → S → S)
                (handle : P → S → S)

      check @process.action
      check @N2O.rec
      check @feed.add
      check @table.mk


end Exe

