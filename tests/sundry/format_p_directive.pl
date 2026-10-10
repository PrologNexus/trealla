% ~p wrote straight to a stream: to an atom(_) sink it had none and
% crashed, and to a stream it came out ahead of the text before it.

:- initialization(main).

portray(secret(_)) :- write('<hidden>').

t_atom(R) :- format(atom(R), '~p', [-2]).
t_order(R) :- with_output_to(atom(R), format('x~py', ['A'])).
t_portray_atom(R) :- format(atom(R), 'a~pb~pc', [secret(1), f(secret(2), x)]).
t_portray_order(R) :- with_output_to(atom(R), format('[~p]', [secret(3)])).
t_print(R) :- with_output_to(atom(R), print(secret(4))).

main :-
	forall(
		member(T, [t_atom, t_order, t_portray_atom, t_portray_order, t_print]),
		(	G =.. [T, R],
			(	catch(G, E, R = uncaught(E)) -> true ; R = failed ),
			format("~w: ~q~n", [T, R])
		)
	).
