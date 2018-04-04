:- module(greedy_agent,[]).


:- dynamic
	greedy_choice/2,
	agent_state/1,
	moves_remaining/1,
	place/6,
	player/6,
	holding/3,
	item/3.

agent_name(greedy_agent).

:- [greedy_agent_kb].

:- [greedy_agent_helpers].
init_agent:-
	reset_KB,
	asserta(state(init)).

move(greedy_agent,_,_):-
	agent_state(init),
	set_agent_state(decide_greedy),
	fail.		% Here, Fail is used to make prolog try the next move/3


move(greedy_agent, MoveType, MoveQuantity):-
	% Irrespective of the state, If you have to go home, You have to go home
	needs_to_go_home,
	MoveType = m,
	step_to_go_to( 0, MoveQuantity).


move(greedy_agent,_,_):-
	% Greedily pick the Item with lowest seller and highest buyer
	agent_state(decide_greedy),
	retractall( greedy_choice(_,_) ),
	find_best_item( BestSeller, BestBuyer ),
	asserta( greedy_choice(BestSeller, BestBuyer) ),
	set_agent_state(do_greedy_buy),
	fail.

% do_greedy_buy
move( greedy_agent, MoveType, MoveQuantity ):-
	agent_state( do_greedy_buy ),
	player( greedy_agent, _,_,_,_, Where ),
	greedy_choice( BestSeller, _),
	Where = BestSeller,
	MoveType = t,
	max_buy( BestSeller, MoveQuantity ),
	set_agent_state(do_greedy_sell).

move( greedy_agent, MoveType, MoveQuantity ):-
	agent_state( do_greedy_buy ),
	%player( greedy_agent, _,_,_,_, Where),
	MoveType = m,
	greedy_choice( BestSeller, _),
	step_to_go_to(BestSeller, MoveQuantity).

% do_greedy_sell
move( greedy_agent, MoveType, MoveQuantity ):-
	agent_state( do_greedy_sell ),
	player( greedy_agent, _,_,_,_, Where ),
	greedy_choice( _, BestBuyer),
	Where = BestBuyer,
	MoveType = t,
	max_sell( BestBuyer, MoveQuantity ),
	set_agent_state(do_greedy_buy).


move( greedy_agent, MoveType, MoveQuantity ):-
	agent_state( do_greedy_buy ),
%	player( greedy_agent, _,_,_,_, Where ),
	greedy_choice( _, BestBuyer),
	MoveType = m,
	step_to_go_to(BestBuyer, MoveQuantity).


find_best_item(BestSeller, BestBuyer):-
% Finds the dealers of the item with max price diff
	findall(
		pppdiff(Place1,Place2,PriceDiff), % Just a name for the structure
		(
				place(Place1,_,Item,_,Price1,seller),
				place(Place2,_,_,Item,Price2,buyer),
				PriceDiff is Price2 - Price1
		),
		PPList
	),
	find_max_pricediff( PPList, MaxPriceDiff),
	MaxPriceDiff = pppdiff(BestSeller, BestBuyer, _).

