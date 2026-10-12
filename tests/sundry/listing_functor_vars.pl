% Variables made by functor/3 have no name, so a clause asserted from them lists them as A, B or _ like any other.

:- initialization(main).

:- dynamic(d/2).

main :-
	functor(H, f, 2), assertz(d(H, t(H))), assertz(d(H, u)),
	functor(G, g, 1), assertz(d(G, v)),
	listing(d/2).
