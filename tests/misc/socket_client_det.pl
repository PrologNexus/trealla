% socket_client_open/3 left a choicepoint on its Host:Port clause, so
% backtracking into it reached the bare-port clause and threw a
% type_error, which surfaced through http_open/3 too.

:- use_module(library(sockets)).

:- initialization(main).

server(Port) :-
	socket_server_open(Port, S, []),
	socket_server_accept(S, _, C, []),
	close(C),
	socket_server_close(S).

main :-
	Port = 39872,
	thread_create(server(Port), T, []),
	sleep(0.2),
	(	socket_client_open('127.0.0.1':Port, C, []),
		close(C),
		writeln(opened),
		fail
	;	writeln(no_more)
	),
	thread_join(T, _).
