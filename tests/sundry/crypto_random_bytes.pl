% crypto_n_random_bytes/2 reads the OS random source. A guard meant for
% freestanding builds was true everywhere, so it raised system_error on
% every platform, which nothing here noticed until a program used it.

:- initialization(main).

main :-
	crypto_n_random_bytes(16, A),
	crypto_n_random_bytes(16, B),
	length(A, N),
	( forall(member(X, A), (integer(X), X >= 0, X =< 255)) -> Bytes = bytes ; Bytes = not_bytes ),
	( A \== B -> Fresh = fresh ; Fresh = repeated ),
	crypto_n_random_bytes(1000, C),
	length(C, M),
	writeq([N, Bytes, Fresh, M]), nl.
