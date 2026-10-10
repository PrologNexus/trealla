% A thread detaching itself in its at_exit goal while another thread was
% already in thread_join/2 left both waiting forever. As in SWI the detach
% is now refused, and the join gets the real status.

:- initialization(main).

hook :- thread_self(Me), catch(thread_detach(Me), error(E, _), assertz(seen(E))).

:- dynamic(seen/1).

main :-
	thread_create(sleep(0.2), T, [at_exit(hook)]),
	thread_join(T, S),
	writeq(joined(S)), nl,
	( seen(permission_error(detach, thread, _)) -> writeln(detach_refused) ; writeln(no_error) ),
	thread_create(true, T2, [at_exit(hook)]),
	sleep(0.3),
	( catch(thread_join(T2, _), error(E2, _), true), nonvar(E2) -> writeq(E2), nl ; writeln(joinable) ).
