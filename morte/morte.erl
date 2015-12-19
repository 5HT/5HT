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

read() -> Bin = file(),
          io:format("~ts~n",[unicode:characters_to_list(Bin)]), tokens(Bin,0,{1,[]},[]).
          main() -> expr(read(),[]).


file() ->  {ok,Bin2} = file:read_file("morte.txt"),
          %<<"( ( a → (b x) → x) → ( c → d ) ) ( a b ) a b"/utf8>>.
          %<<"(c → (a → c) → v)"/utf8>>.
          %<<"(λ (a: c → (a (x a)) → v) → λ (a:*) → *)"/utf8>>.
          Bin2.

%    EXPR := EXPR EXPR                                    => {APP,[           I:EXPR, O:EXPR]}
%          | "lambda" "(" LABEL ":" EXPR ")" "arrow" EXPR => {LAM,[{ARG:LABEL,I:EXPR, O;EXPR]}
%          | "pi"     "(" LABEL ":" EXPR ")" "arrow" EXPR => {PI, [{ATH:LABEL,I:EXPR, O;EXPR]}
%          |                        EXPR     "arrow" EXPR => {PI, [{"_",      I:EXPR, O;EXPR]}
%          |  LABEL                                       => {VAR,LABEL}
%          | "star"                                       => {Star}
%          | "box"                                        => {Box}
%          | "(" EXPR ")"                                 => EXPR

expr([],           Acc) -> {[],Acc};
expr([close   |T], Acc) -> {T1,Acc1}=rewind(Acc,T,[]), expr(T1,Acc1);
expr([star    |T], Acc) -> expr(T,[{const,star}|Acc]);
expr([open    |T], Acc) -> expr(T,[{open}|Acc]);
expr([arrow   |T], Acc) -> expr(T,[{arrow}|Acc]);
expr([lambda  |T], Acc) -> expr(T,[{lambda}|Acc]);
expr([pi  |T], Acc)     -> expr(T,[{lambda}|Acc]);
expr([{name,L},colon|T],Acc) -> expr(T,[{typevar,L}|Acc]);
expr([{name,L}|T],      Acc) -> expr(T,[{var,L}|Acc]).

rewind([{open}       |Acc],T, Rest) -> {T,lists:flatten([Rest|Acc])};
rewind([{N,X}        |Acc],T, [{C,Y}|Rest]) when N/=arrow2 -> rewind(Acc,T,[{app,{{N,X},{C,Y}}}|Rest]);
rewind([{arrow},{C,Y}|Acc],T, [{N,X}|Rest]) -> rewind(Acc,T,[{arrow,{{C,Y},{N,X}}}|Rest]);
rewind([{lambda}|Acc],T, [{arrow,{{app,{{typevar,Label},X}},Y}}|Rest]) -> rewind(Acc,T,[{lambda,{{arg,Label},X,Y}}|Rest]);
rewind([{N,X}        |Acc],T, Rest) -> rewind(Acc,T,[{N,X}|Rest]).


