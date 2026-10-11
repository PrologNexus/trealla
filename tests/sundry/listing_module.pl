% listing(M:PI) found module M and then listed the calling module's
% predicate of that name instead.

:- initialization(main).

lm_probe(user_version).

main :-
	assertz(lists:lm_probe(1)),
	assertz((lists:lm_probe(2) :- true)),
	writeln('% lists:lm_probe/1'), listing(lists:lm_probe/1),
	writeln('% lists:lm_probe'), listing(lists:lm_probe),
	writeln('% lm_probe/1'), listing(lm_probe/1),
	( catch(listing(nomod:lm_probe/1), error(E, _), true) -> writeq(E), nl ; writeln(failed) ).
