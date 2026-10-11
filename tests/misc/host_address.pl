% host_address/3 gives each address the resolver has for a host, so a
% caller can vet them before connecting; domain(inet|inet6) picks a family.

:- use_module(library(socket)).

:- initialization(main).

main :-
	findall(A, host_address(localhost, A, [domain(inet)]), L4),
	writeq(inet(L4)), nl,
	( findall(A, host_address(localhost, A, []), All), memberchk(ip(127,0,0,1), All) -> writeln(all_has_ipv4) ; writeln(missing) ),
	catch(host_address('no-such-host.invalid', _, []), error(E, _), true),
	writeq(E), nl.
