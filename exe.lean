
   import data.nat data.bool data.prod data.list data.sum
          data.unit data.uprod data.tuple data.option

   namespace Exe open nat bool prod sum list classical option

      -- io

      structure ok    := (data: Type)
      structure error := (data: Type)
      structure io    := (code: Type) (data: Type)
      inductive proto := ok
                       | error
                       | io

      -- app

      structure app  (S : Type) (P: Type) :=
                (spawn  : P → S)
                (run    : S → P)
                (action : P → S → S)

      -- kvs

      structure table     := (name: string) (attr: list string) (keys: list string) (gen: ℕ)
      structure container := (table: table) (id: ℕ) (io: io) (size: ℕ)
      structure iterator  := -- (feed: container) 
                             (id: ℕ) (next: ℕ) (prev: ℕ)
      inductive direction := forward | backward
      structure person extends iterator
      structure group  extends iterator := (names: list string)

      inductive kvs :=
                     | add: iterator → kvs
                     | remove: iterator → kvs
                     | reduce: iterator → direction → kvs
                     | proto

      structure store :=
                (sup: list container)
                (tab: list table)
                (calculation: iterator → container → container)
                (action: kvs → container → container)

      definition cal : iterator → container → container := λ x y, y
      definition act : kvs → container → container := λ x y, y

      definition next (big: iterator) : ℕ := match big with {| iterator, next := v |} := v end
 
      check group
      eval next (Exe.group.mk 0 0 0 nil)

      check {| store, sup := nil,
                      tab := nil,
                      calculation := cal,
                      action := act  |}
      

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
                             (io: io)
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

      -- bundle

      structure bundle :=
                (application: proc)
                (database: store)

end Exe

