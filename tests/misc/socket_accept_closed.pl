% Closing a listener from another thread woke the thread blocked in
% socket_server_accept/4, which then just failed. It now raises an
% existence_error, and the closed listener refuses new clients.

:- use_module(library(sockets)).

:- initialization(main).

:- dynamic(held/2).

server :-
	socket_server_open('127.0.0.1':Port, S, []),
	assertz(held(Port, S)),
	catch(
		( socket_server_accept(S, _, C, []), close(C), writeln(accepted) ),
		error(E, _),
		( E = existence_error(stream, _) -> writeln(accept_saw_close) ; writeq(E), nl )
	).

main :-
	thread_create(server, T, []),
	sleep(0.2),
	held(Port, S),
	socket_server_close(S),
	thread_join(T, _),
	catch(
		( socket_client_open('127.0.0.1':Port, C, []), close(C), writeln(connected) ),
		error(socket_error(E, _), _),
		( writeq(refused(E)), nl )
	).
