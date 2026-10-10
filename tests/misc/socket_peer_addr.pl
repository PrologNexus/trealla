% A wildcard listener may be a dual-stack IPv6 socket. Its IPv4 peers
% were decoded as IPv4 from the wrong struct and all came out 0.0.0.0.

:- use_module(library(sockets)).

:- initialization(main).

server(Port) :-
	socket_server_open(Port, S, []),
	socket_server_accept(S, Peer, C, []),
	Peer = Host:_,
	writeq(peer(Host)), nl,
	close(C),
	socket_server_close(S).

main :-
	Port = 39871,
	thread_create(server(Port), T, []),
	sleep(0.2),
	socket_client_open('127.0.0.1':Port, C, []),
	close(C),
	thread_join(T, _).
