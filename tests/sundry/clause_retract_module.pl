% clause/2,3, retract/1 and retractall/1 checked that M in M:Head existed
% and then worked on the calling module. A missing M now fails, or for
% retractall succeeds, as in SWI and Scryer.

:- initialization(main).

:- dynamic(d/1).
d(user_d).

setup :-
	retractall(crm:d(_)), retractall(crm:r(_)),
	assertz(crm:d(1)), assertz(crm:d(2)), assertz(crm:d(3)),
	assertz((crm:r(X) :- d(X))).

t_clause(R) :- setup, findall(X-B, clause(crm:d(X), B), R).
t_retract_all(R) :- setup, findall(X, retract(crm:d(X)), R0), findall(Y, crm:d(Y), Left), R = R0/Left.
t_retract_cut(R) :- setup, retract(crm:d(X)), X >= 2, !, findall(Y, crm:d(Y), Left), R = X/Left.
t_retractall(R) :- setup, retractall(crm:d(_)), findall(Y, crm:d(Y), R).
t_bound_module(R) :- setup, M = crm, findall(X, clause(M:d(X), true), R).
t_retract_rule(R) :- setup, retract((crm:r(X) :- B)), R = X-B.
t_clause_ref(R) :- setup, clause(crm:d(1), true, Ref), clause(H, B, Ref), R = H-B.
t_caller_module(R) :- setup, ( retract(crm:d(X)), X = 2, d(U) -> R = U ; R = none ).
t_missing(R) :- ( retract(nomod:d(_)) -> R = retracted ; clause(nomod:d(_), _) -> R = clause ; retractall(nomod:d(_)) -> R = ok ; R = failed ).

main :-
	forall(
		member(T, [t_clause, t_retract_all, t_retract_cut, t_retractall, t_bound_module, t_retract_rule, t_clause_ref, t_caller_module, t_missing]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
