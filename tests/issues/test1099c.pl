:- initialization(main).
:- set_prolog_flag(strict_iso, true).

% Stage 3 of #1099, continued: s#51..s#100 of UWN's ISO syntax conformity
% suite, as test1099b.pl does s#5..s#50: read by read/1 from inputs/1 in
% strict_iso mode, a syntax error described with how far the reader got.
% Operators a row changes are put back afterwards. A row starting /**/
% stands for the last row before it without one followed by its own
% text, so the operators that row sets up are set up here around it.

% s#51..s#55: exponents and operators named e

?- setup_call_cleanup(op(9,xf,e), (read(G_0), G_0), op(0,xf,e)).
   inputs("/**/ 1.0e- 9 = -(e(1.0),9)."), peeks("\n"), G_0 = ('-'(e(1.0),9) = '-'(e(1.0),9)).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xfy,e)).
   inputs("op(9,xfy,e).\n1.2e 3 = e(X,Y)."), peeks("\n"), G_0 = op(9,xfy,e), G_1 = (e(1.2,3) = e(1.2,3)).

% s#53: the form of a float is left open; '1.0e+100' is the page's example

?- read(G_0), G_0.
   inputs("writeq(1.0e100)."), peeks("\n"), outputs("1.0e+100"), G_0 = writeq(1.0e100).

?- read(G_0), G_0.
   inputs("float(1.0ee9)."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,yf,yf1)).
   inputs("op(1,yf,yf1).\n{-1 yf1}={yf1(X)}."), peeks("\n"), G_0 = op(1,yf,yf1), G_1 = ({yf1(-1)} = {yf1(-1)}).

% s#56..s#64: a name token - followed by a numeric literal is a negative
% number, with layout or a comment between them but not inside a graphic
% token

?- read(G_0), G_0.
   inputs("integer(- 1)."), peeks("\n"), G_0 = integer(-1).

?- read(G_0), G_0.
   inputs("integer('-'1)."), peeks("\n"), G_0 = integer(-1).

?- read(G_0), G_0.
   inputs("integer('-' 1)."), peeks("\n"), G_0 = integer(-1).

?- read(G_0), G_0.
   inputs("integer(- /*.*/1)."), peeks("\n"), G_0 = integer(-1).

?- read(G_0), G_0.
   inputs("integer(-/*.*/1)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("integer('-'/*.*/1)."), peeks("\n"), G_0 = integer(-1).

?- read(G_0), G_0.
   inputs("atom(-/*.*/-)."), peeks("\n"), G_0 = atom('-/*.*/-').

?- setup_call_cleanup(true, (read(G_0), G_0), op(200,fy,-)).
   inputs("op(0,fy,-)."), peeks("\n"), G_0 = op(0,fy,-).

?- setup_call_cleanup(op(0,fy,-), (read(G_0), G_0), op(200,fy,-)).
   inputs("/**/ integer(- 1)."), peeks("\n"), G_0 = integer(-1).

% s#65..s#67: +1 is a compound (Cor.2), and a syntax error once + is no
% longer a prefix operator

?- read(G_0), G_0.
   inputs("compound(+1)."), peeks("\n"), G_0 = compound('+'(1)).

?- read(G_0), G_0.
   inputs("compound(+ 1)."), peeks("\n"), G_0 = compound('+'(1)).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(200,fy,+)).
   inputs("op(0,fy,+).\ncompound(+1)."), peeks("\n"), syntax_error(...).

% s#68..s#74: bars and commas

?- read(G_0), G_0.
   inputs("[(:-)|(:-)]=[:-|:-]."), peeks("\n"), G_0 = ([(:-)|(:-)] = [(:-)|(:-)]).

?- read(G_0), G_0.
   inputs("X=[a|b,c]."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("op(1000,xfy,',')."), peeks("\n"), permission_error(modify,operator,',').

% s#71: modify or create, the page allows either

?- read(G_0), G_0.
   inputs("op(1001,xfy,',')."), peeks("\n"), permission_error(modify,operator,',').

?- setup_call_cleanup(true, (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("op(0,xfy,'|'), op(999,xfy,'|')."), peeks("\n"), permission_error(create,operator,'|').

% s#73, s#74: s#72 has taken | away as an operator before it fails

?- setup_call_cleanup(op(0,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ X=[a|b]."), peeks("\n"), G_0 = ([a|b] = [a|b]).

?- setup_call_cleanup(op(0,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ X=[a|b|c]."), peeks("\n"), syntax_error(...).

% s#75..s#78: an operator as an operand needs brackets

?- read(G_0), G_0.
   inputs("var(a:-b)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs(":- = :- ."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("- = - ."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("* = * ."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("current_op(200,fy,-)."), peeks("\n"), G_0 = current_op(200,fy,'-').

?- read(G_0), G_0.
   inputs("current_op(200,fy,+)."), peeks("\n"), G_0 = current_op(200,fy,'+').

% s#81..s#94: prefix operators and operator atoms

?- read(G_0), G_0.
   inputs("{- - c}={-(-(c))}."), peeks("\n"), G_0 = ({'-'('-'(c))} = {'-'('-'(c))}).

?- read(G_0), G_0.
   inputs("(- -) = -(-)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("(- - -) = -(-(-))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("(- - - -) = -(-(-(-)))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("{:- :- c} = {:-(:-,c)}."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("{- = - 1}={(-(=)) - 1}."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("write_canonical((- = - 1))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("write_canonical((- = -1))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("write_canonical((-;))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("write_canonical((-;-))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("write_canonical((:-;-))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("[:- -c] = [(:- -c)]."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq([a,b|,])."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("X ={,}."), peeks("\n"), syntax_error(...).

% s#95..s#100: curly terms, '[]' as a functor, and quoting

?- read(G_0), G_0.
   inputs("{1} = {}(1)."), peeks("\n"), G_0 = ({1} = {1}).

?- read(G_0), G_0.
   inputs("write_canonical({1})."), peeks("\n"), outputs("{}(1)"), G_0 = write_canonical({1}).

?- read(G_0), G_0.
   inputs("'[]'(1) = [ ](X)."), peeks("\n"), G_0 = ('[]'(1) = '[]'(1)).

?- read(G_0), G_0.
   inputs("X = [] (1)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("op(100,yfy,op)."), peeks("\n"), domain_error(operator_specifier,yfy).

?- read(G_0), G_0.
   inputs("'''' = '\\''."), peeks("\n"), G_0 = ('\'' = '\'').

main :-
	use_module(library(quads)),
	run_quads.
