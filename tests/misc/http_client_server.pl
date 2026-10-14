% library(http/...) client against its own server, and against a raw
% socket server for the replies the server never sends: chunked, and a
% body that runs to end of file.

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_open)).
:- use_module(library(socket)).
:- use_module(library(iso_ext)).
:- initialization(main).

:- http_handler(root(hello), hello, [methods([get])]).
:- http_handler(root(echo), echo, [method(post)]).
:- http_handler('/api/', api, [prefix]).
:- http_handler(root(go), go, []).
:- http_handler(root(auth), auth, []).
:- http_handler(root(goauth), goauth, []).
:- http_handler(root(cross), cross, []).
:- http_handler(root(teapot), teapot, []).
:- http_handler(root(stop), stop, []).

hello(R) :-
	(memberchk(search(Q), R), memberchk(name=N, Q) -> true ; N = "world"),
	format("Content-type: text/plain~n~nhello ~s~n", [N]).
echo(R) :-
	http_read_data(R, Data, []),
	format("Content-type: text/plain~n~n~q~n", [Data]).
api(R) :- memberchk(path(P), R), format("Content-type: text/plain~n~n~s~n", [P]).
go(R) :- http_redirect(see_other, root(hello), R).
auth(R) :-
	(memberchk(authorization(A), R) -> true ; A = none),
	(memberchk(cookie(C), R) -> true ; C = none),
	format("Content-type: text/plain~n~n~s ~s~n", [A, C]).
goauth(R) :- http_redirect(see_other, root(auth), R).
cross(R) :- http_redirect(see_other, 'http://127.0.0.1:3428/', R).
teapot(_) :- format("Status: 418 I'm a teapot~n~nshort~n").
stop(_) :- http_stop_server(3427, []), format("~nbye~n").

run_server :-
	http_server(http_dispatch, [port(3427)]).

raw(Reply) :-
	raw(Reply, _).

raw(Reply, Head) :-
	tcp_socket(Srv), tcp_bind(Srv, '127.0.0.1':3428), tcp_listen(Srv, 5),
	tcp_accept(Srv, Cl, _),
	tcp_open_socket(Cl, S),
	drain(S, Head),
	format(S, "~s", [Reply]),
	close(S),
	tcp_close_socket(Srv).

drain(S, Head) :-
	getline(S, Line),
	(	(Line == '' ; Line == "\r" ; Line == []) -> Head = []
	;	Head = [Line|Head1], drain(S, Head1)
	).

% The names of the header fields the raw server was sent...

cross_headers(URL, Options, Hs) :-
	thread_create((raw("HTTP/1.0 200 OK\r\n\r\nok", Head), thread_exit(Head)), T, []),
	sleep(0.1),
	http_get(URL, _, Options),
	thread_join(T, exited(Head)),
	findall(H, (member(L, Head), once(append(Name, [':'|_], L)), atom_chars(H, Name)), Hs).

raw_get(Reply, Data) :-
	thread_create(raw(Reply), T, []),
	sleep(0.1),
	http_get('http://127.0.0.1:3428/', Data, []),
	thread_join(T).

url(Path, URL) :- atom_concat('http://127.0.0.1:3427', Path, URL).

check(Name, Goal) :-
	(	\+ \+ catch(call_with_time_limit(10, Goal), E, (format("~w: ~q~n", [Name, E]), fail)) ->
		true
	;	format("~w: failed~n", [Name])
	).

main :-
	thread_create(run_server, T, []),
	sleep(0.2),
	check(get, (url('/hello?name=Zo%C3%AB', U), http_get(U, D, []), atom_chars(A, D), atom_codes(A, Cs), writeq(Cs), nl)),
	check(prefix, (url('/api/a/b', U), http_get(U, D, [to(atom)]), writeq(D), nl)),
	check(form, (url('/echo', U), http_post(U, form([a="1 2", b=x]), D, [to(atom)]), writeq(D), nl)),
	check(redirect, (url('/go', U), http_get(U, D, [final_url(F), to(atom)]), atom_chars(FA, F), writeq(D-FA), nl)),
	check(same_origin_auth, (url('/goauth', U), atom_concat('http://', R, U), atom_concat('http://u:p@', R, UA), http_get(UA, D, [request_header('Cookie'='c=1'), to(atom)]), writeq(D), nl)),
	check(cross_origin_auth, (url('/cross', U), atom_concat('http://', R, U), atom_concat('http://u:p@', R, UA), cross_headers(UA, [request_header('Cookie'='c=1'), request_header(x_keep='1')], Hs), writeq(Hs), nl)),
	check(status, (url('/teapot', U), http_get(U, D, [status_code(C), to(atom)]), writeq(C-D), nl)),
	check(not_found, (url('/nope', U), catch(http_get(U, _, []), error(E, _), true), E =.. [N|_], writeq(N), nl)),
	check(not_allowed, (url('/hello', U), http_get(U, _, [method(delete), status_code(C)]), writeq(C), nl)),
	check(head, (url('/hello', U), http_get(U, D, [method(head), status_code(C)]), writeq(C-D), nl)),
	check(stop, (url('/stop', U), http_get(U, D, [to(atom)]), writeq(D), nl)),
	thread_join(T),
	check(chunked, (raw_get("HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n5\r\ncafé\r\n1\r\n!\r\n0\r\n\r\n", D), atom_chars(A, D), atom_codes(A, Cs), writeq(Cs), nl)),
	check(to_eof, (raw_get("HTTP/1.0 200 OK\r\n\r\nall of it", D), atom_chars(A, D), writeq(A), nl)).
