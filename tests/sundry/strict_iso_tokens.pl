% A back quoted string and 0'' before anything but a quote are extensions
% Trealla reads by default, so with strict_iso on they are syntax errors.
% A - before a numeral negates it in both modes, even once - is no longer
% a prefix operator.

:- initialization(main).

r(A) :-
	catch(( read_term_from_atom(A, T, []), \+ \+ ( numbervars(T, 0, _), write_term(T, [quoted(true), numbervars(true), ignore_ops(true)]) ) ),
		error(syntax_error(_), _), write(syntax_error)),
	nl.

t :-
	forall(member(A, ['X = `a`', 'integer(0'''')', 'integer(0'''''')']), ( write(A), write(' '), r(A) )),
	setup_call_cleanup(op(0, fy, -),
		forall(member(A, ['X = - 1', 'X = [-1, - 2.5]', 'X = 3 - -1', 'X = - a']), ( write(A), write(' '), r(A) )),
		op(200, fy, -)).

main :-
	t,
	set_prolog_flag(strict_iso, true),
	t,
	set_prolog_flag(strict_iso, false).
