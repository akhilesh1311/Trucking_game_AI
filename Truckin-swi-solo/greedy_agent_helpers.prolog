
set_agent_state(ToState):-
	retractall(agent_state(_)),
	asserta( agent_state(ToState) ).

find_max_pricediff( PPList, MaxPriceDiff):-
	% Returns the member of PPList having max PriceDiff
	% pppdiff( Place1, Place2, PriceDiff)
	findall( PDiff, member(pppdiff(_,_,PDiff), PPList), PDList ),
	max_list(PDList, MaxPDiff),
	member( pppdiff(Place1, Place2, MaxPDiff ), PPList ),
	MaxPriceDiff = pppdiff(Place1,Place2, MaxPDiff).

needs_to_go_home:-
	% If we can't make it home with the (turns-1)  or (fuel-8)
	player(greedy_agent,_,_,_,Fuel, Where ),
	moves_remaining(MRemaining),
	FReqd is min(Where, 64-Where)+16,
	MReqd is FReqd/8,
	( FReqd > Fuel; MReqd > MRemaining ).

% step_to_go_to(Destination, MovesNeeded)
% Returns how many steps to move to go home
step_to_go_to( Dest, 0 ):-
	player(greedy_agent,_,_,_,_, Where ),
	Where = Dest.

step_to_go_to(Dest, MoveQuantity):-
	player(greedy_agent,_,_,_,_, Where ),
	Diff is ((Dest-Where+64) mod 64),
	Diff < 32,
	MoveQuantity is min(8, Diff).


step_to_go_to( Dest, MoveQuantity):-
	% Returns how many steps to move to go home
	player(greedy_agent,_,_,_,_, Where ),
	Diff is ((Dest-Where+64) mod 64),
	Diff >= 32,
	MoveQuantity is max(-8, 64-Diff).

max_buy( Seller, MoveQuantity ):-
	% Returns max amount you can buy from Seller
	player(greedy_agent, WL, Cash, VL, _, _),
	place(Seller, _, Item, SQ, Price, seller),
	item( Item, IW, IV),
	WLim is WL/IW,
	VLim is VL/IV,
	CLim is Cash/Price,
	min_list([WLim,VLim, CLim],OurLim),
	MoveQuantity is min(OurLim,SQ).


max_sell( Buyer, MoveQuantity ):-
	% Returns max amount you can buy from Seller
	% Sell everything you're holding
	place(Buyer, _,Item,_,_,_),
	holding(greedy_agent, Item, MoveQuantity).


















