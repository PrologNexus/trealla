% \e, \d and \s are escapes Trealla accepts by default, as SWI does, but
% they are not ISO, so with strict_iso on they are syntax errors.

:- initialization(main).

r(A) :-
	catch(( read_term_from_atom(A, T, []), atom_codes(T, Cs), write(Cs) ),
		error(syntax_error(_), _), write(syntax_error)),
	nl.

t :- forall(member(A, ['''\\e''', '''\\d''', '''\\s''', '''\\a''', '''\\x41\\''']), (write(A), write(' '), r(A))).

main :-
	t,
	set_prolog_flag(strict_iso, true),
	t,
	set_prolog_flag(strict_iso, false).
