:- module(prolog_format, [format_spec/2, format_types/2]).
:- use_module(library(lists)).

% SWI's library(prolog_format): what a format string asks of its arguments,
% eg. for checking a call to format/2 before it runs.

format_spec(Format, Spec) :-
	format_codes(Format, Cs),
	spec(Cs, Spec).

format_types(Format, Types) :-
	format_spec(Format, Spec),
	spec_types(Spec, Types).

format_codes(Format, Cs) :-
	(	is_list(Format), Format = [C|_], atom(C) -> atom_chars(A, Format), atom_codes(A, Cs)
	;	is_list(Format) -> Cs = Format
	;	atom_codes(Format, Cs)
	).

spec([], []).
spec([0'~|Cs0], [escape(N,M,A)|Spec]) :- !,
	numeric(Cs0, N, Cs1),
	modifier(Cs1, M, Cs2),
	Cs2 = [C|Cs3],
	char_code(A, C),
	(	action_types(C, _) -> true
	;	throw(error(existence_error(format_character, A), format_spec/2))
	),
	spec(Cs3, Spec).
spec(Cs0, [text(S)|Spec]) :-
	text(Cs0, T, Cs1),
	string_codes(S, T),
	spec(Cs1, Spec).

text([], [], []).
text([0'~|Cs], [], [0'~|Cs]) :- !.
text([C|Cs0], [C|T], Cs) :- text(Cs0, T, Cs).

numeric([0'`,C|Cs], character(C), Cs) :- !.
numeric([0'*|Cs], star, Cs) :- !.
numeric([D|Cs0], number(N), Cs) :-
	D >= 0'0, D =< 0'9, !,
	digits(Cs0, Ds, Cs),
	number_codes(N, [D|Ds]).
numeric(Cs, nothing, Cs).

digits([D|Cs0], [D|Ds], Cs) :- D >= 0'0, D =< 0'9, !, digits(Cs0, Ds, Cs).
digits(Cs, [], Cs).

modifier([0':|Cs], colon, Cs) :- !.
modifier(Cs, no_colon, Cs).

spec_types([], []).
spec_types([text(_)|Spec], Types) :-
	spec_types(Spec, Types).
spec_types([escape(N,_,A)|Spec], Types) :-
	( N == star -> Types = [number|Types1] ; Types = Types1 ),
	char_code(A, C),
	action_types(C, Ts),
	append(Ts, Types2, Types1),
	spec_types(Spec, Types2).

action_types(0'~, []).
action_types(0'a, [atom]).
action_types(0'c, [integer]).
action_types(0'd, [integer]).
action_types(0'D, [integer]).
action_types(0'e, [float]).
action_types(0'E, [float]).
action_types(0'f, [float]).
action_types(0'g, [float]).
action_types(0'G, [float]).
action_types(0'i, [any]).
action_types(0'I, [integer]).
action_types(0'k, [any]).
action_types(0'n, []).
action_types(0'N, []).
action_types(0'p, [any]).
action_types(0'q, [any]).
action_types(0'r, [integer]).
action_types(0'R, [integer]).
action_types(0's, [text]).
action_types(0'@, [callable]).
action_types(0't, []).
action_types(0'|, []).
action_types(0'+, []).
action_types(0'w, [any]).
action_types(0'W, [any, list]).
