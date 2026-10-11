% in_temporary_module/3 runs Setup then Goal in a fresh module and destroys it
% after, even on an exception. A goal still holding a reference to a destroyed
% module's predicate gets an existence error, not freed memory (trealla-port FR-006).

:- initialization(main).

stale :-
	G = tm:p(_),
	in_temporary_module(tm, assertz(p(1)), G),
	catch(G, error(E, _), true),
	writeq(E), nl.

main :-
	in_temporary_module(M, assertz(p(1)), (p(X), writeq(X), nl)),
	( current_module(M) -> writeln(still) ; writeln(gone) ),
	stale,
	in_temporary_module(tm, (assertz(p(2)), op(700, xfx, ===>)), true),
	in_temporary_module(tm, assertz(p(3)), (findall(Y, p(Y), L), writeq(L), nl)),
	catch(read_term_from_atom('a ===> b', _, []), error(E1, _), true),
	writeq(E1), nl,
	catch(in_temporary_module(tm, true, throw(oops)), E2, true),
	writeq(E2), nl,
	( current_module(tm) -> writeln(still) ; writeln(gone) ),
	findall(Z, in_temporary_module(tm, true, member(Z, [a,b])), Zs),
	writeq(Zs), nl,
	forall(between(1, 200, I), in_temporary_module(_, assertz(q(I)), q(I))),
	assertz(tm2:r(1)), destroy_module(tm2),
	( current_module(tm2) -> writeln(still) ; writeln(gone) ),
	catch(destroy_module(user), error(E3, _), true), writeq(E3), nl,
	use_module(library(lists)),
	catch(destroy_module(lists), error(E4, _), true), writeq(E4), nl,
	destroy_module(no_such_module),
	writeln(done).
