% A task that finishes with a choicepoint left must not stop to ask the
% toplevel for more answers.

:- initialization(main).

main :-
	task_call((member(X, [a,b]), writeln(X))),
	task_call((member(Y, [1,2]), sleep(0.01), writeln(Y))),
	task_wait,
	writeln(waited).
