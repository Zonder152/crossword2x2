% Возвращает позицию (ReturnPosition) элеменита X в списке.
member(X, [X | Tail], Position, ReturnPosition):- 
	ReturnPosition is Position+1.
member(X, [Head | Tail], Position, ReturnPosition):-
	NextPosition is Position + 1,
        member( X, Tail, NextPosition, ReturnPosition).

%Объединяет 2 списка. Результат в 3ем.
append2([]/[], [],Return):-
	Return = []/[].
%append2([]/_, _,_):-	write('Append24').
append2(Pos1/[Pos2|All], Massive,Return):-
	append([Pos1/Pos2], Massive, NewMassive),
	append2(Pos1/All, NewMassive,Return);
	nl.
append2(N/[], Massive,Return):-
	Return = Massive.

% Поиск пересечения 2х слов, результат в Ret
intersection2words([], [],Pos2,Massive,Ret):-
	write(' ! no letter, no words '),nl,!;
	write(' EEE1 ').
intersection2words([], _, Pos2,Massive,Ret):-
	Ret = Massive,!;
	write(' EEE22 ').
intersection2words(_, [],Pos2,Massive,Ret):-!.
intersection2words([Letter|Other_Letters], SomeWord,Pos2,Massive,Ret):-
	Pos1 = 0,NextPos2 is Pos2 + 1,
	%Поиск символа (Letter) в слове (SomeWord). В RetPositions все найденные позиции 
 	findall(ReturnPosition,member(Letter,SomeWord, Pos1,ReturnPosition),RetPositions),
	append2(NextPos2/RetPositions,Massive,ResMassive),
	intersection2words(Other_Letters, SomeWord, NextPos2,ResMassive,Ret),!.

%-----------------------------------------------------------------
% Шаг 2:  Составляем список всевозможных сочетаний для пересечения 
%         горизонтального слова с 2мя вертикальными. 
%         Результат в Ret = X2/X/'<-->'/Y2/Y
%
% Пример:
%	               [1/ ]	
%	[ /1][1/2][ /3][2/4][ /5 ][ /6]
%	     [2/ ]     [3/ ]
%            [3/ ]     [4/ ]
%
%  Ret =      1/2  <--> 2/4
%-----------------------------------------------------------------
step2_2(X2/X, Y2/Y, Massive, Ret):-
	R is abs(X-Y), R>1, Ret = [X2/X/'<-->'/Y2/Y];
	Ret = [].

step2_1(Pair1, [], Mas, Ret):-
	Ret = Mas.
step2_1(Pair1,[Pair2|Tail], Mas,Ret):-
	step2_2(Pair1, Pair2,[], Return),
	append(Return, Mas, NewMas),
	step2_1(Pair1, Tail, NewMas,Ret).


step2([],_,Massive,Return):-
	Return = Massive.
step2([Pair1|Tail1], Pairs, Massive,Return):-
	step2_1(Pair1, Pairs,[],Ret),
	append(Ret, Massive, NewMassive),
	step2(Tail1, Pairs, NewMassive,Return),!.
%-----------------------------------------------------------------

%-----------------------------------------------------------------
% Шаг 3: Составляем кросворд удовлетворяющий условиям:
%        а) расстояние между соседними пересекающимися буквами не менее 1.
%        б) места пересечения образуют прямоугольник
%	 Результат в Ret = [X/Y/'<-->'/Z/W,' and ',S/N/'<-->'/R/T];
%
%                        [   ]
%               [   ]    [   ]
%       [  ][  ][x/y][  ][z/w][  ]
%               [   ]    [   ]
%               [   ]    [   ]
%           [  ][s/n][  ][r/t][  ]
%               [   ]
%
%-----------------------------------------------------------------
step3_2(X/Y/_/Z/W, S/N/_/R/T,Massive, Ret):-
	K is W-Y,M is N + K, M = T,
	S-X>1,R-Z>1,W-Y>1,T-N>1,    % а)
	KK is S-X,MM is Z+KK, MM=R, % б)	
	Ret = [X/Y/'<-->'/Z/W,' and ',S/N/'<-->'/R/T];
	Ret = [].

step3_1(Pair1,[], Mas,Ret):-
	Ret = Mas.
step3_1(Pair1,[Pair2|Tail], Mas,Ret):-
	step3_2(Pair1, Pair2,[], Return),
	append(Return, Mas, NewMas),
	step3_1(Pair1, Tail, NewMas,Ret).


step3([],_,Massive,Return):-
	Return = Massive.
step3([Pair1|Tail1], Pairs, Massive,Return):-
	step3_1(Pair1, Pairs,[],Ret),
	append(Ret, Massive, NewMassive),
	step3(Tail1, Pairs, NewMassive,Return),!.
%-----------------------------------------------------------------

% установить курсор в позицию x,y
cursor(X,Y) :- put(27),put(91),write(Y),
               put(59),write(X),put(72).

% очистка экрана
cls :- write('\33\[2J').

% вывод вертикального слова
vert([],_,_).
vert([L|Word], C, R):-
	NextR is R+1,	
	cursor(C,NextR),
	write(L),
	vert(Word,C, NextR).

% вывод горизонтального слова
cout([]).
cout([L|Word]):-
	write(L),cout(Word).

chech(W3,W4,R,T):-
	length(W3, Len3), length(W4, Len4),R=\=Len3,T=\=Len4;
	length(W3,Len3), length(W4,Len4), R=Len3,T=\=Len4;
	length(W3, Len3), length(W4, Len4), R=\=Len3,T=Len4;
        fail.

	

% Вывод полученного кросворда на экран
printCrossword([], W1,W2,W3,W4).
printCrossword([X/Y/'<-->'/Z/W,' and ',S/N/'<-->'/R/T|Others], W1,W2,W3,W4):-	
	chech(W3,W4,R,T),
	
	CC = 10, RR = 10,
	Row1 is RR-X,
	vert(W2,CC, Row1),
	Row2 is RR-Z,
	CC2 is CC+(W-Y),
	vert(W3,CC2, Row2),
	R1 is RR, C1 is CC-Y+1, cursor(C1,R1),cout(W1), 
	R2 is R1+(S-X), C2 is (CC-N)+1, cursor(C2,R2),cout(W4),
	nl,nl,!.
% Пояснение	           
%               CC       CC2
%         	 \        \
%
%                        [ ]	  < R1
%               [ ]      [ ]      < R2
% Row1 >  [ ][ ][ ][ ][ ][ ][ ]
%               [ ]      [ ]
%               [ ]      [ ]
% Row2 >     [ ][ ][ ][ ][ ][ ][ ]
%               [ ]
%
%          ^  ^   
%         C1  C2   

% Если есть решение, очистим экран
emptyCheck(E):-
	E=[_|_],cls.

%поиск решения кросворда
solve(Words):-
	permutation(Words, Perestanovki),
	Perestanovki = [Word1,Word2,Word3,Word4],
	intersection2words(Word2,Word1,0,[],G1V1),
	intersection2words(Word3,Word1,0,[],G1V2),
	intersection2words(Word2,Word4,0,[],G2V1),
	intersection2words(Word3,Word4,0,[],G2V2),
	%write(G1V1), nl,
	
	step2(G1V1, G1V2,[], G1Crosses),
	step2(G2V1, G2V2,[], G2Crosees),
	step3(G1Crosses, G2Crosees, [], AllCrosses),
	emptyCheck(AllCrosses),
	%write(Words),
	printCrossword(AllCrosses,Word1,Word2,Word3,Word4).

%ввод с клавиатуры
enterWords(Words):-
	write('Ручной ввод (пример слова [c,a,t]. ):'),nl,
	write('Введите 1 слово: '),read(Word1),
	write('Введите 2 слово: '),read(Word2),
	write('Введите 3 слово: '),read(Word3),
	write('Введите 4 слово: '),read(Word4),
	Words = [Word1,Word2,Word3,Word4].

% main функция
print:-
	
	% ввод с клавиатуры, например [e,a,g,l,e].	
	enterWords(Words),

	% готовые слова
	%Words = [[e,a,g,l,e],[c,a,s,t,l,e],[d,e,s,e,r,t],[s,t,o,r,e]],
	
	write(Words),
	solve(Words).
