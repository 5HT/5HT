module Exe
import Prelude

    record Ok where
           constructor MkOk
           v: Type

    record Err where
           constructor MkErr
           v: Type

    record Io where
           constructor MkIo
           f: Type
           v: Type

    data Proto = Ok | Err | Io

    class App (p: Proto) (s: Type) where
       spawn: p -> s
       run: s -> p
       action: p -> s -> s

