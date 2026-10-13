:- initialization(main).
:- set_prolog_flag(strict_iso, true).

% Stage 3 of #1099, continued: s#101..s#150 of UWN's ISO syntax
% conformity suite, as test1099c.pl does s#51..s#100. A row starting
% /**/ stands for the last row before it without one followed by its own
% text, so the operators that row sets up are set up here around it.

% s#101..s#110: octal and hex escapes; a syntax error in a quoted atom is
% caught by the end of its line

?- read(G_0), G_0.
   inputs("a = '\\141\\'."), peeks("\n"), G_0 = (a = a).

?- read(G_0), G_0.
   inputs("a = '\\141'."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("X = '\\141\\141'."), peeks("\n"), G_0 = (a141 = a141).

?- read(G_0), G_0.
   inputs("X = '\\9'.\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("X = '\\N'.\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("X = '\\\\' .\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("X = '\\77777777777\\'.\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("a = '\\x61\\'."), peeks("\n"), G_0 = (a = a).

% s#109, s#110: the page allows a syntax error or a wait

?- read(G_0), G_0.
   inputs("atom_codes('\\xG\\',Cs).\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("atom_codes('\\xG1\\',Cs).\n"), syntax_error(...).

% s#111..s#113: a back quoted string is no term

?- read(G_0), G_0.
   inputs("atom(`)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("atom(`+)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("X = `a`"), peeks("."), syntax_error(...).

% s#114..s#130: 0' and radix notation

?- read(G_0), G_0.
   inputs("integer(0'\\')."), peeks("\n"), G_0 = integer(39).

?- read(G_0), G_0.
   inputs("integer(0''')."), peeks("\n"), G_0 = integer(39).

?- read(G_0), G_0.
   inputs("0''' = 0'\\'."), peeks("\n"), G_0 = (39 = 39).

?- read(G_0), G_0.
   inputs("integer(0''"), peeks(")"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,xfx,'')).
   inputs("op(100,xfx,'')."), peeks("\n"), G_0 = op(100,xfx,'').

?- setup_call_cleanup(op(100,xfx,''), (read(G_0), G_0), op(0,xfx,'')).
   inputs("/**/ functor(0 ''1, F, A)."), peeks("\n"), G_0 = functor(''(0,1),'',2).

?- setup_call_cleanup(op(100,xfx,''), (read(G_0), G_0), op(0,xfx,'')).
   inputs("/**/ functor(0''1, F, A)."), peeks("\n"), G_0 = functor(''(0,1),'',2).

?- read(G_0), G_0.
   inputs("X = 2'1.\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xfx,'1')).
   inputs("op(100,xfx,'1').\nfunctor(2'1'y, F, A)."), peeks("\n"), G_0 = op(100,xfx,'1'), G_1 = functor('1'(2,y),'1',2).

?- read(G_0), G_0.
   inputs("X =0'\\x41\\ ."), peeks("\n"), G_0 = (65 = 65).

?- read(G_0), G_0.
   inputs("X =0'\\x41\\."), peeks("\n"), G_0 = (65 = 65).

?- read(G_0), G_0.
   inputs("X =0'\\x1\\."), peeks("\n"), G_0 = (1 = 1).

?- read(G_0), G_0.
   inputs("X = 0'\\\n.\\\n"), waits.

?- read(G_0), G_0.
   inputs("X is 16'mod'2."), peeks("\n"), G_0 = (0 is 16 mod 2).

?- read(G_0), G_0.
   inputs("X is 37'mod'2."), peeks("\n"), G_0 = (1 is 37 mod 2).

?- read(G_0), G_0.
   inputs("X is 0'mod'1.\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("X is 1'+'1."), peeks("\n"), G_0 = (2 is 1+1).

% s#131..s#134: quoted operators; the page's ' op'[] for s#133 counts
% ' op' [] as good too

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,fx,' op')).
   inputs("op(100,fx,' op')."), peeks("\n"), G_0 = op(100,fx,' op').

?- setup_call_cleanup(op(100,fx,' op'), (read(G_0), G_0), op(0,fx,' op')).
   inputs("/**/ writeq(' op' '1')."), peeks("\n"), outputs("' op' '1'"), G_0 = writeq(' op'('1')).

?- setup_call_cleanup(op(100,fx,' op'), (read(G_0), G_0), op(0,fx,' op')).
   inputs("/**/ writeq(' op'[])."), peeks("\n"), outputs("' op' []"), G_0 = writeq(' op'([])).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xf,xf1)).
   inputs("op(1,xf,xf1).\nwriteq({- =xf1})."), peeks("\n"), syntax_error(...).

% s#135..s#140: a prefix operator before a bracket

?- read(G_0), G_0.
   inputs("writeq(-(1))."), peeks("\n"), outputs("- (1)"), G_0 = writeq(-(1)).

?- setup_call_cleanup(op(0,fy,-), (read(G_0), G_0), op(200,fy,-)).
   inputs("/**/ writeq(-(1))."), peeks("\n"), outputs("-(1)"), G_0 = writeq(-(1)).

?- read(G_0), G_0.
   inputs("writeq(- (a*b))."), peeks("\n"), outputs("- (a*b)"), G_0 = writeq(-(a*b)).

?- read(G_0), G_0.
   inputs("writeq(\\ (a*b))."), peeks("\n"), outputs("\\ (a*b)"), G_0 = writeq(\(a*b)).

?- read(G_0), G_0.
   inputs("writeq(-((a,b)))."), peeks("\n"), outputs("- (a,b)"), G_0 = writeq(-((a,b))).

?- read(G_0), G_0.
   inputs("writeq(-a)."), peeks("\n"), outputs("-a"), G_0 = writeq(-a).

% s#141..s#144: . as an infix operator

?- read(G_0), G_0.
   inputs("current_op(P,xfy,.)."), peeks("\n"), false.

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,xfy,'.')).
   inputs("op(100,xfy,.)."), peeks("\n"), G_0 = op(100,xfy,'.').

?- setup_call_cleanup(op(100,xfy,'.'), (read(G_0), G_0), op(0,xfy,'.')).
   inputs("/**/ writeq(1 .2)."), peeks("\n"), outputs("[1|2]"), G_0 = writeq([1|2]).

?- setup_call_cleanup(op(100,xfy,'.'), (read(G_0), G_0), op(0,xfy,'.')).
   inputs("/**/ writeq([1])."), peeks("\n"), outputs("[1]"), G_0 = writeq([1]).

% s#145, s#146: '$VAR' is only special to numbervars(true)

?- read(G_0), G_0.
   inputs("write_canonical('$VAR'(0))."), peeks("\n"), outputs("'$VAR'(0)"), G_0 = write_canonical('$VAR'(0)).

?- read(G_0), G_0.
   inputs("write_term('$VAR'(0),[])."), peeks("\n"), outputs("$VAR(0)"), G_0 = write_term('$VAR'(0),[]).

% s#147..s#150: fy and yf of the same priority

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), (op(0,fy,fy), op(0,yf,yf))).
   inputs("op(9,fy,fy),op(9,yf,yf).\nwrite_canonical(fy 1 yf)."), peeks("\n"), outputs("fy(yf(1))"), G_0 = (op(9,fy,fy),op(9,yf,yf)), G_1 = write_canonical(fy(yf(1))).

?- setup_call_cleanup((op(9,fy,fy), op(9,yf,yf)), (read(G_0), G_0), (op(0,fy,fy), op(0,yf,yf))).
   inputs("/**/ write_canonical(fy yf)."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup((op(9,fy,fy), op(9,yf,yf)), (read(G_0), G_0), (op(0,fy,fy), op(0,yf,yf))).
   inputs("/**/ writeq(fy(yf(1)))."), peeks("\n"), outputs("fy 1 yf"), G_0 = writeq(fy(yf(1))).

?- setup_call_cleanup((op(9,fy,fy), op(9,yf,yf)), (read(G_0), G_0), (op(0,fy,fy), op(0,yf,yf))).
   inputs("/**/ writeq(yf(fy(1)))."), peeks("\n"), outputs("(fy 1)yf"), G_0 = writeq(yf(fy(1))).

main :-
	use_module(library(quads)),
	run_quads.
