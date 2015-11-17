
      import data.nat data.bool data.prod data.list data.sum data.stream
             data.unit data.uprod data.tuple data.option
   namespace exe open nat bool prod sum list classical option stream

      record app (P S: Type) := (spawn  : P → S)
                                (run    : S → P)
                                (action : P → S → S)

  definition ids       := option ℕ
      record table     := (name: string) (attr: list string) (keys: list string) (gen: ℕ)
      record container := (top: ids) (size: ℕ)
      record iterator  := (id: ids) (next: ids) (prev: ids)
   inductive direction := forward | backward

      record person extends iterator := (names: list string)
      record group  extends iterator := (name:  list string)
      record task      := (name: string)
      record event     := (name: string)
      record flow      := (source: task) (target: task)
      record process
     extends iterator :=
             (env: list iterator)
             (feed_id: ℕ)
             (taxonomy: prod (prod (list task) (list flow)) (list event))

      record proto := (data: iterator)
      record db     extends proto
      record add    extends db
      record reduce extends db := (dir:  direction)
      record remove extends db
      record ok     extends proto
      record error  extends proto
      record io     extends proto := (effects: iterator)
  definition kvs    := add + remove + reduce + ok + error + io
      record procs extends container := (io: io)

      record store
     extends app proto container :=
             (sup: list container)
             (tab: list table)
             (calculation: iterator → container → container)

  definition top    (x: container) : ids      := match x with {| container, top := v |}   := v end
  definition size   (x: container) : ℕ        := match x with {| container, size := v |}  := v end
  definition next   (x: iterator)  : ids      := match x with {| iterator, next := v |}   := v end
  definition data   (x: proto)     : iterator := match x with {| proto, data := v |}      := v end
  definition id     (x: iterator)  : ids         := match x with {| iterator, id := v |}  := v end
  definition names  (x: person)    : list string := match x with {| person, names := v |} := v end
  definition action (x: store)     : proto → container → container :=  match x with {| store, action := v |} := v end
  definition cal : iterator → container → container := λ x y, container.mk (id x) (addl (size y) 1)
  definition act : proto → container → container := λ x y, cal (data x) y

       check group
       print prefix names
       print instances inhabited
        eval (names (exe.person.mk (some 0) (some 0) (some 0) (cons "maxim" nil)))
       print "maxim"
       check action

  definition empty_container := {| container, top := none, size := 0 |}
  definition empty_store     := {| store,
                         sup := nil,
                         tab := nil,
                       spawn := λ x, empty_container,
                         run := λ x, ok.mk (iterator.mk (some 0) none none),
                 calculation := λ x y, container.mk (id x) (addl (size y) 1),
                      action := λ x y, cal (data x) y |}

        eval (action empty_store) (add.mk (person.mk (some 12) none none nil)) empty_container

      record kv :=
                (get:    Π (t: iterator), iterator → proto)
                (put:    Π (t: iterator), iterator → proto)
                (index : Π (t: iterator), iterator → proto)

      record proc
     extends app proto process :=
             (sup: list process)

      record bundle :=
             (application: proc)
             (database: store)

         end exe
