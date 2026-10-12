% An atom that is an operator of any kind is bracketed as an operand,
% not only a prefix one: * = a reads only leniently, (*)=a as ISO says.
% And after a postfix operator a minus is infix: 1 ff - 1 is -(ff(1),1).

:- initialization(main).
:- op(200, xf, ff).

main :-
	forall(member(T, [(*)=a, a=(*), (*)=(*), (mod)=a, (is)=(is), (-)=(-), (',')=a, ('|')=a,
			-(*), -((*)=a), [(*)], f((*)), [(*)=(*)], a:(*), (a,(*)), ((*):-a), (\+)=a,
			- (-), - - a, (:-)=a, (*)+(*)*(*), user-(^)-sees]),
		(	writeq(T), nl,
			format(atom(A), "~q", [T]), read_term_from_atom(A, T2, []),
			( T2 == T -> true ; writeq(differs(T2)), nl )
		)),
	forall(member(T, [1 ff - 1, 1 ff-1, a ff-1, (1 ff) - -1, 1 - -1, a- -1, [-1], -(1), 1-1]),
		(write_canonical(T), nl)).
