% A symbolic functor in functional notation after an infix operator gets a
% space, as a:>>(b,c,d) would read back as a :>> ..., which also broke
% throwing such a term. A meta argument whose module is a bound variable
% isn't qualified again.

:- initialization(main).

:- meta_predicate w(:).
w(X) :- writeq(X), nl.

main :-
	forall(member(T, [a:'>>'(b,c,d), a='>>'(b,c,d), a:'>>'(b), a='\\+'(b,c), a:[1,2], a:{x}, a=f(x), a:'.'(b), a:(b:c)]),
		(	writeq(T), nl,
			format(atom(A), "~q", [T]), read_term_from_atom(A, T2, []),
			( T2 == T -> true ; writeq(differs(T2)), nl )
		)),
	catch(throw(error(x, user:'>>'(a,b,c))), C, (writeq(C), nl)),
	M = m1, w(M:foo), w(bar).
