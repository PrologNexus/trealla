% bb_get/2 copied the stored value out after dropping the lock, so a
% bb_put/2 in another thread could free it mid-copy and crash. And
% bb_update/3 was a get then a put, so racing threads lost updates.

:- initialization(main).

inc(0) :- !.
inc(N) :- bb_get(c, V0), V is V0+1, bb_update(c, V0, V) -> N1 is N-1, inc(N1) ; inc(N).

main :-
	bb_put(c, 0),
	findall(T, (between(1, 4, _), thread_create(inc(1000), T, [])), Ts),
	maplist(thread_join, Ts),
	bb_get(c, V),
	writeq(total(V)), nl.
