% in_temporary_module/3 runs Setup then Goal in a fresh module and destroys it
% after, even on an exception. A goal still holding a reference to a destroyed
% module's predicate gets an existence error, not freed memory (trealla-port FR-006).

:- initialization(main).

stale :-
	G = tm:p(_),
	in_temporary_module(tm, assertz(p(1)), G),
	catch(G, error(E, _), true),
	writeq(E), nl.

% Names tm5 directly, so its call caches tm5's p/1, which a later module
% reusing tm5's struct revives: that one mustn't be what this calls.

named :- tm5:p(X), writeq(named(X)), nl.

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
	% one already in use, if only by a declaration, isn't taken and destroyed
	'$create_module'(tmapp), load_text(":- dynamic(store/1).", [module(tmapp)]),
	catch(in_temporary_module(tmapp, true, true), error(E5, _), true), writeq(E5), nl,
	( predicate_property(tmapp:store(_), dynamic) -> writeln(tmapp_kept) ; writeln(tmapp_lost) ),
	% destroyed modules are reused, as many times as asked
	forall(between(1, 3000, I), in_temporary_module(_, assertz(r(I)), r(I))),
	in_temporary_module(tm5, assertz(p(old)), named),
	in_temporary_module(tm6, assertz(p(new)), (catch(named, error(E6, _), true), writeq(E6), nl, tm6:p(Y6), writeq(tm6(Y6)), nl)),
	writeln(done).
