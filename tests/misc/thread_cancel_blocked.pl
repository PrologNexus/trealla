% thread_cancel/1 reaches a thread blocked in accept, waiting in the slices
% reads use, rather than leaving it there till a client connects. Its
% at_exit goal still runs.

:- use_module(library(sockets)).
:- initialization(main).

main :-
	socket_server_open(localhost:0, S, []),
	thread_create(socket_server_accept(S, _, _, []), T, [at_exit((writeln(at_exit_ran)))]),
	sleep(0.3),
	thread_cancel(T),
	sleep(1),
	( catch(thread_property(T, status(St)), _, fail) -> writeq(status(St)) ; writeq(gone) ), nl,
	close(S).
