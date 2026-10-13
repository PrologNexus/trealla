% writeq/1 escapes neither ` nor " inside single quotes, writes +(1^2)
% as + 1^2 without brackets, writes '$VAR'(N) as a variable even when
% '$VAR' is an operator, and writes a list as [...] even when . is one.
% Each term is written and read back.

:- initialization(main).

w(T) :-
	with_output_to(atom(A), writeq(T)),
	read_term_from_atom(A, T2, []),
	write(A), write(' '), ( T2 =@= T -> write(same) ; write(differs) ), nl.

main :-
	forall(member(T, ['^`', 'a"b', 'a`b', 'it''s', +(1^2), +(a^b), +(a=b), -(1^2)]), w(T)),
	setup_call_cleanup(op(9, xf, '$VAR'),
		( forall(member(T, ['$VAR'(0), -('$VAR'(1)), '$VAR'(-1)]), (writeq(T), nl)) ),
		op(0, xf, '$VAR')),
	setup_call_cleanup(op(9, xfy, '.'),
		forall(member(T, [-[1], [1,2], -(1)]), (writeq(T), nl)),
		op(0, xfy, '.')).
