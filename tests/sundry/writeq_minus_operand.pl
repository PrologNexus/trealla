% writeq/1 brackets the operand of a prefix - that would be written
% starting with a number, since - 1~2 reads back as (-1)~2. Each term
% is written and read back.

:- initialization(main).
:- op(100, yfx, ~).
:- op(9, yf, yf).

main :-
	forall(member(T, [-(1~2~3), -(1~2), -(1.5~2), -(yf(1)), -(a~2), -(-1~2), -(1), -(-1), -(1^2), -(f(1))]),
		( writeq(T), write(' '),
		  with_output_to(atom(A), writeq(T)),
		  read_term_from_atom(A, T2, []),
		  ( T2 == T -> write(same) ; write(differs) ), nl )).
