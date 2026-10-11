% name/2 and atom_to_term/3 as SWI has them, and smaller fixes: msort/2
% isn't ISO, format/2 has its recorded properties, a module's declared but
% empty expansion hooks aren't listed by current_predicate/1.

:- initialization(main).

t(G) :- catch((G -> R = G ; R = failed), error(E, _), R = E), \+ \+ (numbervars(R, 0, _), writeq(R)), nl.

main :-
	atom_chars(T1, "12"), atom_chars(T2, " 12"), atom_chars(T3, "0x1A"), atom_chars(T4, "- 3"),
	atom_codes(T1, C1), atom_codes(T2, C2), atom_codes(T3, C3), atom_codes(T4, C4),
	t(name(_, C1)), t(name(_, C2)), t(name(_, C3)), t(name(_, C4)), t(name(_, [])), t(name(_, [a,b])),
	t(name(foo, _)), t(name(12, _)), t(name(1.5, _)), t(name(f(x), _)), t(name(_, _)),
	t(atom_to_term('foo(X, Y, X)', _, _)), t(atom_to_term(' foo ', _, _)), t(atom_to_term(12, _, _)),
	t(atom_to_term('a. b', _, _)), t(atom_to_term(f(x), _, _)), t(atom_to_term('', _, _)), t(atom_to_term(_, f(x), _)),
	t(predicate_property(msort(_,_), iso)),
	t(predicate_property(format(_,_), built_in)),
	findall(P, predicate_property(format(_,_), P), Ps), ( memberchk(built_in, Ps) -> writeln(format_enumerates_built_in) ; writeln(no) ),
	assertz(natm:x), findall(N/A, current_predicate(natm:N/A), L), writeq(L), nl,
	assertz(natm:term_expansion(a, b)), findall(N2/A2, current_predicate(natm:N2/A2), L2), msort(L2, L3), writeq(L3), nl.
