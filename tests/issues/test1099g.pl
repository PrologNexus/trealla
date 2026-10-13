:- initialization(main).
:- set_prolog_flag(strict_iso, true).

% Stage 3 of #1099, continued: s#251..s#300 of UWN's ISO syntax
% conformity suite, as test1099f.pl does s#201..s#250. s#270 and s#271
% are in test1099.pl, and there is no s#273. A row starting /**/ stands
% for the last row before it without one followed by its own text, so
% the operators or flags that row sets up are set up here around it.
% Where the page grades a different layout as good too, such as - [1]
% for -[1], Trealla's is described.

% s#251..s#256: operators whose names start like a radix prefix

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,yfx,[bop,bo,b,op,xor])).
   inputs("op(9,yfx,[bop,bo,b,op,xor]).\nwriteq(0bop 2)."), peeks("\n"), outputs("0 bop 2"), G_0 = op(9,yfx,[bop,bo,b,op,xor]), G_1 = writeq(bop(0,2)).

?- setup_call_cleanup(op(9,yfx,[bop,bo,b,op,xor]), (read(G_0), G_0), op(0,yfx,[bop,bo,b,op,xor])).
   inputs("/**/ writeq(0bo 2)."), peeks("\n"), outputs("0 bo 2"), G_0 = writeq(bo(0,2)).

?- setup_call_cleanup(op(9,yfx,[bop,bo,b,op,xor]), (read(G_0), G_0), op(0,yfx,[bop,bo,b,op,xor])).
   inputs("/**/ writeq(0b 2)."), peeks("\n"), outputs("0 b 2"), G_0 = writeq(b(0,2)).

?- setup_call_cleanup(op(9,yfx,[bop,bo,b,op,xor]), (read(G_0), G_0), op(0,yfx,[bop,bo,b,op,xor])).
   inputs("/**/ writeq(0op 2)."), peeks("\n"), outputs("0 op 2"), G_0 = writeq(op(0,2)).

?- setup_call_cleanup(op(9,yfx,[bop,bo,b,op,xor]), (read(G_0), G_0), op(0,yfx,[bop,bo,b,op,xor])).
   inputs("/**/ writeq(0xor 2)."), peeks("\n"), outputs("0 xor 2"), G_0 = writeq(xor(0,2)).

?- setup_call_cleanup(op(100,xf,f), (read(G_0), G_0), op(0,xf,f)).
   inputs("/**/ writeq(0f)."), peeks("\n"), outputs("0 f"), G_0 = writeq(f(0)).

% s#257..s#264

?- read(G_0), G_0.
   inputs("writeq([+{a},+[]])."), peeks("\n"), outputs("[+ {a},+ []]"), G_0 = writeq([+{a},+[]]).

?- setup_call_cleanup(op(100,xfy,'.'), (read(G_0), G_0, read(G_1), G_1), op(0,xfy,'.')).
   inputs("/**/ writeq(ok).%\n1 = X."), peeks("\n"), outputs("ok"), G_0 = writeq(ok), G_1 = (1 = 1).

?- read(G_0), G_0.
   inputs("X = 0'\\\n+'/*'. %*/1."), peeks("\n"), G_0 = (0+1 = 0+1).

?- read(G_0), G_0.
   inputs("writeq(-(a^2))."), peeks("\n"), outputs("- (a^2)"), G_0 = writeq(-(a^2)).

?- read(G_0), G_0.
   inputs(")\n'\n"), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(op(100,xfx,'1'), (read(G_0), G_0), op(0,xfx,'1')).
   inputs("/**/ functor(2 '1'y, F, A)."), peeks("\n"), G_0 = functor('1'(2,y),'1',2).

?- setup_call_cleanup(op(9,yfx,[bop,bo,b,op,xor]), (read(G_0), G_0), op(0,yfx,[bop,bo,b,op,xor])).
   inputs("/**/ writeq(0 bop 2)."), peeks("\n"), outputs("0 bop 2"), G_0 = writeq(bop(0,2)).

?- read(G_0), G_0.
   inputs("writeq('^`')."), peeks("\n"), outputs("'^`'"), G_0 = writeq('^`').

% s#265..s#269

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,yf,[b2,o8])).
   inputs("op(9,yf,[b2,o8])."), peeks("\n"), G_0 = op(9,yf,[b2,o8]).

?- setup_call_cleanup(op(9,yf,[b2,o8]), (read(G_0), G_0), op(0,yf,[b2,o8])).
   inputs("/**/ writeq(0b2)."), peeks("\n"), outputs("0 b2"), G_0 = writeq(b2(0)).

?- setup_call_cleanup(op(9,yf,[b2,o8]), (read(G_0), G_0), op(0,yf,[b2,o8])).
   inputs("/**/ writeq(0o8)."), peeks("\n"), outputs("0 o8"), G_0 = writeq(o8(0)).

?- read(G_0), G_0.
   inputs("op(500, xfy, {})."), peeks("\n"), permission_error(create,operator,{}).

?- read(G_0), G_0.
   inputs("writeq('\\b\\r\\f\\t\\n')."), peeks("\n"), outputs("'\\b\\r\\f\\t\\n'"), G_0 = writeq('\b\r\f\t\n').

% s#272..s#285

?- read(G_0), G_0.
   inputs("writeq(0B1)."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,fx,--)).
   inputs("op(20,fx,--),writeq(--(a))."), peeks("\n"), outputs("--a"), G_0 = (op(20,fx,--),writeq(--(a))).

?- setup_call_cleanup(op(20,fx,--), (read(G_0), G_0), op(0,fx,--)).
   inputs("/**/ op(0,fy,--),writeq(--(a))."), peeks("\n"), outputs("--(a)"), G_0 = (op(0,fy,--),writeq(--(a))).

?- read(G_0), G_0.
   inputs("writeq(0xamod 2)."), peeks("\n"), outputs("10 mod 2"), G_0 = writeq(10 mod 2).

?- read(G_0), G_0.
   inputs("writeq(+1^2)."), peeks("\n"), outputs("+ 1^2"), G_0 = writeq(+(1^2)).

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,xfy,'.')).
   inputs("op(9,xfy,.), writeq(-[1])."), peeks("\n"), outputs("- [1]"), G_0 = (op(9,xfy,'.'),writeq(-[1])).

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,xf,'$VAR')).
   inputs("op(9,xf,'$VAR'), writeq(- '$VAR'(0))."), peeks("\n"), outputs("- A"), G_0 = (op(9,xf,'$VAR'),writeq(-('$VAR'(0)))).

?- read(G_0), G_0.
   inputs("writeq(00'+'1)."), peeks("\n"), outputs("0+1"), G_0 = writeq(0+1).

?- read(G_0), G_0.
   inputs("writeq(00'a).\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(//*.*/)."), peeks("\n"), outputs("//*.*/"), G_0 = writeq('//*.*/').

?- setup_call_cleanup(op(100,xfy,'.'), (read(G_0), G_0), op(0,xfy,'.')).
   inputs("/**/ writeq(-[1])."), peeks("\n"), outputs("- [1]"), G_0 = writeq(-[1]).

?- read(G_0), G_0.
   inputs("writeq('\\^J').\n"), syntax_error(...).

?- setup_call_cleanup(op(0,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ X=[(a|b)]."), peeks("\n"), syntax_error(...).

% s#286..s#300

?- read(G_0), G_0.
   inputs("(- (1)) = -(1)."), peeks("\n"), G_0 = (-(1) = -(1)).

?- read(G_0), G_0.
   inputs("(- -1) = -(-1)."), peeks("\n"), G_0 = (-(-1) = -(-1)).

?- read(G_0), G_0.
   inputs("(- 1^2) = ^(-1,2)."), peeks("\n"), G_0 = (^(-1,2) = ^(-1,2)).

?- read(G_0), G_0.
   inputs("writeq('$VAR'('A'))."), peeks("\n"), outputs("'$VAR'('A')"), G_0 = writeq('$VAR'('A')).

?- setup_call_cleanup(op(1105,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ writeq([(a|b)])."), peeks("\n"), outputs("[(a|b)]"), G_0 = writeq(['|'(a,b)]).

?- read(G_0), G_0.
   inputs("writeq([(a,b)])."), peeks("\n"), outputs("[(a,b)]"), G_0 = writeq([(a,b)]).

?- read(G_0), G_0.
   inputs("writeq(1= \\\\)."), peeks("\n"), outputs("1= \\\\"), G_0 = writeq(1 = '\\\\').

?- read(G_0), G_0.
   inputs("writeq((,))."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq({[})."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq({(})."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(op(9,xf,'$VAR'), (read(G_0), G_0), op(0,xf,'$VAR')).
   inputs("/**/ writeq('$VAR'(0))."), peeks("\n"), outputs("A"), G_0 = writeq('$VAR'(0)).

?- read(G_0), G_0.
   inputs("atom(`\n"), peeks("`"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq([a,b|c])."), peeks("\n"), outputs("[a,b|c]"), G_0 = writeq([a,b|c]).

?- read(G_0), G_0.
   inputs("(\\+ (a,b)) = \\+(T)."), peeks("\n"), G_0 = (\+((a,b)) = \+((a,b))).

% s#300: the page's ['\0\'] is an example; Trealla writes NUL as \x0\

?- setup_call_cleanup(set_prolog_flag(double_quotes,chars), (read(G_0), G_0), set_prolog_flag(double_quotes,chars)).
   inputs("/**/ writeq(\"\\0\\\")."), peeks("\n"), outputs("['\\x0\\']"), G_0 = writeq(['\x0\']).

main :-
	use_module(library(quads)),
	run_quads.
