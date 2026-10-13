% thread_get_message/3 takes SWI's deadline(T), on get_time/1's clock; with a timeout too, the earlier wins.

:- initialization(main).

main :-
	thread_self(Me),
	get_time(T0),
	( thread_get_message(Me, _, [deadline(T0)]) -> writeln(got) ; writeln(expired) ),
	get_time(T1), D1 is T1 + 0.3,
	( thread_get_message(Me, _, [deadline(D1)]) -> writeln(got) ; writeln(timed_out) ),
	get_time(T2), E1 is T2 - T1,
	( E1 >= 0.25, E1 < 1.0 -> writeln(waited_until_deadline) ; format("waited(~3f)~n", [E1]) ),
	D2 is T2 + 5,
	( thread_get_message(Me, _, [deadline(D2), timeout(0.2)]) -> true ; true ),
	get_time(T3), E2 is T3 - T2,
	( E2 < 1.0 -> writeln(timeout_earlier) ; writeln(timeout_ignored) ),
	D3 is T3 + 0.2,
	( thread_get_message(Me, _, [timeout(5), deadline(D3)]) -> true ; true ),
	get_time(T4), E3 is T4 - T3,
	( E3 < 1.0 -> writeln(deadline_earlier) ; writeln(deadline_ignored) ),
	thread_send_message(Me, other), thread_send_message(Me, wanted),
	D4 is T4 + 1,
	thread_get_message(Me, wanted, [deadline(D4)]), writeln(selected),
	catch(thread_get_message(Me, _, [deadline(foo)]), error(E, _), (writeq(E), nl)).
