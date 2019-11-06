%
% Connections
% Compute homoclinic and heteroclinic orbits in the Generalized Henon map.
% We sequentially call all the testruns.
%
disp('Testing Homoclinic Continuation')
Homtestrun
disp('Testing Homoclinic Tangency Continuation')
HomTtestrun
HomTtestrun2

disp('Testing Heteroclinic Continuation')
Hettesthenon
Hettestrun

disp('Testing Heteroclinic Tangency Continuation')
HetTtestrun

disp('Testing Connecting Continuation in higher dimension')
Homtestrun3D
Hettestrun3D