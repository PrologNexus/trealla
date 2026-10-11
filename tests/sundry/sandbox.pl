% library(sandbox), SWI's safe_goal/1 and safe_call/1: whether every
% predicate a goal can reach is whitelisted, walking user and library code
% and the goals passed to meta-predicates (trealla-port FR-007).

:- use_module(library(sandbox)).
:- use_module(library(lists)).

:- multifile sandbox:safe_primitive/1, sandbox:safe_global_variable/1, sandbox:safe_meta/2.

sandbox:safe_primitive(user:trusted(_)).
sandbox:safe_global_variable(my_counter).
sandbox:safe_meta(run_it(G), [G]).

:- dynamic counter/1.
:- meta_predicate twice(0).

double(X, Y) :- Y is X * 2.
evil :- shell('echo pwned').
indirect :- evil.
trusted(_) :- shell('echo trusted').
run_it(G) :- call(G).
twice(G) :- G, G.
loop(0) :- !.
loop(N) :- N1 is N - 1, loop(N1).
evens(L, E) :- include([X]>>(0 is X mod 2), L, E).

t(G) :-
	(	catch((safe_goal(G), R = safe), error(E, _), R = E) -> true
	;	R = failed
	),
	\+ \+ (numbervars(G-R, 0, _), writeq(G-R)),
	nl.

:- initialization(main).

main :-
	t(X is 1 + 2),
	t(double(3, _)),
	t(maplist(double, [1,2], _)),
	t(append(_, _, [a])),
	t(loop(5)),
	t(evens([1,2], _)),
	t(shell(ls)),
	t(evil),
	t(indirect),
	t(maplist([Y]>>shell(Y), [ls])),
	t(call(_)),
	t(include(_, [1], _)),
	t(findall(Z, member(Z, [1]), _)),
	t(findall(_, shell(ls), _)),
	t(setof(A, B^member(A-B, [a-1]), _)),
	t(catch(true, _, shell(ls))),
	t(setup_call_cleanup(true, true, shell(ls))),
	t(\+ shell(ls)),
	t(once(member(_, [a]))),
	t(call(member, _, [a])),
	t(call(shell, ls)),
	t(format("~w~n", [x])),
	t(format("~@~n", [shell(ls)])),
	t(with_output_to(atom(_), writeln(x))),
	t(with_output_to(user_error, writeln(x))),
	t(phrase(([a], [b]), [a,b])),
	t(write(x)),
	t(open(f, write, _)),
	t(system:shell(ls)),
	t(nosuch:foo),
	t(assertz(counter(1))),
	t(assertz((counter(1) :- shell(ls)))),
	t(assertz(lists:foo(1))),
	t(clause(lists:append(_,_,_), _)),
	t(nb_setval(my_counter, 1)),
	t(nb_setval(other, 1)),
	t(trusted(x)),
	t(run_it(true)),
	t(run_it(shell(ls))),
	t(twice(true)),
	t(twice(shell(ls))),
	t(nosuch(1)),
	safe_call(double(4, D)), writeq(D), nl,
	catch(safe_call(evil), error(E, _), (\+ \+ (numbervars(E, 0, _), writeq(E)), nl)).
