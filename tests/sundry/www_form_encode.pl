% www_form_encode/2 as in SWI's library(url), also here in library(uri):
% only alphanumerics and -_.~ pass, the rest is lowercase %xx over UTF-8,
% and decoding reads '+' as a space and leaves a malformed escape alone.

:- use_module(library(url)).

:- initialization(main).

t(encode, E) :- www_form_encode('a b&c=é', E).
t(unreserved, E) :- www_form_encode('-_.~!*''()/', E).
t(decode, D) :- www_form_encode(D, 'a+b%26c%3D%C3%A9').
t(plus, D) :- www_form_encode(D, 'a+b%20c%2Bd').
t(malformed, D) :- www_form_encode(D, '%zz').
t(round_trip, ok) :- www_form_encode('x=1&y=ü', E), www_form_encode(D, E), D == 'x=1&y=ü'.
t(unbound, E) :- catch(www_form_encode(_, _), error(E, _), true).

main :-
	forall(t(Name, R), format("~w: ~q~n", [Name, R])).
