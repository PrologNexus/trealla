% Issue #1165: listing a built-in throws a permission error without reading past its indicator.

:- initialization(main).

t(G) :- catch(G, E, true), writeq(E), nl.

main :-
	t(listing(atom_length/2)),
	t(listing(write/1)),
	t('$xlisting'(atom_length/2)),
	t('$dlisting'(atom_length/2)).
