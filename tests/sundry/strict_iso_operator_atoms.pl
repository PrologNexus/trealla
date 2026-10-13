% An operator taken as an atom, quoted or not, must stand alone, as an
% argument or between brackets: with strict_iso on, * = * and X = '*' are
% syntax errors, as in Scryer, while f(*), [:-,-] and (*)=(*) still read.
% Default mode is unchanged.

:- initialization(main).

r(A, R) :-
	catch(( read_term_from_atom(A, _, []), R = ok ), error(syntax_error(_), _), R = syntax_error).

t :-
	forall(member(A, ['f(*)', '[:-,-]', '(*)=(*)', '(a,(*))', '- (-)', 'X = (+)', 'maplist(=(1),[1])', '[-]',
			'f(''*'')', '[a|''*'']', 'X = (''*'')', '''*''(1,2)',
			'- = - 1', '(-;)', '(a, *)', 'f(* = a)', '* :- a', 'a = mod',
			'X = ''*''', 'X = '',''', '''*'' = a', '(a, ''*'')']),
		( r(A, R), write(A), write(' '), write(R), nl )).

main :-
	t,
	set_prolog_flag(strict_iso, true),
	t,
	set_prolog_flag(strict_iso, false).
