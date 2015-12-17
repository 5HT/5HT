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
tokens(<<$(,      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{t,[]},[{token,open}|stack(C,Acc)]);
tokens(<<$),      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{t,[]},[{token,close}|stack(C,Acc)]);
tokens(<<$:,      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},[{token,colon}|label(C,Acc)]);
tokens(<<$*,      R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},[{token,star}|stack(C,Acc)]);
tokens(<<"→"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},[{token,arrow}|stack(C,Acc)]);
tokens(<<"λ"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},[{token,lambda}|stack(C,Acc)]);
tokens(<<"∀"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R,L,{1,[]},[{token,pi}|stack(C,Acc)]);
tokens(<<X,       R/binary>>, L, {a,C}, Acc) when ?is_alpha(X) -> tokens(R,L,{a,[X|C]},Acc);
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_alpha(X) -> tokens(R,L,{a,[X]},  stack([C],Acc));
tokens(<<X,       R/binary>>, L, {t,C}, Acc) when ?is_termi(X) -> tokens(R,L,{t,[X|C]},Acc);
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_termi(X) -> tokens(R,L,{t,[X]},  stack(C,[Acc]));
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_space(X) -> tokens(R,L,{s,[C]},  Acc).

stack(C,Acc) -> case lists:flatten(C) of [] -> Acc; Re -> lists:flatten([{token,lists:reverse(Re)}|Acc]) end.
label(C,Acc) -> case lists:flatten(C) of [] -> Acc; Re -> lists:flatten([{token,{label,lists:reverse(Re)}}|Acc]) end.
read() -> {ok,Bin} = file:read_file("cat.txt"), io:format("~ts~n",[unicode:characters_to_list(Bin)]), tokens(Bin,0,{1,[]},[]).
main() -> parse(read(),[]).

parse([],Acc)                      -> {[],lists:reverse(Acc)};
parse([{token,open}|T],Acc)        -> parse_closure(T,Acc);
parse([{token,star}|T],Acc)        -> parse(T,[{const,star}|Acc]);
parse([{token,lambda}|T],Acc)      -> parse_arrow(T,Acc);
parse([{token,pi}|T],Acc)          -> parse_arrow(T,Acc);
parse([{token,arrow}|T],Acc)       -> parse(T,[{arrow,element(2,parse([],Acc)),element(2,parse(T,[]))}]);
parse([{token,close}|_]=All,Acc)   -> {All,Acc};
parse([{token,L}|T],[{var,X}|Acc]) -> parse(tail(T),[{apply,[{var,X}],element(2,parse(T,[{var,L}|Acc]))}]);
parse([{token,L}|T],Acc)           -> parse(T,[{var,L}|Acc]);
parse(T,Acc)                       -> {T,Acc}.

parse_closure(T,Acc) ->
    {[],In} = parse(T,Acc),
    parse([],[In|Acc]).

parse_arrow([{token,open},{token,{label,Label}},{token,colon}|T],Acc) ->
    {[{token,close},{token,arrow}|Out],In} = parse(T,Acc),
    {[],[{lambda,Label,In,element(2,parse(Out,Acc))}|Acc]}.

tail([]) -> [];
tail(Tl) -> tl(Tl).

head([]) -> [];
head(Tl) -> hd(Tl).
