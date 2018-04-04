% Original World - Never Change
%
%	item(Name, Weight, Volume)
%
item('Anything', 0,0).
item('Beer', 1500,1300).
item('Books', 60000,50000).
item('DE68K minis', 50000,150000).
item('Diamonds', 100,500).
item('Eggs', 800,5000).
item('Fuel', 750,1000).
item('Gold Bars', 3000,500).
item('Mandarins', 1000,2000).
item('Newspapers', 160,1300).
item('Nothing', 0,0).
item('Strawberries', 1000,4000).
item('TVs', 40000,100000).
item('VAXes', 1000000,6000000).
item('Wine', 1200,1000).
%	player(Name, Weight, Cash, Volume, Fuel, Where).
%
%	holding(Name, Item, Quantity).
%
% player('8030052', 2809000,5073,19236000,99,63).
% holding('8030052', 'Strawberries', 191).
% player('8129713', 2784000,73540,19820000,96,4).
% holding('8129713', 'Wine', 180).
% player('8129722', 2799000,103,19196000,99,63).
% holding('8129722', 'Strawberries', 201).
% player('8149461', 2807000,4079,19228000,99,63).
% holding('8149461', 'Strawberries', 193).
%
%	Miscellaneous
%
last_stop(63).         % Board wraps around at place(63,...)
can_carry(3000000).    % 3 tonne in weight
can_hold(20000000).    % 20 cubic meters
max_fuel(100).         % 100 litres of fuel
max_move(8).           % maximum distance truck can move.
start_cash(100000).    % original cash ammount
