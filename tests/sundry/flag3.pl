% flag/3 as in SWI: keys are atoms, integers or compounds by name/arity,
% New is an atom or evaluated, and Old failing to unify leaves it alone.

:- initialization(main).

t_count(R) :- flag(c, A, A+1), flag(c, B, B*2.5), flag(c, C, foo), flag(c, D, D), R = [A,B,C,D].
t_compound(R) :- flag(f(y), _, 1), flag(f(z), R, R).
t_int_key(R) :- flag(9, N, N+1), flag(9, R, R), N == 0.
t_no_update(R) :- ( flag(k, 1, 5) -> R = updated ; flag(k, R, R) ).
t_eval_error(R) :- catch(flag(e, _, 1/0), error(E, _), true), flag(e, V, V), R = E-V.
t_big(R) :- catch(flag(b, _, 2^100), error(R, _), true).

main :-
	forall(
		member(T, [t_count, t_compound, t_int_key, t_no_update, t_eval_error, t_big]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
