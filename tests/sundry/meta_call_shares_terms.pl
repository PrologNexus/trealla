% call/1, once/1, ignore/1 and findall/3 ran a copy of a control-construct
% goal, so nb_setarg/3 on a term a variable in it was bound to changed the
% copy: the caller never saw it, and a loop re-reading it never advanced.

:- initialization(main).

bump(C) :- arg(1, C, N0), N is N0+1, nb_setarg(1, C, N).

t_call(R) :- copy_term(c(0), C), call((member(_, [1,2,3]), arg(1, C, N0), N is N0+1, nb_setarg(1, C, N), N >= 2)), R = C.
t_once(R) :- copy_term(c(0), C), once((member(_, [1,2,3]), arg(1, C, N0), N is N0+1, nb_setarg(1, C, N), N >= 2)), R = C.
t_ignore(R) :- copy_term(c(0), R), ignore((member(_, [1,2,3]), bump(R), fail)).
t_findall(R) :- copy_term(c(0), R), findall(x, (member(_, [1,2,3]), bump(R)), _).
t_page(R) :- C = count(2), findall(L, (findnsols(C, X, member(X, [a,b,c,d,e,f,g]), L), nb_setarg(1, C, 3)), R).

main :-
	forall(
		member(T, [t_call, t_once, t_ignore, t_findall, t_page]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
