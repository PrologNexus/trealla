% What a goal-safety walker like SWI's library(sandbox) needs to ask of the
% system: more predicate properties, static clause bodies, global variable
% lookup, and the type of each format/2 argument (trealla-port FR-007).

:- use_module(library(prolog_format)).
:- dynamic d/1.
:- multifile m/1.
:- initialization(main).

foo(X) :- bar(X), member(X, [1]).
foo(2).
bar(_).

user:goal_expansion(sq(X, Y), Y is X*X).

t(G) :-
	(	catch(G, error(E, _), (show(E), nl, fail)) -> show(G)
	;	show(no(G))
	),
	nl.

show(T) :- \+ \+ (numbervars(T, 0, _), writeq(T)).

main :-
	t(predicate_property(foo(_), number_of_clauses(_))),
	t(predicate_property(foo(_), number_of_rules(_))),
	t(predicate_property(d(_), number_of_clauses(_))),
	t(predicate_property(d(_), defined)),
	t(predicate_property(m(_), defined)),
	t(predicate_property(m(_), number_of_clauses(_))),
	t(predicate_property(nope(_), defined)),
	t(predicate_property(append(_,_,_), interpreted)),
	t(predicate_property(atom_length(_,_), interpreted)),
	t(predicate_property(atom_length(_,_), iso)),
	t(predicate_property(foo(_), iso)),
	t(predicate_property(forall(_,_), meta_predicate(_))),
	t(predicate_property(format(_,_), meta_predicate(_))),
	assertz(zz(1)), assertz((zz(2) :- zz(1))),
	findall(P, (predicate_property(zz(_), P), P \= visible), Ps),
	show(Ps), nl,
	t(findall(B, '$clause'(foo(_), B), _)),
	t('$clause'(lists:append([],_,_), _)),
	t('$clause'(atom_length(_,_), _)),
	t(clause(foo(_), _)),
	nb_setval(k1, f(x)), b_setval(k2, 1),
	t(nb_current(k1, _)),
	t(nb_current(nokey, _)),
	t(nb_current(1, _)),
	t(findall(K, (nb_current(K, _), memberchk(K, [k1,k2])), _)),
	t(nb_delete(k1)),
	t(nb_current(k1, _)),
	t(compound_name_arity(_, f, 2)),
	t(compound_name_arity(g(a,b,c), _, _)),
	t(compound_name_arity(abc, _, _)),
	t(compound_name_arguments(_, f, [a,b])),
	t(compound_name_arguments(h(1), _, _)),
	t(f(A,A) =@= f(B,B)),
	t(f(C,C) =@= f(_,_)),
	t(f(_) \=@= f(a)),
	t(expand_goal((sq(3,_), \+ sq(2,_)), _)),
	t(format_types("~w and ~a~n", _)),
	t(format_types('~*c~t~20|~@', _)),
	t(format_types("~p ~e ~s ~3d", _)),
	t(format_types("~y", _)).
