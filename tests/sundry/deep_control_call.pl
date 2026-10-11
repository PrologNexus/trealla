% A control construct run as a body, by call/1, findall/3 and the like, is
% rebuilt walking its right-hand chain in a loop: recursing on it ran out
% of C stack on a long conjunction built at run time.

:- initialization(main).

conj(0, true) :- !.
conj(N, (true, G)) :- N1 is N-1, conj(N1, G).

main :-
	conj(200000, G),
	findall(x, G, L), writeq(L), nl,
	( call(G) -> writeln(call_ok) ; true ),
	( once(G) -> writeln(once_ok) ; true ),
	( \+ \+ G -> writeln(not_not_ok) ; true ),
	( (fail ; G) -> writeln(disj_ok) ; true ),
	H = (member(X, [1,2,3]), X > 1, !), findall(X, H, L2), writeq(L2), nl.
