% Issue #1163: an indexed key with a variable inside, as in f(_), is still found.

:- initialization(main).

:- dynamic(p/2).
:- dynamic(q/2).
:- dynamic(r/2).
:- dynamic(s/2).

fill(F) :- forall(between(1, 497, I), (fill(F, I, C), assertz(C))).

fill(p, I, p(I,n)).
fill(q, I, q(I,n)).
fill(r, I, r(n,I)).
fill(s, I, s(I,n)).

main :-
	fill(p),
	assertz(p(f(2), a)), assertz(p(f(_), b)), assertz(p(f(1), c)),
	findall(T, p(f(1), T), L1), writeq(L1), nl,
	findall(T, p(7, T), L2), writeq(L2), nl,
	retract(p(f(_), b)),
	findall(T, p(f(1), T), L3), writeq(L3), nl,
	fill(q),
	assertz(q([2], a)), assertz(q([_], b)), assertz(q([1], c)),
	findall(T, q([1], T), L4), writeq(L4), nl,
	fill(r),
	assertz(r(a, f(2))), assertz(r(b, f(_))), assertz(r(c, f(1))),
	findall(T, r(T, f(1)), L5), writeq(L5), nl,
	fill(s),
	assertz(s(f(2,x), a)), assertz(s(f(_,y), b)), assertz(s(f(1,_), c)), assertz(s(f(1,y), d)),
	findall(T, s(f(1,y), T), L6), writeq(L6), nl.
