% thread_create/3's stack_limit(Bytes), as in SWI: a thread that grows past
% it gets resource_error(stack), catchable or ending the thread with it.

:- initialization(main).

:- dynamic(got/1).

deep(0) :- !.
deep(N) :- N1 is N-1, deep(N1), true.

grow(N) :- length(L, N), maplist(=(x), L), N2 is N*2, grow(N2).

main :-
	thread_create(catch(deep(10000000), error(F, _), assertz(got(F))), T1, [stack_limit(8000000)]),
	thread_join(T1, S1),
	( retract(got(G1)) -> true ; G1 = none ),
	writeq(caught(G1, S1)), nl,
	thread_create(grow(1000), T2, [stack_limit(8000000)]),
	thread_join(T2, S2),
	( S2 = exception(error(E2, _)) -> writeq(uncaught(E2)) ; writeq(S2) ), nl,
	thread_create(deep(1000), T3, [stack_limit(8000000)]),
	thread_join(T3, S3),
	writeq(within(S3)), nl,
	catch(thread_create(true, _, [stack_limit(foo)]), error(E4, _), true),
	writeq(E4), nl.
