:- initialization(main).
:- set_prolog_flag(strict_iso, true).

% Stage 3 of #1099, continued: s#5..s#50 of UWN's ISO syntax conformity
% suite (https://www.complang.tuwien.ac.at/ulrich/iso-prolog/conformity_testing),
% each row's text read by read/1 from inputs/1, in strict_iso mode since
% the suite describes ISO. A syntax error is described with how far the
% reader got, which the standard leaves open: up to the offending
% character, or through the end token with the layout after it peeked.

% s#5: a horizontal tab in a quoted atom

?- read(G_0), G_0.
   inputs("writeq('\t'). % horiz. tab\n"), syntax_error(...).

% s#6: a newline in a quoted atom

?- read(G_0), G_0.
   inputs("writeq('\n"), peeks("'"), syntax_error(...).

% s#7..s#10: a continuation escape, backslash then newline

?- read(G_0), G_0.
   inputs("writeq('\\\n')."), peeks(" "), outputs("''"), G_0 = writeq('').

?- read(G_0), G_0.
   inputs("writeq('\\\na')."), peeks(" "), outputs("a"), G_0 = writeq(a).

?- read(G_0), G_0.
   inputs("writeq('a\\\nb')."), peeks(" "), outputs("ab"), G_0 = writeq(ab).

?- read(G_0), G_0.
   inputs("writeq('a\\\n b')."), peeks(" "), outputs("'a b'"), G_0 = writeq('a b').

% s#11, s#12: a backslash followed by a space or a tab

?- read(G_0), G_0.
   inputs("writeq('\\ ').\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq('\\\t'). % \"\\\\\\t\"\n"), syntax_error(...).

% s#13

?- read(G_0), G_0.
   inputs("writeq('\\t')."), peeks("\n"), outputs("'\\t'"), G_0 = writeq('\t').

% s#14, s#15: how BEL is written is left open; '\a' is the page's example

?- read(G_0), G_0.
   inputs("writeq('\\a')."), peeks("\n"), outputs("'\\a'"), G_0 = writeq('\a').

?- read(G_0), G_0.
   inputs("writeq('\\7\\')."), peeks("\n"), outputs("'\\a'"), G_0 = writeq('\a').

% s#16, s#17: \c and \e are not ISO escapes (Trealla accepts \e outside
% strict_iso)

?- read(G_0), G_0.
   inputs("writeq('\\ca').\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq('\\e').\n"), syntax_error(...).

% s#18: ESC has no escape of its own, so its form is left open: the page
% gives '\33\' as an example, and Trealla writes the hex escape '\x1b\'

?- read(G_0), G_0.
   inputs("writeq('\\033\\')."), peeks("\n"), outputs("'\\x1b\\'"), G_0 = writeq('\33\').

% s#19, s#21: \e and \d are not ISO escapes (s#20 is not on the page)

?- read(G_0), G_0.
   inputs("char_code('\\e',C).\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("char_code('\\d',C).\n"), syntax_error(...).

% s#22, s#23: neither is \u

?- read(G_0), G_0.
   inputs("writeq('\\u1').\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("X = 0'\\"), peeks("u"), syntax_error(...).

% s#24..s#26: unterminated text

?- read(G_0), G_0.
   inputs("writeq('\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("writeq(.\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("'\\\n''.\n"), syntax_error(...).

% s#27..s#37: operators and special atoms as arguments and in output

?- read(G_0), G_0.
   inputs("writeq((*)=(*))."), peeks("\n"), outputs("(*)=(*)"), G_0 = writeq('='('*','*')).

?- read(G_0), G_0.
   inputs("writeq([:-,-])."), peeks("\n"), outputs("[:-,-]"), G_0 = writeq([':-','-']).

?- read(G_0), G_0.
   inputs("writeq(f(*))."), peeks("\n"), outputs("f(*)"), G_0 = writeq(f('*')).

?- read(G_0), G_0.
   inputs("writeq(a*(b+c))."), peeks("\n"), outputs("a*(b+c)"), G_0 = writeq('*'(a,'+'(b,c))).

?- read(G_0), G_0.
   inputs("writeq(f(;,'|',';;'))."), peeks("\n"), outputs("f(;,'|',';;')"), G_0 = writeq(f(';','|',';;')).

?- read(G_0), G_0.
   inputs("writeq([.,.(.,.,.)])."), peeks("\n"), outputs("['.','.'('.','.','.')]"), G_0 = writeq(['.','.'('.','.','.')]).

?- read(G_0), G_0.
   inputs("writeq((a :- b,c))."), peeks("\n"), outputs("a:-b,c"), G_0 = writeq(':-'(a,','(b,c))).

?- read(G_0), G_0.
   inputs("write_canonical([a])."), peeks("\n"), outputs("'.'(a,[])"), G_0 = write_canonical([a]).

?- read(G_0), G_0.
   inputs("writeq('/*')."), peeks("\n"), outputs("'/*'"), G_0 = writeq('/*').

?- read(G_0), G_0.
   inputs("writeq('/**')."), peeks("\n"), outputs("'/**'"), G_0 = writeq('/**').

?- read(G_0), G_0.
   inputs("writeq('*/')."), peeks("\n"), outputs("*/"), G_0 = writeq('*/').

% s#38..s#41: quotes and backslashes. s#38 compares two strings, whose
% form depends on double_quotes, so only its success is described. How
% s#40's atom is written is left open; Trealla escapes ` and " too.

?- \+ \+ (read(G_0), G_0).
   inputs("\"\\'\\`\\\"\" = \"'`\"\"\"."), peeks(" ").

?- read(G_0), G_0.
   inputs("'\\'\\`\\\"' = '''`\"'."), peeks("\n"), G_0 = ('\'`"' = '\'`"').

?- read(G_0), G_0.
   inputs("writeq('\\'\\`\\\"\\\"')."), peeks("\n"), outputs("'\\'\\`\\\"\\\"'"), G_0 = writeq('\'`""').

?- read(G_0), G_0.
   inputs("('\\\\') = (\\)."), peeks("\n"), G_0 = (('\\') = ('\\')).

% s#42, s#45, s#49, s#50 declare an operator and then use it: two reads,
% with the operator taken away again afterwards

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xf,xf1)).
   inputs("op(1,xf,xf1).\n1xf1 = xf1(1)."), peeks("\n"), G_0 = op(1,xf,xf1), G_1 = (xf1(1) = xf1(1)).

% s#43, s#44, s#46..s#48: number syntax

?- read(G_0), G_0.
   inputs("X = 0X1."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("float(.0)."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xfx,'.')).
   inputs("op(100,xfx,.).\nfunctor(3 .2,F,A)."), peeks("\n"), G_0 = op(100,xfx,'.'), G_1 = functor('.'(3,2),'.',2).

?- read(G_0), G_0.
   inputs("float(- .0)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("float(1E9)."), peeks("\n"), syntax_error(...).

?- read(G_0), G_0.
   inputs("integer(1e)."), peeks("\n"), syntax_error(...).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xf,e9)).
   inputs("op(9,xf,e9).\n1e9 = e9(1)."), peeks("\n"), G_0 = op(9,xf,e9), G_1 = (e9(1) = e9(1)).

?- setup_call_cleanup(true, (read(G_0), G_0, read(G_1), G_1), op(0,xf,e)).
   inputs("op(9,xf,e).\n1e-9 = -(e(1),9)."), peeks("\n"), G_0 = op(9,xf,e), G_1 = ('-'(e(1),9) = '-'(e(1),9)).

main :-
	use_module(library(quads)),
	run_quads.
