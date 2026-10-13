:- initialization(main).
:- set_prolog_flag(strict_iso, true).

% Stage 3 of #1099, continued: s#151..s#200 of UWN's ISO syntax
% conformity suite, as test1099d.pl does s#101..s#150. A row starting
% /**/ stands for the last row before it without one followed by its own
% text, so the operators or flags that row sets up are set up here
% around it. Remarks the page adds after a row's end are left out.

% s#151..s#156: prefix, infix and postfix of the same priority; where
% the page writes (fy 1)yfx 2 it counts (fy 1) yfx 2 as good too

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), (op(0,fy,fy), op(0,yfx,yfx))).
   inputs("op(9,fy,fy),op(9,yfx,yfx).\nwrite_canonical(fy 1 yfx 2)."), peeks("\n"), outputs("fy(yfx(1,2))"), G_0 = (op(9,fy,fy),op(9,yfx,yfx)), G_1 = write_canonical(fy(yfx(1,2))).

?- setup_call_cleanup((op(9,fy,fy), op(9,yfx,yfx)), (read(G_0), G_0), (op(0,fy,fy), op(0,yfx,yfx))).
   inputs("/**/ writeq(fy(yfx(1,2)))."), peeks("\n"), outputs("fy 1 yfx 2"), G_0 = writeq(fy(yfx(1,2))).

?- setup_call_cleanup((op(9,fy,fy), op(9,yfx,yfx)), (read(G_0), G_0), (op(0,fy,fy), op(0,yfx,yfx))).
   inputs("/**/ writeq(yfx(fy(1),2))."), peeks("\n"), outputs("(fy 1) yfx 2"), G_0 = writeq(yfx(fy(1),2)).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), (op(0,yf,yf), op(0,xfy,xfy))).
   inputs("op(9,yf,yf),op(9,xfy,xfy).\nwrite_canonical(1 xfy 2 yf)."), peeks("\n"), outputs("xfy(1,yf(2))"), G_0 = (op(9,yf,yf),op(9,xfy,xfy)), G_1 = write_canonical(xfy(1,yf(2))).

?- setup_call_cleanup((op(9,yf,yf), op(9,xfy,xfy)), (read(G_0), G_0), (op(0,yf,yf), op(0,xfy,xfy))).
   inputs("/**/ writeq(xfy(1,yf(2)))."), peeks("\n"), outputs("1 xfy 2 yf"), G_0 = writeq(xfy(1,yf(2))).

?- setup_call_cleanup((op(9,yf,yf), op(9,xfy,xfy)), (read(G_0), G_0), (op(0,yf,yf), op(0,xfy,xfy))).
   inputs("/**/ writeq(yf(xfy(1,2)))."), peeks("\n"), outputs("(1 xfy 2)yf"), G_0 = writeq(yf(xfy(1,2))).

% s#157, s#158: taking away an operator, which , cannot be

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(1200,xfx,:-)).
   inputs("op(0,xfy,:-).\ncurrent_op(P,xfx,:-)."), peeks("\n"), false.

?- read(G_0), G_0.
   inputs("op(0,xfy,',')."), peeks("\n"), permission_error(modify,operator,',').

% s#159..s#164: a name that is both prefix and postfix or infix

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), (op(0,fy,f), op(0,yf,f))).
   inputs("op(9,fy,f),op(9,yf,f).\nwrite_canonical(f f 0)."), peeks("\n"), outputs("f(f(0))"), G_0 = (op(9,fy,f),op(9,yf,f)), G_1 = write_canonical(f(f(0))).

?- setup_call_cleanup((op(9,fy,f), op(9,yf,f)), (read(G_0), G_0), (op(0,fy,f), op(0,yf,f))).
   inputs("/**/ write_canonical(0 f f)."), peeks("\n"), outputs("f(f(0))"), G_0 = write_canonical(f(f(0))).

?- setup_call_cleanup((op(9,fy,f), op(9,yf,f)), (read(G_0), G_0), (op(0,fy,f), op(0,yf,f))).
   inputs("/**/ write_canonical(f f)."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), (op(0,fy,p), op(0,yfx,p))).
   inputs("op(9,fy,p),op(9,yfx,p).\nwrite_canonical(1 p p p 2)."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), (op(0,fy,p), op(0,xfy,p))).
   inputs("op(9,fy,p),op(9,xfy,p).\nwrite_canonical(1 p p p 2)."), peeks("\n"), outputs("p(1,p(p(2)))"), G_0 = (op(9,fy,p),op(9,xfy,p)), G_1 = write_canonical(p(1,p(p(2)))).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), (op(0,fy,p), op(0,yfx,p))).
   inputs("op(7,fy,p),op(9,yfx,p).\nwrite_canonical(1 p p p 2)."), peeks("\n"), outputs("p(1,p(p(2)))"), G_0 = (op(7,fy,p),op(9,yfx,p)), G_1 = write_canonical(p(1,p(p(2)))).

% s#165..s#169, s#194: . and | as atoms and operators; where the page
% writes '.'+'.' it counts '.' + '.' as good too

?- read(G_0), G_0.
   inputs("atom('.''-''.')."), peeks("\n"), G_0 = atom('.''-''.').

?- setup_call_cleanup(true, (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("op(0,xfy,'|')."), peeks("\n"), G_0 = op(0,xfy,'|').

?- setup_call_cleanup(op(0,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ writeq((a|b))."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,yf,'.')).
   inputs("op(0,xfy,.),op(9,yf,.)."), peeks("\n"), G_0 = (op(0,xfy,'.'),op(9,yf,'.')).

?- setup_call_cleanup(op(9,yf,'.'), (read(G_0), G_0), op(0,yf,'.')).
   inputs("/**/ writeq(.(.))."), peeks("\n"), outputs("('.')'.'"), G_0 = writeq('.'('.')).

?- read(G_0), G_0.
   inputs("op(0,xfy,.),writeq((.)+(.))."), peeks("\n"), outputs("'.' + '.'"), G_0 = (op(0,xfy,'.'),writeq('.'+'.')).

% s#170, s#171: double_quotes

?- setup_call_cleanup(true, (read(G_0), G_0), set_prolog_flag(double_quotes,chars)).
   inputs("set_prolog_flag(\n double_quotes,chars)."), peeks("\n"), G_0 = set_prolog_flag(double_quotes,chars).

?- setup_call_cleanup(set_prolog_flag(double_quotes,chars), (read(G_0), G_0), set_prolog_flag(double_quotes,chars)).
   inputs("/**/ writeq(\"a\")."), peeks("\n"), outputs("[a]"), G_0 = writeq([a]).

% s#172..s#176: numbers; the form of a float is left open, '1.0e-323'
% is the page's example

?- read(G_0), G_0.
   inputs("X is 10.0** -323, writeq(X)."), peeks("\n"), outputs("1.0e-323"), G_0 = (1.0e-323 is 10.0** -323, writeq(1.0e-323)).

?- read(G_0), G_0.
   inputs("1.0e-323=:=10.0** -323."), peeks("\n"), G_0 = (1.0e-323 =:= 10.0** -323).

?- read(G_0), G_0.
   inputs("-1 = -0x1."), peeks("\n"), G_0 = (-1 = -1).

?- read(G_0), G_0.
   inputs("T = t(0b1,0o1,0x1)."), peeks("\n"), G_0 = (t(1,1,1) = t(1,1,1)).

?- read(G_0), G_0.
   inputs("X is 0b1mod 2."), peeks("\n"), G_0 = (1 is 1 mod 2).

% s#177..s#179, s#193: layout and escapes in quoted tokens

?- read(G_0), G_0.
   inputs("0'\\t=0'\t"), peeks("."), syntax_error(...).

?- read(G_0), G_0.
   inputs("\"\\`\" = \"`\"."), peeks("\n"), G_0 = (['`'] = ['`']).

?- read(G_0), G_0.
   inputs("\"\\'\\\"\" = \"'\"\"\"."), peeks("\n"), G_0 = (['\'','"'] = ['\'','"']).

?- read(G_0), G_0.
   inputs("writeq('\\ \n"), peeks("'"), syntax_error(...).

% s#180, s#181: rows that run after an earlier one

?- setup_call_cleanup(op(0,fy,-), (read(G_0), G_0), op(200,fy,-)).
   inputs("/**/ integer(-1)."), peeks("\n"), G_0 = integer(-1).

?- setup_call_cleanup(op(1105,xfy,'|'), (read(G_0), G_0), op(1105,xfy,'|')).
   inputs("/**/ writeq((a-->b,c|d))."), peeks("\n"), outputs("a-->b,c|d"), G_0 = writeq((a-->b,c|d)).

% s#182..s#192: prefix minus; where the page writes -[-], -{} and -{a}
% it counts - [-], - {} and - {a} as good too

?- read(G_0), G_0.
   inputs("writeq(-(-1))."), peeks("\n"), outputs("- -1"), G_0 = writeq(-(-1)).

?- read(G_0), G_0.
   inputs("writeq(-(1^2))."), peeks("\n"), outputs("- (1^2)"), G_0 = writeq(-(1^2)).

?- read(G_0), G_0.
   inputs("writeq(-(-))."), peeks("\n"), outputs("- (-)"), G_0 = writeq(-(-)).

?- read(G_0), G_0.
   inputs("writeq(-[-])."), peeks("\n"), outputs("- [-]"), G_0 = writeq(-[-]).

?- read(G_0), G_0.
   inputs("X/* /*/=7."), peeks("\n"), G_0 = (7 = 7).

?- read(G_0), G_0.
   inputs("X/*/*/=7."), peeks("\n"), G_0 = (7 = 7).

?- read(G_0), G_0.
   inputs("writeq(-p(c))."), peeks("\n"), outputs("-p(c)"), G_0 = writeq(-p(c)).

?- read(G_0), G_0.
   inputs("writeq(-{})."), peeks("\n"), outputs("- {}"), G_0 = writeq(-{}).

?- read(G_0), G_0.
   inputs("writeq(-{a})."), peeks("\n"), outputs("- {a}"), G_0 = writeq(-{a}).

?- read(G_0), G_0.
   inputs("writeq(-(-a))."), peeks("\n"), outputs("- -a"), G_0 = writeq(-(-a)).

?- read(G_0), G_0.
   inputs("writeq(-(-(-a)))."), peeks("\n"), outputs("- - -a"), G_0 = writeq(-(-(-a))).

% s#195..s#197: '' as a postfix operator; the page allows 0 '' or 0''

?- setup_call_cleanup(true, (read(G_0), G_0), op(0,xf,'')).
   inputs("op(100,xf,'')."), peeks("\n"), G_0 = op(100,xf,'').

?- setup_call_cleanup(op(100,xf,''), (read(G_0), G_0), op(0,xf,'')).
   inputs("/**/ writeq(0 '')."), peeks("\n"), outputs("0 ''"), G_0 = writeq(''(0)).

?- setup_call_cleanup(op(100,xf,''), (read(G_0), G_0), op(0,xf,'')).
   inputs("/**/ writeq(0'')."), peeks("\n"), outputs("0 ''"), G_0 = writeq(''(0)).

% s#198..s#200: $ as an atom and an operator

?- read(G_0), G_0.
   inputs("atom($-)."), peeks("\n"), G_0 = atom('$-').

?- read(G_0), G_0.
   inputs("atom(-$)."), peeks("\n"), G_0 = atom('-$').

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,fy,'$')).
   inputs("op(900, fy, [$]).\nwrite_canonical($a+b)."), peeks("\n"), outputs("$(+(a,b))"), G_0 = op(900,fy,['$']), G_1 = write_canonical('$'(a+b)).

main :-
	use_module(library(quads)),
	run_quads.
