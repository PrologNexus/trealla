% thread_local/1, as in SWI: a dynamic predicate whose clauses each thread
% keeps to itself. A thread starts with none, even on a reused thread id,
% and assert, retract, retractall and clause all work on its own.

:- initialization(main).

:- thread_local(counter/1), thread_local([seen/1, (pair/2)]).

static_fact(1).

t(threads, main(ML)/OL) :-
	assertz(counter(main)),
	thread_create((assertz(counter(other)), findall(X, counter(X), L), thread_send_message(main, other_sees(L))), T, []),
	thread_join(T, _),
	thread_get_message(other_sees(OL)),
	findall(X, counter(X), ML).
t(database, L1/Y/L2) :-
	retractall(counter(_)), assertz(counter(1)), assertz(counter(2)), retract(counter(1)),
	findall(X, counter(X), L1),
	( clause(counter(Y), true) -> true ; Y = none ),
	retractall(counter(_)),
	findall(X, counter(X), L2).
t(property, A/B) :-
	( predicate_property(counter(_), thread_local) -> A = tl ; A = no ),
	( predicate_property(counter(_), dynamic) -> B = dyn ; B = no ).
t(static, E) :- catch(thread_local(static_fact/1), error(E, _), true).
t(other_thread_left_nothing, L) :-
	thread_create((assertz(seen(a)), assertz(pair(1, 2))), T, []),
	thread_join(T, _),
	findall(X, seen(X), L).
t(reused_ids, R) :-
	findall(L, (between(1, 20, I), thread_create((findall(X, counter(X), L0), assertz(counter(I)), thread_send_message(main, l(L0))), T, []), thread_join(T, _), thread_get_message(l(L))), Ls),
	( forall(member(L, Ls), L == []) -> R = all_started_empty ; R = Ls ).

main :-
	forall(t(Name, R), format("~w: ~q~n", [Name, R])).
