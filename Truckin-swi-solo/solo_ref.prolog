:- dynamic
	moves_remaining/1,
	player/6,
	place/6,
	holding/3,
	pending/4.


ref_reset_dynamic:-
	retractall(player(_,_,_,_,_,_)),
	retractall(place(_,_,_,_,_,_)),
	retractall(moves_remaining(_)),
	retractall(pending(_,_,_,_)),
	retractall(holding(_,_,_)),
	findall( _,( 
		initial_place(A,B,C,D,E,F),
		assert(place(A,B,C,D,E,F))
		),
		_
	).

start_ref:-
	repeat,
	ref_info,
	make_moves,
	ref_retract(moves_remaining(Moves)),
	Moves1 is Moves - 1,
	ref_asserta(moves_remaining(Moves1)),
	Moves1 = 0,
	ref_end.

make_moves :-
	player(Player, _, _, _, _, _),
	make_move(Player),
	fail.

make_moves :-
	place(Where, _, _, Amount, _, _),
	% Do only the things you can when you're at this square
	bagof(pending(Player, Q, Gets), pending(Player, Q, Item, Where), L),
	retractall( pending(_,_,_,Where) ), % BUG FIX! Else they keep buying.
	L \= [],
	distrib(Amount, L, 0),
	group_transact(L, Where),
	print_place(Where),
	fail.
make_moves.

print_place(Place):-
	place(Place,Name,Item,Amount,Price,seller),!,
	Dollars is Price / 100,
	Cents is Price - Dollars * 100,
	format(
		'~s (~d) now has ~f of ~s to sell at $ ~f.~f \n',
		[Name, Place, Amount, Item, Dollars, Cents]
	).

print_place(Place):-
	place(Place,Name,Item,Amount,Price,buyer),!,
	Dollars is Price / 100,
	Cents is Price - Dollars * 100,
	format(
		'~s (~d) will now buy ~f of ~s for $ ~f.~f \n',
		[Name, Place, Amount, Item, Dollars, Cents]
	).

print_place(Place):-
	place(Place,Name,Item,Amount,Price,tip),!,
	Dollars is Price / 100,
	Cents is Price - Dollars * 100,
	format(
		'~s (~d) will accept ~f of ~s for $ ~f.~f \n',
		[Name, Place, Amount, Item, Dollars, Cents]
	).

print_place(_).

make_move(Player):-
	move(Player, Type, Quantity),
	print(move(Player, Type, Quantity)),
	integer(Quantity),
	ref_choice(Player, Type, Quantity),!.

make_move(Player):-
	format('no valid move for ~s\n', [Player]).

ref_choice(Player,Type,Quantity):-
	Type = m,
	ref_absolute(Quantity,Abs),
	Abs > 8,
	format('~s tried to go further than 8\n',[Player]).

ref_choice(Player,Type,Quantity):-
	Type = m,
	ref_retract(player(Player,W,Cash,V,Fuel,Where)),
	ref_absolute(Quantity,Abs),
	ref_min([Abs,Fuel],Min),
	Fuel1 is Fuel - Min,
	ref_posneg(Quantity,Min,Min1),
	ref_move(Where,Min1,To),
	item('Fuel',FWeight,_),
	Weight is W + Min*FWeight,
	ref_asserta(player(Player,Weight,Cash,V,Fuel1,To)).
ref_choice(Player,Type,Quantity):-
	Type = t,
	Quantity >= 0,
	ref_transact(Player,Quantity).

ref_transact(Player,0).
ref_transact(Player,Quantity):-
	player(Player,_,Cash,_,_,Where),
	place(Where,_,_,_,_,seller),!,
	Cash > 0,
	ref_buying(Player,Quantity).
ref_transact(Player,Quantity):-
	ref_selling(Player,Quantity).

ref_buying( Player, Quantity):-
	player(Player, _, _, _, _, Where),
	place(Where, _, Item, _, _, _),
	ref_max(Max, Player),
	ref_min([Max, Quantity], Min),
	asserta(pending(Player, Min, Item, Where)).

ref_selling(Player,Quantity):-
	player(Player,_,_,_,_,Where),
	place(Where,_,Item,_,_,buyer),!,
	ref_sell(Player,Quantity,Item).

ref_selling(Player,Quantity):-
	player(Player,_,_,_,_,Where),
	place(Where,_,_,_,_,tip),
	ref_sell(Player,Quantity,_).

ref_sell(Player, Quantity, Item):-
	player(Player, _, Cash, _, _, Where),
	place(Where,_,_,_,_,buyer),
	holding(Player, Item, Numb),
	ref_min([Quantity, Numb], Min),
	asserta(pending(Player,Min, Item, Where)).

ref_sell(Player, Quantity, Item):-
	player(Player, _, Cash, _, _, Where),
	place(Where,_,_,_,Price,tip),
	CanSell is Cash / - Price ,
	holding(Player, Item, Numb),
	ref_min([Quantity, Numb, CanSell], Min),
	asserta(pending(Player,Min, Item, Where)).

group_transact(L, Where):-
	place(Where, _, _, _, _, seller),
	group_buy(L).
group_transact(L,Where):-
	place(Where, _, _, _, _, buyer),
	group_sell(L).
group_transact(L,Where):-
	place(Where, _, _, _, _, tip),
	group_sell(L).


group_buy([]).
group_buy([pending(Player, _, Gets) | Rest]):-
	ref_retract(player(Player, W, Cash, V, Gas, Where)),
	ref_retract(place(Where, Name, Item, Numb, Price, Type)),
	item(Item, Iweight, Ivolume),
	Nweight is W - (Iweight * Gets),
	Ncash is Cash - (Price  * Gets),
	Nvolume is V - (Ivolume * Gets),
	Nquantity is Numb - Gets,
	ref_asserta(player(Player, Nweight, Ncash, Nvolume, Gas, Where)),
	ref_asserta(place(Where, Name, Item, Nquantity, Price, Type)),
	ref_morehold(Player, Item, Gets),

	group_buy(Rest).

group_sell([]).
group_sell([pending(Player, _, Sells) | Rest]):-
	ref_retract(player(Player, W, Cash, V, Gas, Where)),
	ref_retract(place(Where, Name, Item, Numb, Price, Type)),
	ref_retract(holding(Player, Item, Have)),
	item(Item, Iweight, Ivolume),
	Nweight is W + (Iweight * Sells),
	Ncash is Cash + (Price * Sells),
	Nvolume is V + (Ivolume* Sells),
	Nquantity is Numb - Sells,
	Nhave is Have - Sells,
	ref_asserta(player(Player, Nweight, Ncash, Nvolume, Gas, Where)),
	ref_asserta(place(Where, Name, Item, Nquantity, Price, Type)),
	(Nhave \= 0 -> ref_asserta(holding(Player, Item, Nhave)) | true),
	group_sell(Rest).

	% pending(Player,Wants,Gets)

distrib(QA,Players,Have):-
	fix(Players,Have,NonZero,Count),
	Count > 0,!,
	min_want(NonZero,Q1),
	Q is Q1 - Have,
	QRequired is Q * Count,
	( QRequired =< QA
	->
		( Remaining is QA - QRequired,
		  WillHave is Q + Have,
		  distrib(Remaining,NonZero,WillHave)
		)
	|
		(
		  Qe is QA / Count,
		  QRemaining is QA - Qe * Count,
		  share(Qe,QRemaining,NonZero,Have)
		)
	).
distrib(QA,Players,Have):-fix(Players,Have,[],0).

min_want([pending(_,X,_)],X):-!.
min_want([pending(_,Wants,_)|T],Min):-
	min_want(T,Min2),
	ref_min([Wants,Min2],Min).

%fix(Player,CanHave,WantMore,Count)

fix([],_,[],0):-!.
fix([pending(Player,CanHave,CanHave)|T],CanHave,T2,C):-
	fix(T,CanHave,T2,C).
fix([pending(Player,Wants,Gets)|T],CanHave,[pending(Player,Wants,Gets)|T2],C):-
	Wants > CanHave,
	fix(T,CanHave,T2,C2),
	C is C2 + 1.

share(_,_,[],_):-!.
share(Q,0,[pending(Player,_,Gets)|T],Has):-
	Gets is Has + Q,
	share(Q,0,T,Has).
share(Q,Bits,[pending(Player,_,Gets)|T],Has):-
	Bits > 0,
	Bits2 is Bits - 1,
	Gets is Has + Q + 1,
	share(Q,Bits2,T,Has).

ref_morehold(_, _, 0):-!.
ref_morehold(Player,'Fuel', Min):-!,
	ref_retract(player(Player, W, C, V, Fuel, Wh)),
	NewFuel is Fuel + Min,
	ref_asserta(player(Player, W, C, V, NewFuel, Wh)).

ref_morehold(Player,Item,Min):-
	ref_retract(holding(Player,Item,X)),!,
	New is X + Min,
	ref_asserta(holding(Player,Item,New)).
ref_morehold(Player,Item,Min):-
	ref_asserta(holding(Player,Item,Min)).

ref_max(Max,Player):-
	player(Player,Pweight,Pcash,Pvolume,Pfuel,Where),
	place(Where,_,Item,_,Price,seller),
	item(Item,Iweight,Ivolume),
	Cash is Pcash / Price,
	Weight is Pweight / Iweight,
	max_fuel(Max_fuel),
	(Item = 'Fuel' -> Volume is Max_fuel - Pfuel
			| Volume is Pvolume / Ivolume),
	ref_min([Cash, Weight,Volume],Max).

ref_move(Where,Quantity,To):-
	Spot is Where + Quantity,
	last_stop(G),
	H is G + 1,
	ref_to(H,Spot,To).

ref_to(H,Spot,Spot):-
	Spot >= 0,
	Spot < H,!.
ref_to(H,Spot,To):-
	Spot < 0,!,
	To is Spot + H.
ref_to(H,Spot,To):-
	Spot > (H - 1),
	To is Spot - H.

ref_posneg(Quantity,Min,Min):- Quantity >= 0, !.
ref_posneg(Quantity,Min,Min1):- Min1 is 0 - Min.

ref_absolute(Quantity,Abs) :-
	Quantity =< 0,
	Abs is 0 - Quantity.
ref_absolute(Quantity,Quantity) :-
	Quantity > 0.

ref_min([A], A).
ref_min([A,B|C],X):-
	A =< B,!,
	ref_min([A|C],X).
ref_min([_,B|C],X):-
	ref_min([B|C],X).

ref_end:-
	ref_info,
	player(Player,_,Cash,_,_,Place),
	Cash1 is Cash / 100,
	place(Place,Name,_,_,_,_),
	format('~s finished at ~s  with $ ~f\n',[Player, Name,Cash1]),
	fail.
ref_end.

ref_info:-
	player(Player,_,Cash,_,Fuel,Where),
	Cash1 is Cash / 100,
	place(Where,Name,_,_,_,_),
	format('~s at ~s ( ~d ) has $ ~f and ~f \n', [Player,Name, Where,Cash1, Fuel]),
	format('Holding: '),
	ref_holdwrite(Player),
	format('\n',[]),
	fail.

ref_info:-
	moves_remaining(Moves),
	format('Moves remaining: ~d\n', [Moves]),
	nl.

ref_holdwrite(Player):-
	holding(Player,Item,Quantity),
	format('[ ~f of ~s], ', [Quantity,Item]),
	fail.
ref_holdwrite(_).

ref_retract(P):-
	retract(P).
ref_asserta(P):-
	asserta(P).

start_atruck(Name):-
	format('~s is starting (Brmmm Brmmm)\n',[Name]),
	can_carry(Can_carry),
	can_hold(Can_hold),
	start_cash(Cents),
	max_fuel(Max_fuel),
				 %	item('Fuel',FuelW,FuelV),
	WeightLeft is Can_carry ,% should it be - Max_fuel * FuelW,
	place(Start, _, _, _, _, start),
	asserta(player(Name, WeightLeft, Cents, Can_hold, Max_fuel, Start)).

