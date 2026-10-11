% A module's operators are its own: an importer sees only those in its
% export list, and every module sees the user module's own and those
% exported to it, as in SWI. current_op/3 lists what the calling module
% sees.

:- initialization(main).

see(M, Op) :-
	(	M:current_op(P, T, Op) -> R = sees(P, T) ; R = none ),
	writeq(M-Op-R), nl.

parses(Text) :-
	(	catch(read_term_from_atom(Text, T, []), _, fail) -> writeq(parsed(T)) ; writeq(no_parse(Text)) ),
	nl.

main :-
	load_text(":- module(opm1, [t1/0]). :- op(700, xfx, ===>). t1 :- X = (a ===> b), X = ===>(_, _).", []),
	load_text(":- module(opm2, [t2/0, op(700, xfx, <~>)]). :- op(700, xfx, <~>). t2.", []),
	op(700, xfx, <<=>>),
	see(user, ===>), see(user, <~>), see(user, <<=>>),
	parses('a ===> b'), parses('a <~> b'),
	see(opm1, ===>), see(opm1, <~>), see(opm1, <<=>>),
	( opm1:t1 -> writeln(opm1_parsed_its_own) ; true ),
	'$create_module'(opm3), opm3:op(0, xfx, =), opm3:op(700, xfx, ~~>),
	see(opm3, =), see(user, =), see(user, ~~>),
	parses('x = y').
