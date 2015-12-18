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
tokens(<<$(,      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{t,[]},     [{token,open}   | stack(C,  Acc)]);
tokens(<<$),      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{t,[]},     [{token,close}  | stack(C,  Acc)]);
tokens(<<$:,      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [{token,colon}  | stack(C,  Acc)]);
tokens(<<$*,      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [{token,star}   | stack(C,  Acc)]);
tokens(<<"→"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [{token,arrow}  | stack(C,  Acc)]);
tokens(<<"λ"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [{token,lambda} | stack(C,  Acc)]);
tokens(<<"∀"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},     [{token,pi}     | stack(C,  Acc)]);
tokens(<<X,       R/binary>>, L, {a,C}, Acc) when ?is_alpha(X) -> tokens(R,L,{a,[X|C]},            Acc);
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_alpha(X) -> tokens(R,L,{a,[X]},    stack([C],Acc));
tokens(<<X,       R/binary>>, L, {t,C}, Acc) when ?is_termi(X) -> tokens(R,L,{t,[X|C]},            Acc);
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_termi(X) -> tokens(R,L,{t,[X]},    stack(C, [Acc]));
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_space(X) -> tokens(R,L,{s,[C]},              Acc).

stack(C,Acc) ->
   case lists:flatten(C) of
        [] -> Acc;
        "(" -> lists:flatten([{token,open}|Acc]);
        ")" -> lists:flatten([{token,close}|Acc]);
        [X|Aa] when ?is_alpha(X) -> lists:flatten([{token,{name,lists:reverse([X|Aa])}}|Acc]);
        Re -> lists:flatten([{token,list_to_atom(lists:reverse(Re))}|Acc]) end.

read() -> {ok,Bin} = file:read_file("cat2.txt"), io:format("~ts~n",[unicode:characters_to_list(Bin)]), tokens(Bin,0,{1,[]},[]).
          main() -> expr(read(),[]).

%
%    EXPR := BEXPR
%          | "lambda" "(" LABEL ":" EXPR ")" "arrow" EXPR => {LAM,[{NAME:LABEL,I:EXPR, O;EXPR]}
%          | "pi" "(" LABEL     ":" EXPR ")" "arrow" EXPR => {PI, [{NAME:LABEL,I:EXPR, O;EXPR]}
%          | BEXPR "arrow" EXPR                           => {PI, [{"_",       I:BEXPR,O;EXPR]}

expr([],Acc) -> {[],lists:reverse(Acc)};
expr([{token,lambda},{token,open},{token,{name,Label}},{token,colon}|T],Acc) ->
    {[{token,close},{token,arrow}|T1],Acc1} = expr(T,Acc),
    {T2,Acc2}=expr(T1,[]),
    {T2,[{lambda,{Label,Acc1,Acc2}}|Acc]};

expr([{token,pi},{token,open},{token,{name,Label}},{token,colon}|T],Acc) ->
    {[{token,close},{token,arrow}|T1],Acc1} = expr(T,Acc),
    {T2,Acc2}=expr(T1,[]),
    {T2,[{pi,{Label,Acc1,Acc2}}|Acc]};

expr(T,Acc) -> aexpr(T,Acc).

aexpr([],Acc) -> {[],lists:reverse(Acc)};
aexpr([{token,{name,L}}|T],[{Name,X}|Acc]) -> aexpr(T,[{app,{[{Name,X}],[{var,L}]}}|Acc]);
aexpr([{token,{name,L}}|T],Acc) -> aexpr(T,[{var,L}|Acc]);
aexpr([{token,star}    |T],Acc) -> {T,[{const,star}|Acc]};
aexpr([{token,box}     |T],Acc) -> {T,[{const,box} |Acc]};
aexpr([{token,close}   |T]=All,Acc) -> aexpr(T,Acc);
aexpr([{token,open}    |T],Acc) -> expr(T,Acc).

%   AEXPR := AEXPR AEXPR  => {APP,I:AEXPR,O:AEXPR}
%          | LABEL        => {VAR,LABEL}
%          | "star"       => {Star}
%          | "box"        => {Box}
%          | "(" EXPR ")" =>

tail([]) -> [];
tail(Tl) -> tl(Tl).

head([]) -> [];
head(Tl) -> hd(Tl).
