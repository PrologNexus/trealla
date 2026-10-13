% An atom with a NUL in it keeps its whole text when consulted, as it
% does when read by read/1; it used to be cut at the NUL.

:- initialization(main).

t('\x0\').
t('a\x0\b').
t('\0\').
t('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\x0\b').
t(f('\x0\', x)).
t('').

main :-
	forall(t(X), ( writeq(X), ( atom(X) -> atom_length(X, L), write(' '), write(L) ; true ), nl )),
	char_code(C, 0),
	( t(C) -> write(found) ; write(not_found) ), nl.
