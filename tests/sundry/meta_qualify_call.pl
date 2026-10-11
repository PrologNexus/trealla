% A : meta argument is qualified even when it is call/N, once/1 or
% ignore/1, as in SWI, both compiled in a clause and at the call.

:- initialization(main).

:- meta_predicate w(:).
w(X) :- writeq(X), nl.

main :-
	w(call(a)), w(once(b)), w(ignore(c)), w(call(d, 1)), w(e),
	G = once(f), w(G).
