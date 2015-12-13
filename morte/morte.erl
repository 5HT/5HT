-module(morte).
-compile(export_all).

-define(is_digit(C), C >= $0, C =< $9).
-define(is_space(C), C =:= $\r; C =:= $\s; C =:= $\t).
-define(is_upper(C), C >= $A, C =< $Z).
-define(is_lower(C), C >= $a, C =< $z).
-define(is_alpha(C), ?is_upper(C); ?is_lower(C)).
-define(is_termi(C), C =:= $!; C =:= $#; C =:= $$; C =:= $%; C =:= $&; C =:= $(; C =:= $:;
                     C =:= $+; C =:= $-; C =:= $*; C =:= $/; C =:= $.; C =:= $\\;C =:= $);
                     C =:= $<; C =:= $>; C =:= $=; C =:= $|; C =:= $^; C =:= $~; C =:= $@).

stack({T,C},Acc) -> case lists:flatten(C) of [] -> Acc; Re -> lists:flatten([{token,lists:reverse(Re)}|Acc]) end.

tokens(<<>>,                  _, {_,_}, Acc) -> lists:reverse(Acc);
tokens(<<$\n,     R/binary>>, L, {_,_}, Acc) -> tokens(R, L+1, {1,[]},     Acc);
tokens(<<$(,      R/binary>>, L, {t,C}, Acc) -> tokens(R, L,   {t,[$(]},   Acc);
tokens(<<$(,      R/binary>>, L, {_,C}, Acc) -> tokens(R, L,   {t,[]},     [{token,"("}|stack({t,C},Acc)]);
tokens(<<$*,      R/binary>>, L, {_,C}, Acc) -> tokens(R, L,   {1,[]},     stack({1,[$*]},stack({1,C},Acc)));
tokens(<<$),      R/binary>>, L, {t,C}, Acc) -> tokens(R, L,   {t,[$)|C]}, Acc);
tokens(<<$),      R/binary>>, L, {_,C}, Acc) -> tokens(R, L,   {t,[]},     stack({1,[$)]},stack({1,C},Acc)));
tokens(<<$:,      R/binary>>, L, {_,C}, Acc) -> tokens(R, L,   {1,[]},     stack({1,[$:]},stack({1,C},Acc)));
tokens(<<"→"/utf8,R/binary>>, L, {_,C},Acc)  -> tokens(R, L,   {1,[]},     [{token,arrow}|stack({t,C},Acc)]);
tokens(<<"λ"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R, L,   {1,[]},     [{token,lambda}|stack({t,C},Acc)]);
tokens(<<"∀"/utf8,R/binary>>, L, {_,C}, Acc) -> tokens(R, L,   {1,[]},     [{token,pi}|stack({t,C},Acc)]);
tokens(<<X,       R/binary>>, L, {a,C}, Acc) when ?is_alpha(X) -> tokens(R,L,{a,[X|C]},Acc);
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_alpha(X) -> tokens(R,L,{a,[X]},stack({a,[C]},Acc));
tokens(<<X,       R/binary>>, L, {t,C}, Acc) when ?is_termi(X) -> tokens(R,L,{t,[X|C]},Acc);
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_termi(X) -> tokens(R,L,{t,[X]},stack({t,C},[Acc]));
tokens(<<X,       R/binary>>, L, {_,C}, Acc) when ?is_space(X) -> tokens(R,L,{s,[C]},Acc).

read() -> {ok,Bin} = file:read_file("morte.txt"), tokens(Bin,0,{1,[]},[]).
