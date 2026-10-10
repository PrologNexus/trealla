% SWI's b_setval/2, nb_setval/2, b_getval/2 and nb_getval/2. They are each
% thread's own, unlike the blackboard, and b_setval/2 is undone on
% backtracking, back to the value it shadowed.

:- use_module(library(freeze)).

:- initialization(main).

t_undo(R) :- nb_setval(k, 1), ( b_setval(k, 2), fail ; true ), b_getval(k, R).
t_nested(R) :- nb_setval(k, 1), ( b_setval(k, 2), b_setval(k, 3), nb_getval(k, 3), fail ; true ), nb_getval(k, R).
t_nb_over_b(R) :- nb_setval(k, 1), ( b_setval(k, 2), nb_setval(k, 3), fail ; true ), nb_getval(k, R).
t_nb_copies(R) :- nb_setval(k, f(X)), X = 1, nb_getval(k, f(Y)), ( var(Y) -> R = copied ; R = shared ).
t_b_shares(R) :- b_setval(k, f(X)), X = 1, b_getval(k, R).
t_missing(R) :- catch(nb_getval(nokey, _), error(R, _), true).
t_key(R) :- catch(nb_setval(f(x), 1), error(R, _), true).
t_thread(R) :-
	nb_setval(k, main),
	thread_create(( catch(nb_getval(k, V), error(E, _), V = E), nb_setval(k, other), nb_setval(seen, V) ), T, []),
	thread_join(T, _),
	nb_getval(k, W),
	R = W.
t_attr(R) :- freeze(X, true), nb_setval(k, g(X)), nb_getval(k, g(Y)), ( frozen(Y, G), G \== true -> R = still_frozen ; R = lost ).

main :-
	forall(
		member(T, [t_undo, t_nested, t_nb_over_b, t_nb_copies, t_b_shares, t_missing, t_key, t_thread, t_attr]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
