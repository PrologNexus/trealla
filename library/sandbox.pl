/*  Ported from SWI-Prolog's library(sandbox) to Trealla.

    Author:        Jan Wielemaker
    E-mail:        J.Wielemaker@vu.nl
    WWW:           http://www.swi-prolog.org
    Copyright (c)  2013-2024, VU University Amsterdam
                              CWI, Amsterdam
                              SWI-Prolog Solutions b.v
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in
       the documentation and/or other materials provided with the
       distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

:- module(sandbox, [safe_goal/1, safe_call/1]).

:- use_module(library(lists)).
:- use_module(library(assoc)).
:- use_module(library(error)).
:- use_module(library(prolog_format)).

% The hooks are SWI's: an application adds clauses for them, qualified as
% sandbox:safe_primitive(...) and so on, after declaring them multifile.
%
% Where SWI tells a system predicate by its module, here it is one that
% predicate_property/2 reports built_in, which user code can't redefine.
% Such a predicate's home module is 'system', so a declaration may name
% it either bare or as system:Goal. A library predicate's is the module it
% is imported from, eg. lists:member(_,_).

:- multifile
	safe_primitive/1,				% Goal
	safe_meta_predicate/1,			% Module:Name/Arity
	safe_meta/2,					% Goal, Calls
	safe_meta/3,					% Goal, Context, Calls
	safe_global_variable/1,			% Name
	safe_directive/1,				% Module:Goal
	safe_prolog_flag/2.				% Name, Value

:- dynamic
	safe_meta_predicate/1,
	safe_meta/3,
	safe_global_variable/1,
	safe_directive/1.

% After the declarations, as library(yall) adds to safe_meta_predicate/1.

:- use_module(library(yall), [lambda_calls/3]).

:- meta_predicate
	safe_goal(:),
	safe_call(:).

:- help(safe_goal(:callable), [iso(false), desc('Throw unless every predicate the goal can reach is whitelisted.')]).
:- help(safe_call(:callable), [iso(false), desc('Expand, check with safe_goal/1, then call the goal.')]).

% safe_call(:Goal): expands then checks Goal, and calls it only if safe.

safe_call(Goal0) :-
	qualified(Goal0, M:Goal1),
	expand_goal(Goal1, Goal),
	safe_goal(M:Goal),
	call(M:Goal).

% safe_goal(:Goal) is det: true if every predicate Goal can reach is safe,
% that is whitelisted by safe_primitive/1 or a safe meta-predicate whose
% goal arguments are themselves safe. It throws instantiation_error if it
% can't tell which predicate a goal position calls, and
% permission_error(call, sandboxed, G) for one that is not safe. It is
% also not allowed to call a module's predicate that it neither exports
% nor declares public.

safe_goal(Goal0) :-
	qualified(Goal0, M:Goal),
	empty_assoc(Safe0),
	catch(safe(Goal, M, [], Safe0, _), E, true),
	!,
	nb_delete(sandbox_last_error),
	(	var(E) -> true
	;	throw(E)
	).
safe_goal(_) :-
	nb_current(sandbox_last_error, E),
	!,
	nb_delete(sandbox_last_error),
	throw(E).
safe_goal(G) :-
	throw(error(instantiation_error, sandbox(G, []))).

% A meta argument arrives unqualified when it is call/N, once/1 or ignore/1,
% which then stands for a goal in user.

qualified(G0, M:G) :-
	strip_module(G0, M0, G),
	( atom(M0) -> M = M0 ; M = user ).

% safe(+Goal, +Module, +Parents, +Safe0, -Safe) is semidet.

safe(V, _, Parents, _, _) :-
	var(V),
	!,
	Error = error(instantiation_error, sandbox(V, Parents)),
	nb_setval(sandbox_last_error, Error),
	throw(Error).
safe(M:G, _, Parents, Safe0, Safe) :-
	!,
	must_be(atom, M),
	must_be(callable, G),
	known_module(M:G, Parents),
	home_module(M, G, M2),
	(	(	safe_primitive(M2:G)
		;	safe_primitive(G),
			system_predicate(M, G)
		)
	->	Safe = Safe0
	;	(	predicate_property(M:G, exported)
		;	predicate_property(M:G, public)
		;	predicate_property(M:G, multifile)
		;	system_predicate(M, G)
		;	memberchk(M:_, Parents)
		)
	->	safe(G, M, Parents, Safe0, Safe)
	;	throw(error(permission_error(call, sandboxed, M:G), sandbox(M:G, Parents)))
	).
safe(G, M, Parents, Safe, Safe) :-
	catch(safe_primitive(G),
		error(instantiation_error, _),
		rethrow_instantiation_error([G|Parents])),
	system_predicate(M, G),
	!.
safe(G, M, Parents, Safe, Safe) :-
	known_module(M:G, Parents),
	home_module(M, G, M2),
	(	catch(safe_primitive(M2:G),
			error(instantiation_error, _),
			rethrow_instantiation_error([M2:G|Parents]))
	;	M2 \== system,
		predicate_property(M2:G, number_of_rules(0))
	),
	!.
safe(G, M, Parents, Safe0, Safe) :-
	system_predicate(M, G),
	safe_meta_call(G, M, Called),
	!,
	add_iso_parent(G, Parents, Parents1),
	safe_list(Called, M, Parents1, Safe0, Safe).
safe(G, M, Parents, Safe0, Safe) :-
	home_module(M, G, M2),
	safe_meta_call(M2:G, M, Called),
	!,
	safe_list(Called, M, Parents, Safe0, Safe).
safe(G, M, Parents, Safe0, Safe) :-
	goal_id(M:G, Id, Gen),
	(	get_assoc(Id, Safe0, _)
	->	Safe = Safe0
	;	put_assoc(Id, Safe0, true, Safe1),
		(	Gen == M:G
		->	safe_clauses(Gen, M, [Id|Parents], Safe1, Safe)
		;	catch(safe_clauses(Gen, M, [Id|Parents], Safe1, Safe),
				error(instantiation_error, Ctx),
				unsafe(Parents, Ctx))
		)
	),
	!.

unsafe(Parents, Var) :-
	var(Var),
	!,
	nb_setval(sandbox_last_error, error(instantiation_error, sandbox(_, Parents))),
	fail.
unsafe(_Parents, Ctx) :-
	Ctx = sandbox(_,_),
	nb_setval(sandbox_last_error, error(instantiation_error, Ctx)),
	fail.

rethrow_instantiation_error(Parents) :-
	throw(error(instantiation_error, sandbox(_, Parents))).

% A system predicate, or a control construct, which are not redefinable.

system_predicate(_, G) :-
	control(G),
	!.
system_predicate(M, G) :-
	predicate_property(M:G, built_in),
	!.

control((_,_)).
control((_;_)).
control((_->_)).
control((_*->_)).
control(\+(_)).
control(!).
control(true).
control(fail).
control(call(_)).

% The module defining G as called in M: the one it is imported from, else
% 'system' for a system predicate, else M itself.

home_module(M, G, H) :-
	(	\+ control(G), predicate_property(M:G, imported_from(H0)) -> H = H0
	;	system_predicate(M, G) -> H = system
	;	H = M
	).

safe_clauses(G, M, Parents, Safe0, Safe) :-
	\+ system_predicate(M, G),
	predicate_property(M:G, interpreted),
	def_module(M:G, MD:QG),
	!,
	findall(Body, '$clause'(MD:QG, Body), Bodies),
	safe_bodies(Bodies, MD, Parents, Safe0, Safe).
safe_clauses(G, M, [_|Parents], _, _) :-
	(	system_predicate(M, G)
	;	predicate_property(M:G, visible)
	),
	!,
	throw(error(permission_error(call, sandboxed, G), sandbox(M:G, Parents))).
safe_clauses(_, _, [G|Parents], _, _) :-
	throw(error(existence_error(procedure, G), sandbox(G, Parents))).

known_module(M:_, _) :-
	current_module(M),
	!.
known_module(M:G, Parents) :-
	throw(error(permission_error(call, sandboxed, M:G), sandbox(M:G, Parents))).

add_iso_parent(G, Parents, Parents) :-
	is_control(G),
	!.
add_iso_parent(G, Parents, [G|Parents]).

is_control((_,_)).
is_control((_;_)).
is_control((_->_)).
is_control((_*->_)).
is_control(\+(_)).

% safe_bodies(+Bodies, +Module, +Parents, +Safe0, -Safe). A body goal
% qualified with another module is checked as the call into it that it is.

safe_bodies([], _, _, Safe, Safe).
safe_bodies([H|T], M, Parents, Safe0, Safe) :-
	copy_term(H, H2),
	safe(H2, M, Parents, Safe0, Safe1),
	safe_bodies(T, M, Parents, Safe1, Safe).

def_module(M:G, MD:QG) :-
	predicate_property(M:G, imported_from(MD)),
	!,
	meta_qualify(MD:G, M, QG).
def_module(M:G, M:QG) :-
	meta_qualify(M:G, M, QG).

% safe_list(+Called, +Module, +Parents, +Safe0, -Safe): goals called by a
% meta-predicate, unqualified where in the caller's own module.

safe_list([], _, _, Safe, Safe).
safe_list([H|T], M, Parents, Safe0, Safe) :-
	(	H = M2:H2,
		M == M2
	->	copy_term(H2, H3)
	;	copy_term(H, H3)
	),
	safe(H3, M, Parents, Safe0, Safe1),
	safe_list(T, M, Parents, Safe1, Safe).

% meta_qualify(:G, +M, -QG): qualifies G's goal arguments with M.

meta_qualify(MD:G, M, QG) :-
	predicate_property(MD:G, meta_predicate(Head)),
	!,
	G =.. [Name|Args],
	Head =.. [_|Q],
	qualify_args(Q, M, Args, QArgs),
	QG =.. [Name|QArgs].
meta_qualify(_:G, _, G).

qualify_args([], _, [], []).
qualify_args([H|T], M, [A|AT], [Q|QT]) :-
	qualify_arg(H, M, A, Q),
	qualify_args(T, M, AT, QT).

qualify_arg(S, M, A, Q) :-
	q_arg(S),
	!,
	qualify(A, M, Q).
qualify_arg(_, _, A, A).

q_arg(I) :- integer(I), !.
q_arg(:).
q_arg(^).
q_arg(//).

qualify(A, M, MZ:Q) :-
	strip_module(M:A, MZ, Q).

% goal_id(:Goal, -Id, -Gen) is nondet: an id for the goal proven safe, the
% most general form first, then the specific one.

goal_id(M:Goal, M:Id, Gen) :-
	!,
	goal_id(Goal, Id, Gen).
goal_id(Var, _, _) :-
	var(Var),
	!,
	instantiation_error(Var).
goal_id(Atom, Atom, Atom) :-
	atom(Atom),
	!.
goal_id(Term, _, _) :-
	\+ compound(Term),
	!,
	type_error(callable, Term).
goal_id(Term, Skolem, Gen) :-
	compound_name_arity(Term, Name, Arity),
	compound_name_arity(Skolem, Name, Arity),
	compound_name_arity(Gen, Name, Arity),
	copy_goal_args(1, Term, Skolem, Gen),
	(	Gen =@= Term
	->	!
	;	true
	),
	numbervars(Skolem, 0, _).
goal_id(Term, Skolem, Term) :-
	copy_term(Term, Skolem),
	numbervars(Skolem, 0, _).

% The most general form keeps module-qualified arguments, as they are
% likely to be called.

copy_goal_args(I, Term, Skolem, Gen) :-
	arg(I, Term, TA),
	!,
	arg(I, Skolem, SA),
	arg(I, Gen, GA),
	copy_goal_arg(TA, SA, GA),
	I2 is I + 1,
	copy_goal_args(I2, Term, Skolem, Gen).
copy_goal_args(_, _, _, _).

copy_goal_arg(Arg, SArg, Arg) :-
	copy_goal_arg(Arg),
	!,
	copy_term(Arg, SArg).
copy_goal_arg(_, _, _).

copy_goal_arg(Var) :- var(Var), !, fail.
copy_goal_arg(_:_).

% safe_primitive(?Goal) is nondet: Goal is safe to call, as it can't reach
% dangerous resources or upset the rest of the process. A bare goal is the
% system predicate of that name, a qualified one the predicate defined in
% that module.

safe_primitive(true).
safe_primitive(fail).
safe_primitive(false).
safe_primitive(repeat).
safe_primitive(!).
										% types
safe_primitive(var(_)).
safe_primitive(nonvar(_)).
safe_primitive(integer(_)).
safe_primitive(float(_)).
safe_primitive(rational(_)).
safe_primitive(number(_)).
safe_primitive(atom(_)).
safe_primitive(string(_)).
safe_primitive(atomic(_)).
safe_primitive(compound(_)).
safe_primitive(callable(_)).
safe_primitive(ground(_)).
safe_primitive(cyclic_term(_)).
safe_primitive(acyclic_term(_)).
safe_primitive(is_stream(_)).
safe_primitive(is_list(_)).
safe_primitive(is_partial_list(_)).
safe_primitive(is_list_or_partial_list(_)).
safe_primitive(is_bigint(_)).
safe_primitive(must_be(_,_)).
safe_primitive(must_be(_,_,_,_)).
safe_primitive(can_be(_,_)).
safe_primitive(can_be(_,_,_,_)).
safe_primitive(error:must_be(_,_)).
safe_primitive(error:can_be(_,_)).
										% ordering
safe_primitive(@>(_,_)).
safe_primitive(@>=(_,_)).
safe_primitive(==(_,_)).
safe_primitive(@<(_,_)).
safe_primitive(@=<(_,_)).
safe_primitive(compare(_,_,_)).
safe_primitive(sort(_,_)).
safe_primitive(msort(_,_)).
safe_primitive(sort(_,_,_,_)).
safe_primitive(keysort(_,_)).
safe_primitive(=@=(_,_)).
safe_primitive(\=@=(_,_)).
safe_primitive(variant(_,_)).
										% unification and equivalence
safe_primitive(=(_,_)).
safe_primitive(\=(_,_)).
safe_primitive(?=(_,_)).
safe_primitive(unifiable(_,_,_)).
safe_primitive(unify_with_occurs_check(_,_)).
safe_primitive(\==(_,_)).
safe_primitive(dif:dif(_,_)).
										% arithmetic
safe_primitive(is(_,_)).
safe_primitive(>(_,_)).
safe_primitive(>=(_,_)).
safe_primitive(=:=(_,_)).
safe_primitive(=\=(_,_)).
safe_primitive(=<(_,_)).
safe_primitive(<(_,_)).
safe_primitive(between(_,_,_)).
safe_primitive(succ(_,_)).
safe_primitive(divmod(_,_,_,_)).
safe_primitive(random(_)).
safe_primitive(random_between(_,_,_)).
										% term handling
safe_primitive(arg(_,_,_)).
safe_primitive(nb_setarg(_,_,_)).
safe_primitive(functor(_,_,_)).
safe_primitive(_ =.. _).
safe_primitive(compound_name_arity(_,_,_)).
safe_primitive(compound_name_arguments(_,_,_)).
safe_primitive(copy_term(_,_)).
safe_primitive(copy_term(_,_,_)).
safe_primitive(copy_term_nat(_,_)).
safe_primitive(duplicate_term(_,_)).
safe_primitive(numbervars(_,_,_)).
safe_primitive(subsumes_term(_,_)).
safe_primitive(term_hash(_,_)).
safe_primitive(term_hash(_,_,_)).
safe_primitive(term_variables(_,_)).
safe_primitive(term_variables(_,_,_)).
safe_primitive(term_singletons(_,_)).
										% atoms
safe_primitive(atom_chars(_,_)).
safe_primitive(atom_codes(_,_)).
safe_primitive(sub_atom(_,_,_,_,_)).
safe_primitive(atom_concat(_,_,_)).
safe_primitive(atom_length(_,_)).
safe_primitive(atom_number(_,_)).
safe_primitive(atom_lower(_,_)).
safe_primitive(atom_upper(_,_)).
safe_primitive(char_code(_,_)).
safe_primitive(atomic_concat(_,_,_)).
safe_primitive(atomic_list_concat(_,_)).
safe_primitive(atomic_list_concat(_,_,_)).
safe_primitive(term_to_atom(_,_)).
safe_primitive(charsio:char_type(_,_)).
safe_primitive(charsio:code_type(_,_)).
										% numbers
safe_primitive(number_codes(_,_)).
safe_primitive(number_chars(_,_)).
										% strings
safe_primitive(string_codes(_,_)).
safe_primitive(string_concat(_,_,_)).
safe_primitive(string_length(_,_)).
safe_primitive(string_lower(_,_)).
safe_primitive(string_upper(_,_)).
safe_primitive(sub_string(_,_,_,_,_)).
safe_primitive(split_string(_,_,_,_)).
safe_primitive(split(_,_,_,_)).
safe_primitive(replace(_,_,_,_)).
safe_primitive(read_term_from_atom(_,_,_)).
safe_primitive(read_from_atom(_,_)).
safe_primitive(read_from_chars(_,_)).
safe_primitive(read_term_from_chars(_,_,_)).
safe_primitive(write_term_to_atom(_,_,_)).
safe_primitive(write_canonical_to_atom(_,_,_)).
safe_primitive(write_term_to_chars(_,_,_)).
safe_primitive(write_canonical_to_chars(_,_,_)).
safe_primitive(hex_chars(_,_)).
safe_primitive(octal_chars(_,_)).
safe_primitive(hex_bytes(_,_)).
safe_primitive(base64(_,_,_)).
safe_primitive(chars_base64(_,_,_)).
safe_primitive(urlenc(_,_,_)).
safe_primitive(chars_urlenc(_,_,_)).
safe_primitive(sre_compile(_,_)).
safe_primitive(sre_match(_,_,_,_)).
safe_primitive(sre_matchp(_,_,_,_)).
safe_primitive(sre_match_all(_,_,_)).
safe_primitive(sre_match_all_pos(_,_,_)).
safe_primitive(sre_subst(_,_,_,_)).
safe_primitive(sre_substp(_,_,_,_)).
safe_primitive(sre_subst_all(_,_,_,_)).
safe_primitive(crypto_data_hash(_,_,_)).
safe_primitive(crypto_n_random_bytes(_,_)).
safe_primitive(uuid(_)).
										% lists
safe_primitive(length(_,_)).
safe_primitive(lists:member(_,_)).
safe_primitive(lists:memberchk(_,_)).
safe_primitive(lists:select(_,_,_)).
safe_primitive(lists:selectchk(_,_,_)).
safe_primitive(lists:append(_,_)).
safe_primitive(lists:append(_,_,_)).
safe_primitive(lists:subtract(_,_,_)).
safe_primitive(lists:union(_,_,_)).
safe_primitive(lists:intersection(_,_,_)).
safe_primitive(lists:is_set(_)).
safe_primitive(lists:nth0(_,_,_)).
safe_primitive(lists:nth1(_,_,_)).
safe_primitive(lists:nth0(_,_,_,_)).
safe_primitive(lists:nth1(_,_,_,_)).
safe_primitive(lists:last(_,_)).
safe_primitive(lists:same_length(_,_)).
safe_primitive(lists:transpose(_,_)).
safe_primitive(lists:sum_list(_,_)).
safe_primitive(lists:max_list(_,_)).
safe_primitive(lists:min_list(_,_)).
safe_primitive(lists:list_sum(_,_)).
safe_primitive(lists:list_max(_,_)).
safe_primitive(lists:list_min(_,_)).
safe_primitive(lists:list_to_set(_,_)).
safe_primitive(lists:reverse(_,_)).
safe_primitive(lists:permutation(_,_)).
										% exceptions
safe_primitive(throw(_)).
										% misc
safe_primitive(current_prolog_flag(_,_)).
safe_primitive(current_op(_,_,_)).
safe_primitive(sleep(_)).
safe_primitive(thread_sleep(_)).
safe_primitive(thread_self(_)).
safe_primitive(get_time(_)).
safe_primitive(wall_time(_)).
safe_primitive(cpu_time(_)).
safe_primitive(date_time(_,_,_,_,_,_)).
safe_primitive(date_time(_,_,_,_,_,_,_)).
safe_primitive(posix_time(_)).
safe_primitive(posix_gmtime(_,_)).
safe_primitive(posix_localtime(_,_)).
safe_primitive(posix_mktime(_,_)).
safe_primitive(posix_strftime(_,_,_)).
safe_primitive(posix_strptime(_,_,_)).
safe_primitive(posix_ctime(_,_)).
safe_primitive(statistics(_,_)).
safe_primitive(thread_property(Id,_)) :-
	(	var(Id)
	->	instantiation_error(Id)
	;	thread_self(Id)
	).
safe_primitive(strip_module(_,_,_)).
										% database
safe_primitive(clause(H,_)) :- safe_clause(H).
safe_primitive(asserta(X)) :- safe_assert(X).
safe_primitive(assertz(X)) :- safe_assert(X).
safe_primitive(retract(X)) :- safe_assert(X).
safe_primitive(retractall(X)) :- safe_assert(X).
safe_primitive(current_predicate(X)) :- safe_current_predicate(X).
safe_primitive(predicate_property(Pred, _)) :-
	nonvar(Pred),
	Pred \= (_:_).
										% globals
safe_primitive(b_getval(_,_)).
safe_primitive(b_setval(Var,_)) :-
	safe_global_var(Var).
safe_primitive(nb_getval(_,_)).
safe_primitive(nb_setval(Var,_)) :-
	safe_global_var(Var).
safe_primitive(nb_current(_,_)).
										% output
safe_primitive(writeln(_)).

% safe_assert(+Term) is semidet: asserting a fact in the current module.

safe_assert(C) :- cyclic_term(C), !, fail.
safe_assert(X) :- var(X), !, fail.
safe_assert((_Head:-_Body)) :- !, fail.
safe_assert(_:_) :- !, fail.
safe_assert(_).

% safe_clause(+Head) is semidet: clause/2 that doesn't cross a module
% boundary, which could read another module's private clauses.

safe_clause(H) :- var(H), !.
safe_clause(_:_) :- !, fail.
safe_clause(_).

safe_global_var(Name) :-
	var(Name),
	!,
	instantiation_error(Name).
safe_global_var(Name) :-
	safe_global_variable(Name).

safe_current_predicate(X) :-
	nonvar(X),
	X = _:_,
	!,
	fail.
safe_current_predicate(_).

% safe_meta(+Goal, -Called:list(callable)) is semidet: a meta-predicate
% that is safe if every goal in Called is.

safe_meta(with_output_to(Output, G), [G]) :-
	safe_output(Output),
	!.
safe_meta(format(Format), Calls) :-
	format_calls(Format, [], Calls).
safe_meta(format(Format, Args), Calls) :-
	format_calls(Format, Args, Calls).
safe_meta(format(Output, Format, Args), Calls) :-
	safe_output(Output),
	format_calls(Format, Args, Calls).
safe_meta(set_prolog_flag(Flag, Value), []) :-
	atom(Flag),
	safe_prolog_flag(Flag, Value).
safe_meta(freeze:freeze(_Var, Goal), [Goal]).
safe_meta(when:when(_Cond, Goal), [Goal]).
safe_meta(_:Lambda, [Goal]) :-
	lambda_goal(Lambda, Goal).
safe_meta(phrase(NT, Xs0, Xs), [Goal]) :-
	expand_nt(NT, Xs0, Xs, Goal).
safe_meta(phrase(NT, Xs0), [Goal]) :-
	expand_nt(NT, Xs0, [], Goal).

% A yall lambda, Params>>Body or Free/Body with any extra arguments, calls
% its body with the parameters bound.

lambda_goal(Lambda, Goal) :-
	compound(Lambda),
	compound_name_arguments(Lambda, Name, [A1,A2|Extra]),
	(	Name == (>>) -> true
	;	Name == (/), nonvar(A1), A1 = {_}
	),
	L =.. [Name, A1, A2],
	lambda_calls(L, Extra, Goal).

% expand_nt(+NT, ?Xs0, ?Xs, -NewGoal): as the grammar body would compile,
% but an error if NT is not instantiated enough.

expand_nt(NT, _Xs0, _Xs, _NewGoal) :-
	strip_module(NT, _, Plain),
	var(Plain),
	!,
	instantiation_error(Plain).
expand_nt(NT, Xs0, Xs, NewGoal) :-
	expand_term((pseudo_nt --> NT), Clause),
	Clause = (pseudo_nt(Xs0c, Xsc) :- NewGoal0),
	(	var(Xsc), Xsc \== Xs0c
	->	Xs = Xsc, NewGoal1 = NewGoal0
	;	NewGoal1 = (NewGoal0, Xsc = Xs)
	),
	(	var(Xs0c)
	->	Xs0 = Xs0c,
		NewGoal = NewGoal1
	;	NewGoal = (Xs0 = Xs0c, NewGoal1)
	).

% safe_meta_call(+Goal, +Context, -Called:list(callable)) is semidet.

safe_meta_call(Goal, Context, Called) :-
	(	safe_meta(Goal, Called)
	->	true
	;	safe_meta(Goal, Context, Called)
	),
	!.
safe_meta_call(Goal, _, Called) :-
	Goal = M:Plain,
	compound(Plain),
	compound_name_arity(Plain, Name, Arity),
	safe_meta_predicate(M:Name/Arity),
	predicate_property(Goal, meta_predicate(Spec)),
	!,
	called(Spec, Plain, Called).
safe_meta_call(M:Goal, _, Called) :-
	!,
	generic_goal(Goal, Gen),
	safe_meta(M:Gen),
	called(Gen, Goal, Called).
safe_meta_call(Goal, _, Called) :-
	generic_goal(Goal, Gen),
	safe_meta(Gen),
	called(Gen, Goal, Called).

called(Gen, Goal, Called) :-
	compound_name_arity(Goal, _, Arity),
	called(1, Arity, Gen, Goal, Called).

called(I, Arity, Gen, Goal, Called) :-
	I =< Arity,
	!,
	arg(I, Gen, Spec),
	(	calling_meta_spec(Spec)
	->	arg(I, Goal, Called0),
		extend(Spec, Called0, G),
		Called = [G|Rest]
	;	Called = Rest
	),
	I2 is I + 1,
	called(I2, Arity, Gen, Goal, Rest).
called(_, _, _, _, []).

generic_goal(G, Gen) :-
	functor(G, Name, Arity),
	functor(Gen, Name, Arity).

calling_meta_spec(V) :- var(V), !, fail.
calling_meta_spec(I) :- integer(I), !.
calling_meta_spec(^).
calling_meta_spec(//).

extend(^, G, Plain) :-
	!,
	strip_existential(G, Plain).
extend(//, DCG, Goal) :-
	!,
	expand_nt(DCG, _, _, Goal).
extend(0, G, G) :- !.
extend(I, M:G0, M:G) :-
	!,
	G0 =.. List,
	length(Extra, I),
	append(List, Extra, All),
	G =.. All.
extend(I, G0, G) :-
	G0 =.. List,
	length(Extra, I),
	append(List, Extra, All),
	G =.. All.

strip_existential(Var, Var) :-
	var(Var),
	!.
strip_existential(M:G0, M:G) :-
	!,
	strip_existential(G0, G).
strip_existential(_^G0, G) :-
	!,
	strip_existential(G0, G).
strip_existential(G, G).

% safe_meta(?Template): a meta-predicate safe when the goals in its
% integer, ^ and // positions are.

safe_meta((0,0)).
safe_meta((0;0)).
safe_meta((0->0)).
safe_meta((0*->0)).
safe_meta(\+(0)).
safe_meta(call(0)).
safe_meta(call(1,*)).
safe_meta(call(2,*,*)).
safe_meta(call(3,*,*,*)).
safe_meta(call(4,*,*,*,*)).
safe_meta(call(5,*,*,*,*,*)).
safe_meta(call(6,*,*,*,*,*,*)).
safe_meta(call(7,*,*,*,*,*,*,*)).
safe_meta(once(0)).
safe_meta(ignore(0)).
safe_meta(forall(0,0)).
safe_meta(if(0,0,0)).
safe_meta(catch(0,*,0)).
safe_meta(findall(*,0,*)).
safe_meta(findall(*,0,*,*)).
safe_meta(findnsols(*,*,0,*)).
safe_meta(setof(*,^,*)).
safe_meta(bagof(*,^,*)).
safe_meta(^(*,0)).
safe_meta(countall(0,*)).
safe_meta(call_nth(0,*)).
safe_meta(call_det(0,*)).
safe_meta(limit(*,0)).
safe_meta(offset(*,0)).
safe_meta(call_cleanup(0,0)).
safe_meta(setup_call_cleanup(0,0,0)).
safe_meta(call_residue_vars(0,*)).
safe_meta(call_with_inference_limit(0,*,*)).
safe_meta(call_with_time_limit(*,0)).
safe_meta(time_out(0,*,*)).

% safe_output(+Output): with_output_to/2 and format/3 may write to these,
% not to a stream.

safe_output(Output) :-
	var(Output),
	!,
	instantiation_error(Output).
safe_output(atom(_)).
safe_output(string(_)).
safe_output(codes(_)).
safe_output(codes(_,_)).
safe_output(chars(_)).
safe_output(chars(_,_)).

% format_calls(+Format, +FormatArgs, -Calls): the goals of Format's ~@.

format_calls(Format, Args, Calls) :-
	is_list(Args),
	!,
	format_types(Format, Types),
	(	format_callables(Types, Args, Calls)
	->	true
	;	throw(error(format_error(Format, Types, Args), _))
	).
format_calls(Format, Arg, Calls) :-
	format_calls(Format, [Arg], Calls).

format_callables([], [], []).
format_callables([callable|TT], [G|TA], [G|TG]) :-
	!,
	format_callables(TT, TA, TG).
format_callables([_|TT], [_|TA], TG) :-
	format_callables(TT, TA, TG).

% safe_prolog_flag(+Flag, +Value): setting Flag to Value is safe.

safe_prolog_flag(occurs_check, _).
safe_prolog_flag(double_quotes, _).
safe_prolog_flag(back_quotes, _).
