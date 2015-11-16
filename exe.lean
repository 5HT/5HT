import data.nat data.bool data.prod data.list data.sum
namespace Exe open nat bool prod sum list classical 

      -- io

      structure ok    := (data: Type)
      structure error := (data: Type)
      structure io    := (code: Type) (data: Type)
      inductive proto := ok
                       | error
                       | io

      -- application

      structure n2o  (S : Type) (P: Type) :=
                (spawn  : P → S)
                (run    : S → P)
                (action : P → S → S)

      -- kvs

      structure table     := (name: string) (attr: list string) (keys: list string)
      structure container := (table: table) (id: ℕ) (io: io) (size: ℕ)
      structure iterator  := (feed: container) (id: ℕ) (next: ℕ) (prev: ℕ)
      inductive direction := forward | backward
      structure id_seq    := (thing: string) (id: ℕ)

      inductive kvs :=
                     | add: iterator → kvs
                     | remove: iterator → kvs
                     | reduce: iterator → direction → kvs
                     | proto

      structure store :=
                (sup: list iterator)
                (seq: list id_seq)
                (tab: list table)
                (tx: Π (d: container) (d: iterator), iterator → container → container)
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
                (sup: list process)
                (spawn:  Π (t: process), process → process)
                (action: Π (t: process), bpe → process → process)

      check @proc.action
      check @n2o.rec
      check @store.action
      check @table.mk


end Exe

