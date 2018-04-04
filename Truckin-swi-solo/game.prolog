% Definitions of the world
:- [board].
:- [world]. 
% The ref and the agents.
:- [solo_ref].
:- [human_agent].		% EDIT TO USE OTHER AGENT

settings( agent, human_agent ). % Set the name of your agent. Make sure you include it using :- [file_name]. % EDIT TO USE OTHER AGENT
settings( moves, 5 ).		% Set the # of moves you want the game to last for.


run_game:-
	ref_reset_dynamic,
	settings( agent, AgentToUse ),
	settings(moves, TotalMoves),
	asserta(moves_remaining(TotalMoves)),
	start_atruck(AgentToUse),
	start_ref,!,
	writeln('\n\n---FINISHED---\n\n').
