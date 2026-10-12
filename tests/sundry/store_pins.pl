% A term kept past the call, as an attribute value or a blackboard entry, names variables by frame index. A frame it
% names was recovered all the same, and the next call to take the index showed through: f(1,2) for f(x1,y1).

:- initialization(main).
:- use_module(library(atts)).
:- attribute(tag/1).

q(A, B, C) :- A = 1, B = 2, C = 3.

% The builtin under bb_b_put/2, whose own frame would otherwise shield p's.

bb_p :- '$bb_b_put'(k, '$bb'(f(X, Y))), X = x1, Y = y1.
bb_p2 :- '$bb_b_put'(k2, '$bb'(f(_, _))).

bb1 :- bb_p, q(_, _, _), '$bb_get'(k, '$bb'(T)), write(T), nl.
bb2 :- bb_p2, q(_, _, _), '$bb_get'(k2, '$bb'(T)), ( ground(T) -> write(bound(T)) ; write(unbound) ), nl.
bb3 :- bb_p2, q(_, _, _), ( '$bb_get'(k2, '$bb'(f(A, _))), A = z, '$bb_get'(k2, '$bb'(f(Z, _))) -> write(Z) ; write(failed) ), nl.

% at_p gets the older variable through arg/3, not its head, so the var-var head rule never saw it.

at_p(T) :- arg(1, T, X), put_atts(X, tag(g(Y))), Y = hello.
at_p0(T) :- at_p(T).
at1 :- T = f(_), at_p0(T), q(_, _, _), arg(1, T, V), get_atts(V, tag(G)), write(G), nl.

main :-
	bb1, bb2, bb3, at1.
