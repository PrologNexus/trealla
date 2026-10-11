% library(sandbox), SWI's safe_goal/1 and safe_call/1: whether every
% predicate a goal can reach is whitelisted, walking user and library code
% and the goals passed to meta-predicates, and safe_call/N, which checks a
% goal that is still a variable when it is called (trealla-port FR-007).

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
	catch(safe_call(evil), error(E, _), (\+ \+ (numbervars(E, 0, _), writeq(E)), nl)),
	% a goal position still a variable is checked when it's called
	g(call(_)),
	g(findall(_, _, _)),
	g(setof(_, _^_, _)),
	g(maplist(_, [1])),
	g(catch(_, _, true)),
	g(_:foo),
	g(maplist(double, [1], _)),
	\+ \+ r(forall(member(G, [true, shell(ls)]), call(G))),
	\+ \+ r((G = double, call(G, 3, W), W == 6)),
	\+ \+ r((G = shell, call(G, ls))),
	\+ \+ r((G = double, maplist(G, [1,2], L), L == [2,4])),
	\+ \+ r((G = shell, maplist(G, [ls]))),
	\+ \+ r((Mod = system, Mod:shell(ls))),
	\+ \+ r((G = (true, shell(ls)), G)),
	\+ \+ r((G = [X]>>(X > 0), maplist(G, [1]))),
	\+ \+ r((G = [X]>>shell(X), maplist(G, [ls]))),
	\+ \+ r(call(_)),
	\+ \+ r(safe_call(shell, ls)),
	% no way out through another module's state or private predicates
	load_text(":- module(sbpriv, [pub/1]). pub(X) :- hidden(X). hidden(secret).", []),
	t((true, sandbox:assertz(safe_meta(shell(_), _, [])))),
	t((true, lists:assertz(injected(1)))),
	t((true, lists:findall(X2, member(X2, [a]), _))),
	t((true, sbpriv:pub(_))),
	t((true, sbpriv:hidden(_))),
	t((true, sandbox:safe_call(sbpriv:hidden(_)))),
	t(assertz(term_expansion(a, b))),
	\+ \+ r((G = sbpriv:hidden(_), call(G))),
	\+ \+ r((G = sbpriv:pub(V), call(G), V == secret)),
	\+ \+ r(sandbox:assertz(safe_global_variable(gv))).

g(G) :-
	safe_guard(G, R),
	\+ \+ (numbervars(G-R, 0, _), writeq(G-R)),
	nl.

r(G) :-
	catch((safe_call(G) -> R = yes ; R = no), error(E, _), R = E),
	\+ \+ (numbervars(G-R, 0, _), writeq(G-R)),
	nl.
