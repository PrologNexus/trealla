:- module(atts, [
		op(1199, fx, attribute)
	]).

% Compatability

get_attr(Var, Module, Value) :-
	var(Var),
	Access =.. [Module, Value],
	get_atts(Var, Access).

put_attr(Var, Module, Value) :-
	Access =.. [Module, Value],
	put_atts(Var, Access).

del_attr(Var, Module) :-
	Access =.. [Module, _],
	var(Var) -> put_atts(Var, -Access); true.
