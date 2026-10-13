% Concurrent sleeps each sleep to a deadline, so they don't lengthen one
% another, and a sleep signalled twice or more carries on to its end.

:- initialization(main).

main :-
	get_time(T0),
	findall(T, (member(G, [sleep(0.5), sleep(1.5), sleep(1.0), thread_sleep(0.5), thread_sleep(1.5), thread_sleep(1.0)]), thread_create(G, T, [])), Ts),
	forall(member(T, Ts), thread_join(T, _)),
	get_time(T1),
	E is T1 - T0,
	( E < 1.7 -> writeln(concurrent_ok) ; format("concurrent_slow(~3f)~n", [E]) ),
	thread_create((sleep(1.0) -> writeln(sleep_ok) ; writeln(sleep_failed)), T2, []),
	sleep(0.2), thread_signal(T2, writeln(s1)),
	sleep(0.2), thread_signal(T2, writeln(s2)),
	sleep(0.2), thread_signal(T2, writeln(s3)),
	thread_join(T2, S2), writeq(joined(S2)), nl,
	get_time(T3),
	thread_create(sleep(1.0), T4, []),
	sleep(0.6), thread_signal(T4, true),
	thread_join(T4, _),
	get_time(T5),
	E2 is T5 - T3,
	( E2 < 1.4 -> writeln(not_restarted) ; format("restarted(~3f)~n", [E2]) ),
	thread_self(Me),
	thread_create((sleep(0.2), thread_signal(Me, writeln(m1)), sleep(0.2), thread_signal(Me, writeln(m2))), _, [detached(true)]),
	( sleep(0.8) -> writeln(main_sleep_ok) ; writeln(main_sleep_failed) ).
