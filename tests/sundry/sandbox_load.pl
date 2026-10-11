% safe_load/2,3 loads untrusted source into a module, refusing clauses for
% other modules or system predicates and the directives SWI's sandboxed
% loading refuses, guarding clause bodies and checking them once loaded
% (trealla-port FR-007).

:- use_module(library(sandbox)).
:- initialization(main).

l(Text) :-
	catch(
		(	in_temporary_module(M, true,
				user:(	safe_load(M, string(Text)),
						findall(N/A, (current_predicate(M:N/A), N \== term_expansion, N \== goal_expansion), Ps0),
						msort(Ps0, Ps)
					)),
			R = ok(Ps)
		),
		error(E, _), R = E),
	\+ \+ (numbervars(R, 0, _), writeq(R)),
	nl.

main :-
	l("p(1). p(2). q(X) :- p(X), X > 1."),
	l(":- dynamic(counter/1). inc :- retract(counter(N)), N1 is N+1, assertz(counter(N1)). counter(0)."),
	l("run(G) :- call(G). go :- run(true)."),
	l("evil :- shell(ls)."),
	l(":- shell(ls)."),
	l(":- initialization(shell(ls))."),
	l(":- initialization(writeln(hello_from_init)). p."),
	l(":- dynamic(user:secret/1)."),
	l(":- multifile(sandbox:safe_primitive/1)."),
	l("sandbox:safe_primitive(shell(_))."),
	l("user:term_expansion(a, b)."),
	l("term_expansion(X, Y) :- shell(ls), Y = X."),
	l("atom_length(a, 1)."),
	l(":- op(700, xfx, ~~>). a ~~> b."),
	l(":- op(0, xfx, =). p :- '='(X, 1), X == 1."),
	( read_term_from_atom('a = b', _, []) -> writeln(user_eq_ok) ; true ),
	l(":- set_prolog_flag(double_quotes, atom). s(\"abc\")."),
	l(":- set_prolog_flag(verbose, normal)."),
	l(":- use_module(library('../etc/passwd'))."),
	l(":- use_module('/etc/passwd')."),
	l(":- include(foo)."),
	l(":- module(m, [])."),
	l("g --> [a], g. g --> []."),
	l("p :- q(."),
	safe_load(act, string("run(G) :- call(G).")),
	catch((safe_call(act:run(true)), writeln(run_true_ok)), _, true),
	catch(safe_call(act:run(shell(ls))), error(E1, _), (\+ \+ (numbervars(E1, 0, _), writeq(E1)), nl)),
	catch(act:run(shell(ls)), error(E2, _), (\+ \+ (numbervars(E2, 0, _), writeq(direct(E2))), nl)),
	open_string("p(1). p(2).", S), safe_load(act2, stream(S)), close(S),
	findall(X, act2:p(X), L), writeq(L), nl,
	safe_load(act3, terms([(q(X1) :- X1 > 0), (:- dynamic(r/1))])),
	( predicate_property(act3:r(_), dynamic), act3:q(1) -> writeln(terms_ok) ; true ),
	catch(safe_load(act4, file(x)), error(E4, _), (writeq(E4), nl)),
	safe_load(act5, string("p :- shell(ls)."), [check(false)]), writeln(check_false_loaded).
