% A module qualifier that isn't an atom is a type error, as in SWI, not a
% lookup of whatever text it happens to have. And predicate_property/2
% asked in a module sees from there, system predicates' meta specs included.

:- initialization(main).

e(G) :- catch(G, error(E, _), true), ( var(E) -> writeq(ok(G)) ; writeq(E) ), nl.

main :-
	e(clause(42:foo, _)),
	e(retract(42:foo)),
	e(retract((f(x):foo :- true))),
	e(retractall(42:foo)),
	e(assertz(42:foo)),
	e(asserta((f(x):foo :- true))),
	e(listing(42:foo/1)),
	e(clause(_:foo, _)),
	load_text(":- module(ppm, [t/2]). t(G, S) :- predicate_property(G, meta_predicate(S)).", []),
	( ppm:t(findall(_,_,_), S) -> writeq(S) ; writeq(none) ), nl,
	( predicate_property(lists:assertz(_), meta_predicate(S2)) -> writeq(S2) ; writeq(none) ), nl.
