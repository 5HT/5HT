-module(morte).
-compile(export_all).
-define(is_space(C), C =:= $\r; C =:= $\s; C =:= $\t).
-define(is_alpha(C), C >= $a, C =< $z; C >= $A, C =< $Z; C >= $0, C =< $9).
-define(is_termi(C), C =:= $!; C =:= $#; C =:= $$; C =:= $%; C =:= $&; C =:= $(; C =:= $:;
                     C =:= $+; C =:= $-; C =:= $*; C =:= $/; C =:= $.; C =:= $\\;C =:= $);
                     C =:= $<; C =:= $>; C =:= $=; C =:= $|; C =:= $^; C =:= $~; C =:= $@).

tokens(<<>>,                  _, {_,C}, Acc) -> lists:reverse(stack(C,Acc));
tokens(<<$\n,     R/binary>>, L, {_,C}, Acc) -> tokens(R,L+1,{1,[]},   stack(C,Acc));
tokens(<<$(,      R/binary>>, L, {t,C}, Acc) -> tokens(R,L,{t,[$(]},   stack(C,Acc));
tokens(<<$),      R/binary>>, L, {t,C}, Acc) -> tokens(R,L,{t,[$)|C]}, stack(C,Acc));
tokens(<<$(,      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{t,[]},     [open   | stack(C,  Acc)]);
tokens(<<$),      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{t,[]},     [close  | stack(C,  Acc)]);
tokens(<<$:,      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [colon  | stack(C,  Acc)]);
tokens(<<$*,      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [star   | stack(C,  Acc)]);
tokens(<<"→"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [arrow  | stack(C,  Acc)]);
tokens(<<"λ"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [lambda | stack(C,  Acc)]);
tokens(<<"∀"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [pi     | stack(C,  Acc)]);
tokens(<<X,       R/binary>>, L, {a,C}, Acc) when ?is_alpha(X) -> tokens(R,L,{a,[X|C]},            Acc);
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_alpha(X) -> tokens(R,L,{a,[X]},    stack([C],Acc));
tokens(<<X,       R/binary>>, L, {t,C}, Acc) when ?is_termi(X) -> tokens(R,L,{t,[X|C]},            Acc);
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_termi(X) -> tokens(R,L,{t,[X]},    stack(C, [Acc]));
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_space(X) -> tokens(R,L,{s,[C]},              Acc).

stack(C,Acc) ->
   case lists:flatten(C) of
        [] -> Acc;
        "(" -> lists:flatten([open|Acc]);
        ")" -> lists:flatten([close|Acc]);
        [X|Aa] when ?is_alpha(X) -> lists:flatten([{name,lists:reverse([X|Aa])}|Acc]);
        Re -> lists:flatten([list_to_atom(lists:reverse(Re))|Acc]) end.

read() -> {ok,Bin} = file:read_file("cat2.txt"), io:format("~ts~n",[unicode:characters_to_list(Bin)]), tokens(Bin,0,{1,[]},[]).
          main() -> expr(read(),[]).

%    EXPR := "lambda" "(" LABEL ":" EXPR ")" "arrow" EXPR => {LAM,[{NAME:LABEL,I:EXPR, O;EXPR]}
%          | "pi"     "(" LABEL ":" EXPR ")" "arrow" EXPR => {PI, [{NAME:LABEL,I:EXPR, O;EXPR]}
%          |                        BEXPR    "arrow" EXPR => {PI, [{"_",       I:BEXPR,O;EXPR]}
%
%   BEXPR :=  BEXPR AEXPR                                 => {APP,I:AEXPR,O:AEXPR}
%          |  AEXPR                                       =>
%
%   AEXPR :=  EXPR AEXPR                                  => {APP,I:AEXPR,O:AEXPR}
%          |  LABEL                                       => {VAR,LABEL}
%          | "star"                                       => {Star}
%          | "box"                                        => {Box}
%          | "(" EXPR ")"                                 =>

expr([],Acc)                                     -> {[],Acc};
expr([lambda,open,{name,Label},colon|T],Acc)     -> {T1,Acc1} = expr(T,Acc),
                                                    expr(T,[{domain,{Label,Acc1}}|Acc]);
expr([{name,L}|T],[{arrow},{Name,X}|Acc])        -> expr(T,[{arrow,{[{Name,X}],[{var,L}]}}|Acc]);
expr([{name,L}|T],[{Name,X}|Acc])                -> expr(T,[{app,{[{Name,X}],[{var,L}]}}|Acc]);
expr([{name,L}|T],Acc)                           -> expr(T,[{var,L}|Acc]);
expr(T,[{arrow},{Name,X}|Acc])                   -> expr(T,[{arrow,{[{Name,X}],element(2,expr(T,Acc))}}|Acc]);
expr([star|T],[{arrow},{Name,X}|Acc])            -> expr(T,[{arrow,{[{Name,X}],[{const,star}|Acc]}}|Acc]);
expr([star|T],Acc)                               -> expr(T,[{const,star}|Acc]);
expr([close,arrow|T],[{Name,X},{domain,{Label,A}}|Acc]) -> {T1,Acc1} = expr(T,Acc),
                                                    expr(T1,[{lambda,{Label,A,element(2,expr(T,Acc))}}]);
expr([close|T],Acc)                              -> expr([],Acc);
expr([open    |T],Acc)                           -> expr(T,Acc);
expr([arrow   |T],Acc)                           -> expr(T,[{arrow}|Acc]).

tail([]) -> [];
tail(Tl) -> tl(Tl).
head([]) -> [];
head(Tl) -> hd(Tl).
