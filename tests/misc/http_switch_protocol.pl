% http_switch_protocol/2, as in SWI: the server replies 101 Switching
% Protocols with the given headers, no Content-Length or Connection: close,
% and hands the connection to the goal, which may keep it or pass it to a
% thread. A goal that fails has the connection closed for it.

:- use_module(library(http/http_server)).
:- use_module(library(sockets)).

:- initialization(main).

handler(Request) :-
	memberchk(path(Path), Request),
	(	Path == "/echo" ->
		http_switch_protocol(echo_once, [headers([upgrade(echo), connection('Upgrade')])])
	;	Path == "/thread" ->
		http_switch_protocol(echo_in_thread, [])
	;	Path == "/fail" ->
		http_switch_protocol(give_up, [])
	;	format("Content-Type: text/plain~n~nplain~n")
	).

echo_once(In, Out) :-
	read_term(In, T, []),
	write_term(Out, echoed(T), [fullstop(true), nl(true)]),
	flush_output(Out),
	close(In).

echo_in_thread(In, Out) :-
	thread_create(echo_once(In, Out), _, [detached(true)]).

give_up(_, _) :- fail.

request(Port, Path, Lines, Reply) :-
	socket_client_open('127.0.0.1':Port, C, []),
	format(C, "GET ~w HTTP/1.1\r\nHost: localhost\r\n\r\n", [Path]),
	flush_output(C),
	head_lines(C, Lines),
	(	Lines = ['HTTP/1.1 101 Switching Protocols'|_] ->
		write_term(C, hello, [fullstop(true), nl(true)]),
		flush_output(C),
		( catch(read_term(C, Reply, []), _, fail) -> true ; Reply = closed )
	;	Reply = none
	),
	close(C).

head_lines(C, Lines) :-
	read_line_to_string(C, L0),
	(	L0 == end_of_file -> Lines = []
	;	L0 == '' -> Lines = []
	;	( append(L, ['\r'], L0) -> true ; L = L0 ),
		(	L == [] -> Lines = []
		;	atom_chars(A, L), Lines = [A|Ls], head_lines(C, Ls)
		)
	).

main :-
	Port = 39883,
	thread_create(http_server(handler, [port(Port)]), _, [detached(true)]),
	sleep(0.3),
	request(Port, '/echo', L1, R1), writeq(echo(L1, R1)), nl,
	request(Port, '/thread', L2, R2), writeq(thread(L2, R2)), nl,
	request(Port, '/fail', L3, R3), writeq(fail(L3, R3)), nl,
	request(Port, '/plain', L4, _), ( L4 = ['HTTP/1.1 200 OK'|_] -> writeln(plain_still_served) ; writeq(L4), nl ),
	http_stop_server(Port, []).
