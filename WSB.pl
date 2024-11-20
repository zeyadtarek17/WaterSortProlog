:- include('KB.pl').

testbottles :-
    bottle1(X, Y),
    bottle2(A, B),
    bottle3(C, D),
    write('Bottle 1: '), write(X), write(', '), write(Y), nl,
    write('Bottle 2: '), write(A), write(', '), write(B), nl,
    write('Bottle 3: '), write(C), write(', '), write(D), nl.

content(1, Top, Bottom, s0) :- bottle1(Top, Bottom).
content(2, Top, Bottom, s0) :- bottle2(Top, Bottom).
content(3, Top, Bottom, s0) :- bottle3(Top, Bottom).

content(B, Top, Bottom, result(pour(I, J), S)) :-
    (
        % Bottle B is the destination of the pour
        B = J,
        content(J, OldTop, OldBottom, S),
        content(I, PouredTop, _, S),
        % Prevent pouring if the destination already has two different colors
        \+ (OldTop \= e, OldBottom \= e, OldTop \= OldBottom),
        (
            % Case 1: Destination bottle is completely empty
            OldTop = e, OldBottom = e,
            Top = e, % Top remains empty
            Bottom = PouredTop % Poured layer goes to the bottom
        ;
            % Case 2: Destination bottle has only the bottom layer filled
            OldTop = e, OldBottom \= e,
            Top = PouredTop, % Poured layer becomes the new top
            Bottom = OldBottom
        ;
            % Case 3: Destination bottle is full (do nothing, valid action ignored)
            OldTop \= e, OldBottom \= e,
            Top = OldTop,
            Bottom = OldBottom
        )
    );
    (
        % Bottle B is the source of the pour
        B = I,
        content(I, OldTop, OldBottom, S),
        OldTop \= e, % Source bottle was not empty
        Top = e, % Top becomes empty after pouring
        Bottom = OldBottom
    );
    (
        % Bottle B is unaffected by the pour
        B \= I, B \= J,
        content(B, Top, Bottom, S)
    ).

% Define the goal state
goal(S) :-
    % Bottle 1 is blue, Bottle 2 is red, Bottle 3 is empty
    # content(1, Color1, Color1, S),
    # content(2, Color2, Color2, S),
    # content(3, Color3, Color3, S),  Color1 \= Color2, Color1 \= Color3, Color2 \= Color3.

    content(1, b, b, S),
    content(2, r, r, S),
    content(3, e, e, S)
    ;
    % Bottle 1 is red, Bottle 2 is blue, Bottle 3 is empty
    content(1, r, r, S),
    content(2, b, b, S),
    content(3, e, e, S)
    ;
    % Bottle 1 is empty, Bottle 2 is blue, Bottle 3 is red
    content(1, e, e, S),
    content(2, b, b, S),
    content(3, r, r, S)
    ;
    % Bottle 1 is empty, Bottle 2 is red, Bottle 3 is blue
    content(1, e, e, S),
    content(2, r, r, S),
    content(3, b, b, S)
    ;
    % Bottle 1 is blue, Bottle 2 is empty, Bottle 3 is red
    content(1, b, b, S),
    content(2, e, e, S),
    content(3, r, r, S)
    ;
    % Bottle 1 is red, Bottle 2 is empty, Bottle 3 is blue
    content(1, r, r, S),
    content(2, e, e, S),
    content(3, b, b, S).

% Iterative deepening search
ids(Solution) :-
    call_with_depth_limit(goal(Solution), 1, R),
    (R \= depth_limit_exceeded -> true ;
    NewDepth is 2, ids_with_limit(NewDepth, Solution)).

ids_with_limit(Depth, Solution) :-
    call_with_depth_limit(goal(Solution), Depth, R),
    (R \= depth_limit_exceeded -> true ;
    NewDepth is Depth + 1, ids_with_limit(NewDepth, Solution)).