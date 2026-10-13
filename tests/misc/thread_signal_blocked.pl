% thread_signal/2 and thread_cancel/1 reach a thread blocked in a read on
% a pipe or in accept, as in SWI: SIGUSR2 interrupts the read, the signal
% runs, and the goal carries on if it didn't throw, however many signals come.

:- use_module(library(sockets)).
:- initialization(main).

st(T, Name) :-
	( catch(thread_property(T, status(St)), _, fail) -> true ; St = gone ),
	format("~w: ~q~n", [Name, St]).

main :-
	popen('sleep 5', read, P1, []),
	thread_create(read(P1, _), T1, []),
	sleep(0.3), thread_signal(T1, throw(stop)), sleep(0.5), st(T1, pipe_read_thrown),
	popen('sleep 1; echo foo.', read, P2, []),
	thread_create((read(P2, X), format("read ~q~n", [X])), T2, []),
	sleep(0.3), thread_signal(T2, writeln(signal_ran)),
	sleep(0.3), thread_signal(T2, writeln(signal_ran_again)), thread_join(T2, S2), writeq(joined(S2)), nl,
	popen('sleep 5', read, P3, []),
	thread_create(read(P3, _), T3, [at_exit(writeln(at_exit_ran))]),
	sleep(0.3), thread_cancel(T3), sleep(0.5), st(T3, pipe_read_cancelled),
	socket_server_open(localhost:Port, L, []),
	thread_create((socket_server_accept(L, _, C, []), writeln(accepted), close(C)), T4, []),
	sleep(0.3), thread_signal(T4, writeln(signal_ran_in_accept)),
	sleep(0.3), socket_client_open(localhost:Port, CS, []), close(CS),
	thread_join(T4, S4), writeq(joined(S4)), nl,
	thread_create(socket_server_accept(L, _, _, []), T5, []),
	sleep(0.3), thread_signal(T5, throw(stop)), sleep(0.5), st(T5, accept_thrown),
	close(L).
