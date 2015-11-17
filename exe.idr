module Exe

    record OK where
           constructor MkOK
           v: Type

    record ERR where
           constructor MkERR
           v: Type

    record IO where
           constructor MkIO
           f: Type
           v: Type

    data Proto = Ok | Err | Io

    class App (p: Type) (s: Type) where
       spawn: p -> s
       run: s -> p
       action: p -> s -> s

