% Who owns a task, and when does it get to run.
%
% Every property here is a *current* behaviour, established by probing
% the engine rather than by reading the docs. Some are arguably wrong -
% a task spawned by a task and then never waited for is dropped without
% a word - and they are pinned down precisely because they are what a
% move to a single global scheduler would change. If one of these
% outputs changes, that has to be a decision someone made, not a side
% effect they did not notice.
%
% The rules, as they stand:
%
%   - a task is a subquery, and it belongs to whoever spawned it. Tasks
%     therefore nest: a task that spawns a task owns it.
%   - the scheduler itself is shared, one per prolog instance. Ownership
%     decides when a task_wait/0 may return, not what is allowed to run.
%   - task_wait/0 returns when the caller's whole subtree is done, at any
%     depth - so a task spawned anywhere below will run, whether or not
%     the task that spawned it waited for it.
%
% That last rule changed in GUSTTO phase 0. Before the scheduler was
% hoisted out of the query, each spawner had a scheduler of its own and
% a task that spawned without waiting had its children thrown away when
% it finished. Two tests below are marked with what they used to say.
%
% Observation is through a dynamic predicate rather than send/1, for two
% reasons: tasks share the database with their parent, so it works at
% any depth where send/1 only reaches one level; and it does not tie
% these properties to a messaging layer that is due to be replaced.
%
% Nothing here depends on timing or on the order two independent tasks
% happen to interleave.

:- initialization(main).

:- dynamic(ran/1).

note(X) :- assertz(ran(X)).

ran_list(L) :- findall(X, ran(X), L).

reset :- retractall(ran(_)).

report(Name, Got, Expect) :-
	(	Got == Expect
	->	format("~w: ok~n", [Name])
	;	format("~w: FAILED got ~q wanted ~q~n", [Name,Got,Expect])
	).

% A task may spawn a task and not wait for it. The child still runs,
% because the task_wait/0 at the top covers the whole subtree.
%
% Before phase 0 this reported [neglectful] alone: the child went into a
% scheduler belonging to `neglectful` that nothing ever drained, and was
% discarded when that task finished.

orphan :- note(orphan).
neglectful :- task_call(orphan), note(neglectful).

spawner_need_not_wait :-
	reset,
	task_call(neglectful),
	task_wait,
	ran_list(L),
	report(spawner_need_not_wait, L, [neglectful,orphan]).

% The same task, but waiting: now the child runs, and it runs before
% the owner continues past its task_wait/0.

attentive :- task_call(orphan), task_wait, note(attentive).

owner_waits_child_runs :-
	reset,
	task_call(attentive),
	task_wait,
	ran_list(L),
	report(owner_waits_child_runs, L, [orphan,attentive]).

% Nesting is not limited to one level, and each level needs its own
% task_wait/0. The top only sees the deepest task because every owner in the
% chain waits for the one below it.

deep3 :- note(deep3).
deep2 :- task_call(deep3), task_wait, note(deep2).
deep1 :- task_call(deep2), task_wait, note(deep1).

nesting_is_recursive :-
	reset,
	task_call(deep1),
	task_wait,
	ran_list(L),
	report(nesting_is_recursive, L, [deep3,deep2,deep1]).

% A gap in the chain of task_wait/0 calls does not sever what is below it.
% sever2 spawns deep3 without waiting, but sever1's task_wait/0 covers its
% whole subtree, so deep3 runs - and runs before sever1 resumes.
%
% Before phase 0 this reported [sever2,sever1]: deep3 was discarded
% along with the scheduler sever2 owned.

sever2 :- task_call(deep3), note(sever2).
sever1 :- task_call(sever2), task_wait, note(sever1).

gap_in_chain_does_not_sever :-
	reset,
	task_call(sever1),
	task_wait,
	ran_list(L),
	report(gap_in_chain_does_not_sever, L, [sever2,deep3,sever1]).

% Tasks run in the order they were spawned, and to completion: task_wait/0
% drains rather than interleaving at every opportunity.

seq(N) :- note(a(N)), note(b(N)).

spawn_order_is_fifo :-
	reset,
	task_call(seq, 1),
	task_call(seq, 2),
	task_wait,
	ran_list(L),
	report(spawn_order_is_fifo, L, [a(1),b(1),a(2),b(2)]).

% A task calling task_end_wait/0 releases its owner from task_wait/0 with the
% other tasks still queued; they run on the next task_wait/0. The flag must
% not survive into that second task_wait/0.

stopper :- note(stopper), task_end_wait.
after(N) :- note(after(N)).

end_wait_releases_once :-
	reset,
	task_call(stopper),
	task_call(after, 1),
	task_wait,
	ran_list(L1),
	task_wait,
	ran_list(L2),
	report(end_wait_releases_first_wait, L1, [stopper]),
	report(end_wait_releases_second_wait, L2, [stopper,after(1)]).

% task_end_wait/0 with nothing waiting is not an error.

end_wait_without_wait :-
	(	catch(task_end_wait, E, true)
	->	( var(E) -> R = ok ; R = threw(E) )
	;	R = failed
	),
	report(end_wait_without_wait, R, ok).

% task_wait/0 with no tasks at all succeeds and does nothing.

wait_with_no_tasks :-
	reset,
	(	catch(task_wait, E, true)
	->	( var(E) -> R = ok ; R = threw(E) )
	;	R = failed
	),
	report(wait_with_no_tasks, R, ok).

main :-
	spawner_need_not_wait,
	owner_waits_child_runs,
	nesting_is_recursive,
	gap_in_chain_does_not_sever,
	spawn_order_is_fifo,
	end_wait_releases_once,
	end_wait_without_wait,
	wait_with_no_tasks.
