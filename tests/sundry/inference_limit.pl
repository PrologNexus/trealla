% call_with_inference_limit/3 as SWI has it: ! for a deterministic success,
% true with choicepoints left, inference_limit_exceeded when the limit is
% hit; the goal's own failure and exceptions pass through, and an inner
% limit inside an outer one reports the overrun.

:- initialization(main).

t_det(R) :- call_with_inference_limit(true, 10, R).
t_nondet(R) :- findall(X-R0, call_with_inference_limit(member(X, [a,b]), 100, R0), R).
t_retry(R) :- findall(R0, call_with_inference_limit(between(1, 3, _), 20, R0), R).
t_exceeded(R) :- call_with_inference_limit((repeat, fail), 1000, R).
t_zero(R) :- call_with_inference_limit(true, 0, R).
t_fail(R) :- ( call_with_inference_limit(fail, 10, _) -> R = succeeded ; R = failed ).
t_throw(R) :- catch(call_with_inference_limit(throw(x), 10, _), R, true).
t_inner(R) :- call_with_inference_limit(call_with_inference_limit((repeat, fail), 100, R1), 100000, R2), R = R1/R2.
t_outer(R) :- call_with_inference_limit(call_with_inference_limit((repeat, fail), 100000, R1), 1000, R2), R = R1/R2.
t_negative(R) :- catch(call_with_inference_limit(true, -1, _), error(R, _), true).
t_restored(R) :- call_with_inference_limit((repeat, fail), 10, _), catch(call_with_inference_limit(throw(y), 10, _), _, true), ( call_with_inference_limit(fail, 10, _) ; true ), between(1, 10000, _), fail ; R = unlimited_after.

main :-
	forall(
		member(T, [t_det, t_nondet, t_retry, t_exceeded, t_zero, t_fail, t_throw, t_inner, t_outer, t_negative, t_restored]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
