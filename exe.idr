module Exe
import Prelude

    record Ok where
           constructor MkOkey
           v: Type

    record Err where
           constructor mkErr
           v: Type

    record Io where
           constructor mkIo
           fun: Type
           val: Type

    data Proto = Ok
               | Error
               | Io

    class App p s where
       spawn: p -> s
       run: s -> p
       action: p -> s -> s

