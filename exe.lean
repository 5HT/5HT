import data.nat data.bool data.prod data.list data.sum
namespace Exe open nat bool prod sum list classical 

      -- application

      structure n2o (S : Type) (P: Type) :=
                (spawn  : P → S)
                (run    : S → P)
                (action : P → S → S)

      -- io

      structure ok    := (val: Type)
      structure error := (val: Type)
      structure io    := (exe: Type) (val: Type)
      inductive proto := ok
                       | error
                       | io

      -- kvs

      structure container := (id: ℕ) (io: io) (size: ℕ)
      structure iterator  := (feed: container) (id: ℕ) (next: ℕ) (prev: ℕ)
      structure table (T: Type) := (tab: T) (name: string) (attr: list string) (keys: list string)
      structure id_seq          := (thing: string) (id: ℕ)
      structure subscription    := (who: ℕ) (whom: ℕ) (how: Type)
      structure user extends iterator := (names: list string) (surnames: list string)
      inductive direction := forward | backward

      inductive kvs :=
                     | add: iterator → kvs
                     | remove: iterator → kvs
                     | reduce: iterator → direction → kvs
                     | proto

      structure store :=
                (action: Π (d: container), kvs → container → container)

      -- kv

      structure kv :=
                (get:    Π (t: iterator), iterator → proto)
                (put:    Π (t: iterator), iterator → proto)
                (index : Π (t: iterator), iterator → proto)

      -- bpe

      structure task      := (name: string)
      structure event     := (name: string)
      structure flow      := (source: task) (target: task)
      structure process
        extends iterator  := (env: list iterator)
                             (feed_id: ℕ)
                             (taxonomy: prod (prod (list task) (list flow)) (list event))

      inductive bpe :=
                     | run: unit → bpe
                     | get: unit → bpe
                     | goto: task → bpe
                     | complete: task → bpe
                     | amend: string → bpe
                     | event: event → bpe
                     | proto

      structure proc :=
                (spawn:  Π (t: process), process → process)
                (action: Π (t: process), bpe → process → process)

      check @proc.action
      check @n2o.rec
      check @store.action
      check @table.mk


end Exe

