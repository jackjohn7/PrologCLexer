% Name:     Jack Branch
% Email:    jcb129@email.latech.edu
% Date:     5/20/24
% Course:   CSC-330-001
% Quarter:  Spring 2024
% Project:  P2A (Lexer in Prolog)

% helpers
stdout(Msg) :- write(Msg), nl.
code_to_atom(C, R) :- atom_codes(R, [C]).
string_to_atoms(S, R) :- string_codes(S, C), maplist(code_to_atom, C, R).
read_file_to_chars(Filename, Chars) :- read_file_to_string(Filename, Str, []),
	string_to_atoms(Str, Chars).
is_member([H|T], R) :- H \= R, is_member(T,R).
is_member([H|_], H).
is_whitespace(C) :- is_member([' ', '\t', '\n', '\r'], C).
is_delimiter(C) :- is_member([';', '(', ')', '{', '}'], C).
delimits(C) :- is_whitespace(C) ; is_delimiter(C).
is_digit(C) :- is_member(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], C).

% read integer chars to single atom in in-<int> format
tok_int([H|T], Acc, R, Next) :- is_digit(H), tok_int(T, [H|Acc], R, Next).
tok_int([H|T], Acc, R, [H|T]) :- \+ is_digit(H),
	reverse(Acc, AccRev), atomic_list_concat(['in-'|AccRev], R).

% tokenize list of atoms (chars) to list of atoms (lexemes)
tokenize([r,e,t,u,r,n|[H|T]],  [ret|R]) :- delimits(H), tokenize([H|T], R).
tokenize([r,e,t,u,r,n|[]],  [ret]).
tokenize([i,n,t|[H|T]], [int|R]) :- delimits(H), tokenize([H|T], R).
tokenize([i,n,t|[]], [int]).
tokenize([m,a,i,n|[H|T]], [mai|R]) :- delimits(H), tokenize([H|T], R).
tokenize([m,a,i,n|[]], [mai]).
tokenize(['('|T], [op|R]) :- tokenize(T, R).
tokenize([')'|T], [cp|R]) :- tokenize(T, R).
tokenize(['{'|T], [ob|R]) :- tokenize(T, R).
tokenize(['}'|T], [cb|R]) :- tokenize(T, R).
tokenize([';'|T], [sc|R]) :- tokenize(T, R).
tokenize([H|T], R) :- is_whitespace(H), tokenize(T, R).
tokenize([H|T], [R1|R]) :- is_digit(H), tok_int(T, [H], R1, T1), tokenize(T1, R).
tokenize([], []). % EOF

% reads file to chars and then tokenize them
read_file_to_tok(Filename, Tokens) :- read_file_to_chars(Filename, Chars), tokenize(Chars, Tokens).
read_file_to_tok(Filename, []) :- read_file_to_chars(Filename, Chars),
	\+ tokenize(Chars, _),
	throw(syntax_error).

% parse function wraps read_file_to_tok to catch all errors
parse(Filename, Tokens) :-
	catch(read_file_to_tok(Filename, Tokens), Exception, handle_exception(Exception)).

% on any exception, simply print Parse Error as nothing further is specified on Canvas
handle_exception(_) :- stdout("Parse Error").
