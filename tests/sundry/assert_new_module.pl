% Asserting M:Clause for a module that didn't exist yet raised a
% permission_error on (:)/2. As in SWI and Scryer it now creates M.

:- initialization(main).

t_fact(R) :- assertz(anm1:p(1)), anm1:p(R).
t_rule(R) :- assertz(anm2:(p(X) :- X = 2)), anm2:p(R).
t_head(R) :- assertz((anm3:p(X) :- X = 3)), anm3:p(R).
t_asserta(R) :- asserta(anm4:p(4)), asserta(anm4:p(0)), findall(X, anm4:p(X), R).
t_exists(R) :- assertz(anm5:p(5)), ( current_module(anm5) -> R = yes ; R = no ).

main :-
	forall(
		member(T, [t_fact, t_rule, t_head, t_asserta, t_exists]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
