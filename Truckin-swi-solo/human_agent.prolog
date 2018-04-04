agent_name(human_agent).

update_from_ref(P):-
	assert(P),
	agent_name(N),
	format('~s got from ref : ~s',N,P).


move(AgentName,MoveType,MoveQuantity):-
	agent_name(AgentName),	%  Make sure the referee has the write agent
	% Some friendly info for the human
	write_agent_status(AgentName),

	% Repeat till the human gives us a legal move ( Humans make mistakes. Your agent should not )
	repeat,
	format('~s: what kind of move? ( m / t )\n', AgentName),
	read(MoveType),
	member(MoveType, [m,t]),
	format(' How many?\n '),
	read(MoveQuantity),
	!.


% Functions specific to this agent. Not part of the interface, No need to replicate in your agent.

write_agent_status(AgentName):-
	% Writes the agent's status.
	% For information only
	
	player(AgentName,W,Cash,V,Fuel,Where),
	place(Where, PlaceName, PlaceItem, PlaceQuantity, PlacePrice, PlaceType ),
	format(
		'\n----\n~s has $~f and ~f fuel (Weight=~f,Volume=~f)',
		[AgentName,Cash,Fuel,W,V]
	),
	format(
		'\nCurrently at ~s (~d):-  ',[PlaceName, Where]
	),
	(	
		(
			member(PlaceType, [buyer,seller] ),
			format('~s of ~s ( ~f available at $~f )\n',
				 [PlaceType, PlaceItem, PlaceQuantity, PlacePrice]
			)
		);
		
		format('( ~s )\n', [PlaceType])

	)
	.

