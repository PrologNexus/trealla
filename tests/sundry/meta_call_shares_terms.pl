% call/1, once/1, ignore/1 and findall/3 ran a copy of a control-construct
% goal, so nb_setarg/3 on a term a variable in it was bound to changed the
% copy: the caller never saw it, and a loop re-reading it never advanced.
% findnsols/4 renames its goal between chunks, but now shares a ground term
% a variable is bound to, while unbound variables still don't leak across.
% Nor may a control construct reached through a variable hide a cut: a
% body built as data still cuts, as Logtalk's phrase/3 relies on.

:- initialization(main).

bump(C) :- arg(1, C, N0), N is N0+1, nb_setarg(1, C, N).

t_call(R) :- copy_term(c(0), C), call((member(_, [1,2,3]), arg(1, C, N0), N is N0+1, nb_setarg(1, C, N), N >= 2)), R = C.
t_once(R) :- copy_term(c(0), C), once((member(_, [1,2,3]), arg(1, C, N0), N is N0+1, nb_setarg(1, C, N), N >= 2)), R = C.
t_ignore(R) :- copy_term(c(0), R), ignore((member(_, [1,2,3]), bump(R), fail)).
t_findall(R) :- copy_term(c(0), R), findall(x, (member(_, [1,2,3]), bump(R)), _).
t_findnsols(R) :- copy_term(c(0), C), findall(C2/L, (findnsols(2, x, (member(_, [1,2,3,4,5]), bump(C)), L), copy_term(C, C2)), R).
t_chunks_hide(R) :- T = t(_), findall(S/L, (findnsols(1, Y, (member(Y, [1,2]), arg(1, T, Y)), L), arg(1, T, A), ( var(A) -> S = unbound ; S = A )), R).
% Built by unifying clause heads, as Logtalk compiles a body: data, so its
% (A;B) and (A,B) carry no builtin, and A and B are variables bound later.
comp((A;B), (TA;TB)) :- !, comp(A, TA), comp(B, TB).
comp((A,B), (TA,TB)) :- !, comp(A, TA), comp(B, TB).
comp(G, G).
t_cut_via_var(R) :-
	comp((((!, fail), X = Y) ; (true, X = Y)), T),
	( call(T) -> A = lost ; A = kept ),
	( once(T) -> B = lost ; B = kept ),
	( T -> C = lost ; C = kept ),
	( \+ \+ T -> D = lost ; D = kept ),
	( findall(x, T, [_|_]) -> E = lost ; E = kept ),
	R = [call-A, once-B, var-C, not-D, findall-E].
t_page(R) :- C = count(2), findall(L, (findnsols(C, X, member(X, [a,b,c,d,e,f,g]), L), nb_setarg(1, C, 3)), R).

main :-
	forall(
		member(T, [t_call, t_once, t_ignore, t_findall, t_findnsols, t_chunks_hide, t_cut_via_var, t_page]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
