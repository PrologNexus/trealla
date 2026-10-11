% A clause asserted into a module that calls a meta-predicate it can only
% reach through user's imports passed its goal without the module, so the
% goal was looked up in user. 0 and ^ goals now carry the caller's module.

:- use_module(library(aggregate)).

:- initialization(main).

setup :-
	assertz(mgm:loc(1)), assertz(mgm:loc(2)),
	assertz(mgm:(count_all(N) :- aggregate_all(count, loc(_), N))),
	assertz(mgm:(count_caret(N) :- aggregate(count, X^loc(X), N))),
	assertz(mgm:(bag(L) :- bagof(X, loc(X), L))),
	assertz(mgm:(chain :- forall(loc(X), integer(X)))).

t_zero(R) :- mgm:count_all(R).
t_caret(R) :- mgm:count_caret(R).
t_bagof(R) :- mgm:bag(R).
t_forall(R) :- ( mgm:chain -> R = ok ; R = failed ).
t_user(R) :- aggregate_all(count, member(_, [a,b,c]), R).

main :-
	setup,
	forall(
		member(T, [t_zero, t_caret, t_bagof, t_forall, t_user]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
