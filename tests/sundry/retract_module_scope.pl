% retract/1 and retractall/1 of M:Head change only M, as in SWI and
% Scryer, never a predicate M would inherit from user, while clause/2
% reads through to user as SWI does.

:- initialization(main).

main :-
	assertz(foo(1)), assertz(rms:bar),
	( clause(rms:foo(X), B) -> writeq(clause(X, B)) ; writeq(clause_none) ), nl,
	( retract(rms:foo(1)) -> writeln(retracted) ; writeln(not_retracted) ),
	retractall(rms:foo(_)),
	( foo(1) -> writeln(user_foo_kept) ; writeln(user_foo_gone) ),
	assertz(rms:baz(1)), retract(rms:baz(1)),
	( rms:baz(_) -> writeln(rms_baz_left) ; writeln(rms_baz_retracted) ),
	retract(user:foo(1)),
	( foo(_) -> writeln(user_retract_failed) ; writeln(user_retract_ok) ).
