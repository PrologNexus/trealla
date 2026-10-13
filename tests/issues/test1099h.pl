:- initialization(main).
:- set_prolog_flag(strict_iso, true).

% Stage 3 of #1099, continued: s#301..s#350 of UWN's ISO syntax
% conformity suite, as test1099g.pl does s#251..s#300. A row starting
% /**/ stands for the last row before it without one followed by its own
% text, so the operators that row sets up are set up here around it.

% How writeq/1 names a variable is left open (s#332): _ and a name.

var_name([C|Cs]) --> [C], { C == '_' }, name_chars(Cs).

name_chars([C|Cs]) --> [C], { char_code(C, X), ( X >= 0'0, X =< 0'9 ; X >= 0'A, X =< 0'Z ; X >= 0'a, X =< 0'z ; X =:= 0'_ ) }, !, name_chars(Cs).
name_chars([]) --> [].

is_var_output --> "1 is ", var_name(_).

% s#301..s#316: escapes, bracketed prefix operands, layout in lists and
% curly terms; the page's '\0\' for s#301 is an example

?- read(G_0), G_0.
   inputs("writeq('\\0\\')."), peeks("\n"), outputs("'\\x0\\'"), G_0 = writeq('\x0\').

?- read(G_0), G_0.
   inputs("[] = '[]'."), peeks("\n"), G_0 = ([] = []).

?- read(G_0), G_0.
   inputs("X = 0'\\\na.\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,fy,~)).
   inputs("op(300,fy,~). writeq(~ (a=b))."), peeks("\n"), outputs("~ (a=b)"), G_0 = op(300,fy,~), G_1 = writeq(~(a=b)).

?- read(G_0), G_0.
   inputs("writeq(\\ (a=b))."), peeks("\n"), outputs("\\ (a=b)"), G_0 = writeq(\(a=b)).

?- read(G_0), G_0.
   inputs("writeq(+ (a=b))."), peeks("\n"), outputs("+ (a=b)"), G_0 = writeq(+(a=b)).

?- read(G_0), G_0.
   inputs("writeq([/*.*/])."), peeks("\n"), outputs("[]"), G_0 = writeq([]).

?- read(G_0), G_0.
   inputs("writeq(.+)."), peeks("\n"), outputs(".+"), G_0 = writeq('.+').

?- read(G_0), G_0.
   inputs("writeq({a,b})."), peeks("\n"), outputs("{a,b}"), G_0 = writeq({a,b}).

?- read(G_0), G_0.
   inputs("writeq({\\+ (})."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(\\+ (())."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq('\\u0021').\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("put_code(0'\\"), peeks("u"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(\"\\u0021\").\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq('\\x21\\')."), peeks("\n"), outputs("!"), G_0 = writeq(!).

?- read(G_0), G_0.
   inputs("writeq('\\x0021\\')."), peeks("\n"), outputs("!"), G_0 = writeq(!).

% s#317..s#332

?- setup_call_cleanup(op(1105,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ writeq([a,(b,c)|[]])."), peeks("\n"), outputs("[a,(b,c)]"), G_0 = writeq([a,(b,c)]).

?- read(G_0), G_0.
   inputs("writeq(+((1*2)^3))."), peeks("\n"), outputs("+ (1*2)^3"), G_0 = writeq(+((1*2)^3)).

?- setup_call_cleanup((op(9,fy,fy), op(9,yf,yf)), (read(G_0), G_0), (op(0,fy,fy), op(0,yf,yf))).
   inputs("/**/ writeq(yf(fy(yf(fy(1)))))."), peeks("\n"), outputs("(fy (fy 1)yf)yf"), G_0 = writeq(yf(fy(yf(fy(1))))).

?- read(G_0), G_0.
   inputs("writeq([a|\\+2])."), peeks("\n"), outputs("[a|\\+2]"), G_0 = writeq([a|\+(2)]).

?- read(G_0), G_0.
   inputs("writeq((a)(b))."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(op(1105,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ write_canonical((a|b;c))."), peeks("\n"), outputs("'|'(a,;(b,c))"), G_0 = write_canonical('|'(a,(b;c))).

?- setup_call_cleanup(op(1105,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ write_canonical((a;b|c))."), peeks("\n"), outputs("'|'(;(a,b),c)"), G_0 = write_canonical('|'((a;b),c)).

?- read(G_0), G_0.
   inputs("writeq('%')."), peeks("\n"), outputs("'%'"), G_0 = writeq('%').

?- read(G_0), G_0.
   inputs("writeq({[y}])."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("(>)(1,2)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(-((1*2)^3))."), peeks("\n"), outputs("- ((1*2)^3)"), G_0 = writeq(-((1*2)^3)).

?- setup_call_cleanup(op(0,fy,-), (read(G_0), G_0), op(200,fy,-)).
   inputs("/**/ writeq([-])."), peeks("\n"), outputs("[-]"), G_0 = writeq([-]).

?- read(G_0), G_0.
   inputs("write_canonical(;(a))."), peeks("\n"), outputs(";(a)"), G_0 = write_canonical(;(a)).

?- read(G_0), G_0.
   inputs("write_canonical(';'(a))."), peeks("\n"), outputs(";(a)"), G_0 = write_canonical(;(a)).

?- read(G_0), G_0.
   inputs("write_canonical(;(a,b))."), peeks("\n"), outputs(";(a,b)"), G_0 = write_canonical((a;b)).

?- read(G_0), G_0.
   inputs("writeq(1 is _)."), peeks("\n"), outputs(user:is_var_output), G_0 = writeq(1 is _A).

% s#333..s#339: . and .> as operators

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,fx,'.')).
   inputs("op(9,fx,.),writeq(.(' '))."), peeks("\n"), outputs("'.' ' '"), G_0 = (op(9,fx,'.'),writeq('.'(' '))).

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,yf,'.>')).
   inputs("op(9,yf,.>)."), peeks("\n"), G_0 = op(9,yf,'.>').

?- setup_call_cleanup(op(9,yf,'.>'), (read(G_0), G_0), op(0,yf,'.>')).
   inputs("/**/ write_canonical(a.> .>)."), peeks("\n"), outputs(".>(.>(a))"), G_0 = write_canonical('.>'('.>'(a))).

?- setup_call_cleanup(op(9,yf,'.>'), (read(G_0), G_0), op(0,yf,'.>')).
   inputs("/**/ writeq(((a).>).>)."), peeks("\n"), outputs("a.> .>"), G_0 = writeq('.>'('.>'(a))).

?- read(G_0), G_0.
   inputs("writeq([.|1])."), peeks("\n"), outputs("['.'|1]"), G_0 = writeq(['.'|1]).

?- read(G_0), G_0.
   inputs("writeq(-'-'2)."), peeks("\n"), outputs("- -2"), G_0 = writeq(-(-2)).

?- read(G_0), G_0.
   inputs("writeq(0'\\x\\"), peeks(")"), syntax_error(...).

% s#340..s#346: >. as a postfix operator; s#346 runs after s#237, which
% fails, so > is as it was

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,xf,'>.')).
   inputs("op(699,xf,>.)."), peeks("\n"), G_0 = op(699,xf,'>.').

?- setup_call_cleanup(op(699,xf,'>.'), (read(G_0), G_0), op(0,xf,'>.')).
   inputs("/**/ writeq(>(>.(a),b))."), peeks("\n"), outputs("a>. >b"), G_0 = writeq('>'('>.'(a),b)).

?- setup_call_cleanup(op(699,xf,'>.'), (read(G_0), G_0), op(0,xf,'>.')).
   inputs("/**/ write_canonical(a>. >b)."), peeks("\n"), outputs(">(>.(a),b)"), G_0 = write_canonical('>'('>.'(a),b)).

?- setup_call_cleanup(op(699,xf,'>.'), (read(G_0), G_0), op(0,xf,'>.')).
   inputs("/**/ write_canonical(a>. =b)."), peeks("\n"), outputs("=(>.(a),b)"), G_0 = write_canonical('>.'(a) = b).

?- setup_call_cleanup(op(699,xf,'>.'), (read(G_0), G_0), op(0,xf,'>.')).
   inputs("/**/ write_canonical((a>.,b))."), peeks("\n"), outputs("','(>.(a),b)"), G_0 = write_canonical(('>.'(a),b)).

?- setup_call_cleanup(op(699,xf,'>.'), (read(G_0), G_0), op(0,xf,'>.')).
   inputs("/**/ write_canonical(a>.)."), peeks("\n"), outputs(">.(a)"), G_0 = write_canonical('>.'(a)).

?- read(G_0), G_0.
   inputs("/**/ write_canonical(a>b)."), peeks("\n"), outputs(">(a,b)"), G_0 = write_canonical(a>b).

% s#347..s#350

?- read(G_0), G_0.
   inputs("op(100,fx,',')."), peeks("\n"), permission_error(modify,operator,',').

?- setup_call_cleanup(op(1105,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ write_canonical([a;b|c])."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("write_canonical((-,(1)))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(-[]1)."), peeks("\n"), syntax_error(...).

main :-
	use_module(library(quads)),
	run_quads.
