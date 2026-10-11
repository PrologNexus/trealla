% Thread signals: one sent while the target was backtracking was lost; a
% delivered one returned past the goal it interrupted; none arrived during
% sleep/1; thread_cancel/1 freed a running thread's query and crashed; and
% thread_exit/1 inside catch/3 crashed the at_exit goal that followed.

:- initialization(main).

:- dynamic(log/1).

spin :- catch((repeat, fail), E, assertz(log(caught(E)))).

count :- forall(between(1, 100000, _), flag(c, V, V+1)).

hook :- assertz(log(hook)).

t_spin(R) :- thread_create(spin, T, []), sleep(0.1), thread_signal(T, throw(stop)), thread_join(T, _), ( log(caught(stop)) -> R = delivered ; R = lost ).
t_no_skip(R) :- thread_create(count, T, []), forall(between(1, 500, _), catch(thread_signal(T, true), _, true)), thread_join(T, S), flag(c, N, N), R = S/N.
t_sleep(R) :- thread_create(sleep(10), T, []), sleep(0.1), thread_signal(T, throw(stop)), thread_join(T, R).
t_cancel(R) :- retractall(log(_)), thread_create((repeat, fail), T, [at_exit(hook)]), sleep(0.1), thread_cancel(T), sleep(0.3), ( log(hook) -> R = hook_ran ; R = no_hook ).
t_cancel_joined(R) :- thread_create(spin, T, []), thread_create((sleep(0.1), thread_cancel(T)), _, []), thread_join(T, R).
t_exit_in_catch(R) :- retractall(log(_)), thread_create(catch(thread_exit(x), _, true), T, [at_exit(hook)]), thread_join(T, S), ( log(hook) -> R = S ; R = no_hook(S) ).

main :-
	forall(
		member(T, [t_spin, t_no_skip, t_sleep, t_cancel, t_cancel_joined, t_exit_in_catch]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
