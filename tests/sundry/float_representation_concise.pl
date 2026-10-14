% float_representation_concise, on by default, writes 1.0e15 and 1.0e-5; off gives %g's 1.0e+15 and 1.0e-05.

:- set_prolog_flag(float_representation_concise, false).

:- initialization(main).

main :-
	L = [1.23e20, 1.0e-5, 1.0e15, 100.0, 5.0e-324, -1.5e-7],
	current_prolog_flag(float_representation_concise, F0), writeq(F0-L), nl,
	set_prolog_flag(float_representation_concise, true),
	current_prolog_flag(float_representation_concise, F1), writeq(F1-L), nl,
	format("~w ~q ~e ~g~n", [1.0e100, 1.0e100, 1.0e100, 1.0e100]),
	findall(V, current_prolog_flag(float_representation_concise, V), Vs), writeq(Vs), nl,
	catch(set_prolog_flag(float_representation_concise, maybe), E, true), writeq(E), nl.
