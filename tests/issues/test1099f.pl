:- initialization(main).
:- set_prolog_flag(strict_iso, true).

% Stage 3 of #1099, continued: s#201..s#250 of UWN's ISO syntax
% conformity suite, as test1099e.pl does s#151..s#200. A row starting
% /**/ stands for the last row before it without one followed by its own
% text, so the operators or flags that row sets up are set up here
% around it.

% How write_canonical/1 names a variable is left open, so s#226 and
% s#227 describe the output by grammar: _ and a name, different names
% for different variables and the same name for the same one.

var_name([C|Cs]) --> [C], { C == '_' }, name_chars(Cs).

name_chars([C|Cs]) --> [C], { char_code(C, X), ( X >= 0'0, X =< 0'9 ; X >= 0'A, X =< 0'Z ; X >= 0'a, X =< 0'z ; X =:= 0'_ ) }, !, name_chars(Cs).
name_chars([]) --> [].

distinct_vars --> "+(", var_name(A), ",", var_name(B), ")", { A \== B }.
same_var --> "+(", var_name(A), ",", var_name(A), ")".

% s#201..s#205: rows after earlier operator declarations; the page's
% f f 0 and 1 e are examples

?- setup_call_cleanup((op(9,fy,f), op(9,yf,f)), (read(G_0), G_0), (op(0,fy,f), op(0,yf,f))).
   inputs("/**/ writeq(f(f(0)))."), peeks("\n"), outputs("f f 0"), G_0 = writeq(f(f(0))).

?- setup_call_cleanup((op(9,fy,f), op(9,yf,f)), (read(G_0), G_0), (op(0,fy,f), op(0,yf,f))).
   inputs("/**/ write_canonical(f 0 f)."), peeks("\n"), outputs("f(f(0))"), G_0 = write_canonical(f(f(0))).

?- read(G_0), G_0.
   inputs("writeq(//*)."), peeks("\n"), outputs("//*"), G_0 = writeq('//*').

?- setup_call_cleanup(op(9,xf,e), (read(G_0), G_0), op(0,xf,e)).
   inputs("/**/ writeq(1e)."), peeks("\n"), outputs("1 e"), G_0 = writeq(e(1)).

?- setup_call_cleanup(op(100,xf,''), (read(G_0), G_0), op(0,xf,'')).
   inputs("/**/ (0 '') = ''(X)."), peeks("\n"), G_0 = (''(0) = ''(0)).

% s#206..s#214: 0' and quoted operators, and continuation escapes; s#210
% and s#211 differ only after where the reader stops

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xf,f)).
   inputs("op(100,xf,f).\nwriteq(0'f').\n"), syntax_error(...).

?- setup_call_cleanup(op(100,xf,f), (read(G_0), G_0), op(0,xf,f)).
   inputs("/**/ writeq(0'f'f')."), peeks("\n"), outputs("102 f"), G_0 = writeq(f(102)).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xf,'f ')).
   inputs("op(100,xf,'f ').\nwriteq(0 'f ')."), peeks("\n"), outputs("0 'f '"), G_0 = op(100,xf,'f '), G_1 = writeq('f '(0)).

?- setup_call_cleanup(op(100,xf,f), (read(G_0), G_0), op(0,xf,f)).
   inputs("/**/ writeq(0'ff)."), peeks("\n"), outputs("102 f"), G_0 = writeq(f(102)).

?- read(G_0), G_0.
   inputs("X = 0'\\"), peeks("."), syntax_error(...).

?- read(G_0), G_0.
   inputs("X = 0'\\"), peeks("."), syntax_error(...).

?- read(G_0), G_0.
   inputs("X is 1'\\\n+'1."), peeks("\n"), G_0 = (2 is 1+1).

?- read(G_0), G_0.
   inputs("X is 0'\\\n+'1."), peeks("\n"), G_0 = (1 is 0+1).

?- read(G_0), G_0.
   inputs("X is 0'\\\n"), waits.

% s#215..s#223: prefix minus and operator atoms as operands

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,yfx,~)).
   inputs("op(100,yfx,~).\nwriteq(-(1~2~3))."), peeks("\n"), outputs("- (1~2~3)"), G_0 = op(100,yfx,~), G_1 = writeq(-('~'('~'(1,2),3))).

?- read(G_0), G_0.
   inputs("writeq(-(-(1)))."), peeks("\n"), outputs("- - (1)"), G_0 = writeq(-(-(1))).

?- read(G_0), G_0.
   inputs("op(1105,xfy,'|')."), peeks("\n"), G_0 = op(1105,xfy,'|').

?- read(G_0), G_0.
   inputs("writeq(-(1*2))."), peeks("\n"), outputs("- (1*2)"), G_0 = writeq(-(1*2)).

?- setup_call_cleanup(op(0,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ [a|[]]=[a]."), peeks("\n"), G_0 = ([a] = [a]).

?- setup_call_cleanup(op(9,xf,e), (read(G_0), G_0), op(0,xf,e)).
   inputs("/**/ writeq(1.0e)."), peeks("\n"), outputs("1.0 e"), G_0 = writeq(e(1.0)).

?- setup_call_cleanup(op(100,xfy,'.'), (read(G_0), G_0), op(0,xfy,'.')).
   inputs("/**/ X = 1.e."), peeks("\n"), G_0 = ([1|e] = [1|e]).

?- read(G_0), G_0.
   inputs("writeq((-)-(-))."), peeks("\n"), outputs("(-)-(-)"), G_0 = writeq((-)-(-)).

?- read(G_0), G_0.
   inputs("writeq(((:-):-(:-)))."), peeks("\n"), outputs("(:-):-(:-)"), G_0 = writeq(((:-):-(:-))).

% s#224..s#227: \ as a goal, the NUL character, whose '\x0\' the page
% counts as good, and variables

?- read(G_0), G_0.
   inputs("\\ ."), peeks("\n"), existence_error(procedure,(\)/0).

?- read(G_0), G_0.
   inputs("char_code(C,0), writeq(C)."), peeks("\n"), outputs("'\\x0\\'"), G_0 = (char_code('\x0\',0), writeq('\x0\')).

?- read(G_0), G_0.
   inputs("write_canonical(_+_)."), peeks("\n"), outputs(user:distinct_vars), G_0 = write_canonical(_A+_B).

?- read(G_0), G_0.
   inputs("write_canonical(B+B)."), peeks("\n"), outputs(user:same_var), G_0 = write_canonical(_A+_A).

% s#228..s#233: escapes that do not exist, and a name before a bracket

?- read(G_0), G_0.
   inputs("writeq(0'\\"), peeks("z"), syntax_error(...).

?- setup_call_cleanup(set_prolog_flag(double_quotes,chars), (read(G_0), G_0), set_prolog_flag(double_quotes,chars)).
   inputs("/**/ writeq(\"\\z\").\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("char_code('\\^',X).\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(0'\\"), peeks("c"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(0'\\"), peeks(" "), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(nop (1))."), peeks("\n"), syntax_error(...).

% s#234, s#235: a comment between a name and ( is layout, so f below is
% a prefix operator and not functional notation

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,fx,f)).
   inputs("op(400,fx,f).\nwriteq(f/*.*/(1,2))."), peeks("\n"), outputs("f (1,2)"), G_0 = op(400,fx,f), G_1 = writeq(f((1,2))).

?- setup_call_cleanup(op(400,fx,f), (read(G_0), G_0), op(0,fx,f)).
   inputs("/**/ writeq(1 = f)."), peeks("\n"), syntax_error(...).

% s#236..s#243: > cannot also be postfix, since it is infix, so s#237
% fails and the rows after it run with > as it was

?- read(G_0), G_0.
   inputs("write_canonical(a- - -b)."), peeks("\n"), outputs("-(a,-(-(b)))"), G_0 = write_canonical(-(a,-(-(b)))).

?- read(G_0), G_0.
   inputs("op(699,xf,>)."), peeks("\n"), permission_error(create,operator,>).

?- read(G_0), G_0.
   inputs("/**/ writeq(>(>(a),b))."), peeks("\n"), outputs(">(a)>b"), G_0 = writeq('>'('>'(a),b)).

?- read(G_0), G_0.
   inputs("/**/ write_canonical(a> >b)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("/**/ write_canonical(a>)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq('\\d').\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("/**/ write_canonical(a> =b)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("/**/ write_canonical((a>,b))."), peeks("\n"), syntax_error(...).

% s#244..s#250: '$VAR' under writeq, low-priority infix operators after a
% prefix minus, and the NUL character again

?- read(G_0), G_0.
   inputs("writeq('$VAR'(0))."), peeks("\n"), outputs("A"), G_0 = writeq('$VAR'(0)).

?- read(G_0), G_0.
   inputs("writeq('$VAR'(-1))."), peeks("\n"), outputs("'$VAR'(-1)"), G_0 = writeq('$VAR'(-1)).

?- read(G_0), G_0.
   inputs("writeq('$VAR'(-2))."), peeks("\n"), outputs("'$VAR'(-2)"), G_0 = writeq('$VAR'(-2)).

?- read(G_0), G_0.
   inputs("writeq('$VAR'(x))."), peeks("\n"), outputs("'$VAR'(x)"), G_0 = writeq('$VAR'(x)).

?- setup_call_cleanup(op(100,yfx,~), (read(G_0), G_0), op(0,yfx,~)).
   inputs("/**/ writeq(- (1~2))."), peeks("\n"), outputs("- (1~2)"), G_0 = writeq(-('~'(1,2))).

?- setup_call_cleanup(op(100,yfx,~), (read(G_0), G_0), op(0,yfx,~)).
   inputs("/**/ writeq(1~2)."), peeks("\n"), outputs("1~2"), G_0 = writeq('~'(1,2)).

?- read(G_0), G_0.
   inputs("writeq('\\0\\')."), peeks("\n"), outputs("'\\x0\\'"), G_0 = writeq('\x0\').

main :-
	use_module(library(quads)),
	run_quads.
