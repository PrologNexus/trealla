% Backtracking over bb_b_put/2 took the entry off the calling module's
% blackboard, but with the global blackboard it is stored in user, so
% from a module it was never undone. The undo also shared the entry's key,
% which a later bb_put/2 freed.

:- module(bb_b_put_undo, []).

:- initialization(main).

t_undone(R) :- ( bb_b_put(k, 1), fail ; true ), ( bb_get(k, X) -> R = leaked(X) ; R = undone ).
t_nested(R) :- bb_b_put(j, 1), ( bb_b_put(j, 2), fail ; true ), bb_get(j, R).
t_after_put(R) :- ( bb_b_put(u, 1), bb_put(u, 2), fail ; true ), bb_get(u, R).

main :-
	forall(
		member(T, [t_undone, t_nested, t_after_put]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
