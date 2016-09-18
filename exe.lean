
      import data.nat data.bool data.prod data.list data.sum data.stream
             data.unit data.uprod data.tuple data.option
   namespace exe open nat bool prod sum list classical option stream

      record app (P S: Type) := (spawn  : P → S)
                                (run    : S → P)
                                (action : P → S → S)

  definition ids       := option ℕ
      record table     := (name: string) (attr: list string) (keys: list string) (gen: ℕ)
      record container := (top: ids) (size: ℕ) (carrier: Type)
      record iterator  := (id: ids) (next: ids) (prev: ids) (carrier: Type)
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
  definition kvs    := add + remove + reduce + ok + error

      record store
     extends app proto container :=
             (sup: list container)
             (tab: list table)
             (calculation: iterator → container → container)

  definition carrier (x: container) : Type     := match x with {| container, carrier := v |} := v end
  definition top     (x: container) : ids      := match x with {| container, top := v |}   := v end
  definition size    (x: container) : ℕ        := match x with {| container, size := v |}  := v end
  definition next    (x: iterator)  : ids      := match x with {| iterator, next := v |}   := v end
  definition data    (x: proto)     : iterator := match x with {| proto, data := v |}      := v end
  definition id      (x: iterator)  : ids         := match x with {| iterator, id := v |}  := v end
  definition names   (x: person)    : list string := match x with {| person, names := v |} := v end
  definition action  (x: store)     : proto → container → container :=  match x with {| store, action := v |} := v end
  definition cal : iterator → container → container := λ x y, container.mk (id x) (addl (size y) 1) (carrier y)
  definition act : proto → container → container := λ x y, cal (data x) y

       check group
       print prefix names
       print instances inhabited
        eval (names (exe.person.mk (some 0) (some 0) (some 0) ℕ (cons "maxim" nil)))
       print "maxim"
       check action

  definition new_container (x: Type) := {| container, top := none, size := 0, carrier := x |}
  definition new_store     := {| store,
                         sup := nil,
                         tab := nil,
                       spawn := λ x, new_container person,
                         run := λ x, ok.mk (iterator.mk (some 0) none none (carrier x)),
                 calculation := λ x y, container.mk (id x) (addl (size y) 1) (carrier y),
                      action := λ x y, cal (data x) y |}

        eval (action new_store) (add.mk (person.mk (some 11) none none person nil))
                                ((action new_store) (add.mk (person.mk (some 12) none none person nil))
                                                    (new_container person))

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

      -- control

      record pure (P: Type → Type) (A: Type) := (return: P A)

      record functor (F: Type → Type) (A B: Type) := (fmap: (A → B) → F A → F B)

      record applicative (F: Type → Type) (A B: Type)
     extends pure F A, functor F A B := (ap: F (A → B) → F A → F B)

      record monad (F: Type → Type) (A B: Type)
     extends pure F A, functor F A B := (join: F (F A) → F A)

     -- effects

      record eff        (x: Type)               := (carrier : x)
      record io         (x: Type) extends eff x := (get: unit → eff x) (put: x → eff x)
      record exception  (x: Type) extends eff x := (raise: x → eff x)
      record comm       (x: Type) extends eff x := (recv: unit → eff x) (send: x → eff x)
      record state      (x: Type) extends eff x, app proto x

    definition unpure (x: Type) := proto → x → eff x

      print unpure

         end exe
