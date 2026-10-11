% Issue #1166: clause/3 with a bound reference fails, rather than looping, when the body does not unify.

:- initialization(main).

:- dynamic(d/1).

d(1).
d(2) :- true, true.

main :-
	clause(d(1), _, R), ( clause(_, fail, R) -> writeq(yes) ; writeq(no) ), nl,
	( clause(_, true, R) -> writeq(yes) ; writeq(no) ), nl,
	( clause(d(2), _, R) -> writeq(yes) ; writeq(no) ), nl,
	clause(d(2), _, R2), findall(B, clause(_, B, R2), Bs), writeq(Bs), nl,
	( clause(d(2), true, R2) -> writeq(yes) ; writeq(no) ), nl.
