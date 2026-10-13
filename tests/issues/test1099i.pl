:- initialization(main).
:- set_prolog_flag(strict_iso, true).

% Stage 3 of #1099, concluded: s#351..s#382 of UWN's ISO syntax
% conformity suite, as test1099h.pl does s#301..s#350. A row starting
% /**/ stands for the last row before it without one followed by its own
% text, so the operators that row sets up are set up here around it.

% How writeq/1 names a variable is left open (s#376): _ and a name.

var_name([C|Cs]) --> [C], { C == '_' }, name_chars(Cs).

name_chars([C|Cs]) --> [C], { char_code(C, X), ( X >= 0'0, X =< 0'9 ; X >= 0'A, X =< 0'Z ; X >= 0'a, X =< 0'z ; X =:= 0'_ ) }, !, name_chars(Cs).
name_chars([]) --> [].

var_only --> var_name(_).

% s#351..s#362: priority 1000 in a list element, and brackets that do not
% close; where the page writes -1'$VAR' it counts -1 '$VAR' as good too

?- read(G_0), G_0.
   inputs("writeq(-{}1)."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xfx,~>)).
   inputs("op(1000,xfx,~>). writeq([a~>b])."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,yfx,~>)).
   inputs("op(1000,yfx,~>). writeq([a~>b])."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xfy,~>)).
   inputs("op(1000,xfy,~>). writeq([a~>b])."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(op(9,xf,'$VAR'), (read(G_0), G_0), op(0,xf,'$VAR')).
   inputs("/**/ writeq('$VAR'(-1))."), peeks("\n"), outputs("-1 '$VAR'"), G_0 = writeq('$VAR'(-1)).

?- read(G_0), G_0.
   inputs("writeq({|})."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(([))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(((>)(1))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq({a:-b})."), peeks("\n"), outputs("{a:-b}"), G_0 = writeq({a:-b}).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(1105,xfy,'|')).
   inputs("op(1105,xfy,'|').\nwriteq((|))."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(1105,xfy,'|')).
   inputs("op(0,xfy,'|').\nwriteq((|))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(\\(!;!))."), peeks("\n"), syntax_error(...).

% s#363..s#367: numbers, and $; the page's 0.0 for s#364 is an example

?- read(G_0), G_0.
   inputs("writeq(010)."), peeks("\n"), outputs("10"), G_0 = writeq(10).

?- read(G_0), G_0.
   inputs("writeq(-0.0)."), peeks("\n"), outputs("0.0"), G_0 = writeq(0.0).

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,fy,'$')).
   inputs("op(0,fy,$)."), peeks("\n"), G_0 = op(0,fy,'$').

?- setup_call_cleanup(op(0,fy,'$'), (read(G_0), G_0), op(0,fy,'$')).
   inputs("/**/ writeq($ab)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(0'. )."), peeks("\n"), outputs("46"), G_0 = writeq(46).

% s#368..s#382: graphic atoms, unclosed brackets, variables, and the
% canonical form of a list

?- read(G_0), G_0.
   inputs("writeq(?)."), peeks("\n"), outputs("?"), G_0 = writeq(?).

?- read(G_0), G_0.
   inputs("writeq(?-)."), peeks("\n"), outputs("?-"), G_0 = writeq(?-).

?- read(G_0), G_0.
   inputs("writeq(./*)."), peeks("\n"), outputs("./*"), G_0 = writeq('./*').

?- read(G_0), G_0.
   inputs("writeq({*})."), peeks("\n"), outputs("{*}"), G_0 = writeq({*}).

?- read(G_0), G_0.
   inputs("writeq(.*)."), peeks("\n"), outputs(".*"), G_0 = writeq('.*').

?- read(G_0), G_0.
   inputs("writeq(...*)."), peeks("\n"), outputs("...*"), G_0 = writeq('...*').

?- read(G_0), G_0.
   inputs("[.\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("{.\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(E)."), peeks("\n"), outputs(user:var_only), G_0 = writeq(_A).

?- read(G_0), G_0.
   inputs("write_term(., [ignore_ops(true)])."), peeks("\n"), outputs("."), G_0 = write_term('.', [ignore_ops(true)]).

?- read(G_0), G_0.
   inputs("writeq(--> /2)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq((-->)/2)."), peeks("\n"), outputs("(-->)/2"), G_0 = writeq((-->)/2).

?- read(G_0), G_0.
   inputs("write_term([' '], [ignore_ops(true)])."), peeks("\n"), outputs(".( ,[])"), G_0 = write_term([' '], [ignore_ops(true)]).

?- read(G_0), G_0.
   inputs("writeq([','])."), peeks("\n"), outputs("[',']"), G_0 = writeq([',']).

?- read(G_0), G_0.
   inputs("Finis ()."), peeks("\n"), syntax_error(...).

main :-
	use_module(library(quads)),
	run_quads.
