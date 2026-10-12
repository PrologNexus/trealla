% An output argument carried down a recursion cost a frame a call: the callee's head variable, bound to one in an
% older frame, pinned the callee. Only a binding into the frame a tail call reuses has to stop it.

:- initialization(main).

sum(N, A, S) :- ( N > 0 -> A1 is A+N, M is N-1, sum(M, A1, S) ; S = A ).

sum2(0, A, A) :- !.
sum2(N, A, S) :- A1 is A+N, M is N-1, sum2(M, A1, S).

len([], N, N).
len([_|T], N0, N) :- N1 is N0+1, len(T, N1, N).

mk_eq(X) :- X = f(a).
eqloop(0) :- !.
eqloop(N) :- mk_eq(_), M is N-1, eqloop(M).

check(Name, Goal, Result) :-
	call(Goal),
	statistics(max_frames, F),
	write(Name), write(': '), write(Result),
	(	F < 1000 -> write(' ok') ; write(' '), write(frames(F)) ), nl.

main :-
	check(sum, sum(100000, 0, S1), S1),
	check(sum2, sum2(100000, 0, S2), S2),
	numlist(1, 100000, L), check(len, len(L, 0, N), N),
	check(eqloop, eqloop(100000), done).
