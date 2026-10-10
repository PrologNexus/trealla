% Global variables are each thread's own, unlike the blackboard: a thread
% does not see the creator's, and what it sets does not reach the creator.

:- initialization(main).

main :-
	nb_setval(k, main),
	thread_create(( catch(nb_getval(k, V), error(E, _), V = E), nb_setval(k, other), writeq(thread_sees(V)), nl ), T, []),
	thread_join(T, _),
	nb_getval(k, W),
	writeq(main_sees(W)), nl.
