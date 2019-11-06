function [x0,v0]= init_ICm_ICm(mapfile, x, p, ap,n)

global civds

civds.n = length(x); % The dimension of x, small n
x0 = [];
civds.NumPars = length(p);

initoption = 2; %as the initializer doesnt produce the first X yet, there are 2 hardcoded X0s from which we choose at the moment, depending on the system we chose
rho = 0;

zerocomponent = 0;

if initoption == 1
    x0 = load 'FC15_init.mat'; %initial x value to start continuer
    x0 = [x0.FC([1:2*civds.n 2*civds.n+2:end]); -0.512; 1.195];
    rho = 4.62505205; % The initial curve radius
elseif initoption == 2
    x0 = [0.5; 0.5; 0.2; 0.4; 0.34641016151; 2; 0];
    rho = 0.16666666666;
    zerocomponent = 1;
end

v0 = []; %initial tangent vectors
civds.rho = rho; % The initial curve radius
civds.mapfile = mapfile; % The map we want to evaluate
func_handles = feval(civds.mapfile);
civds.func = func_handles{2};
civds.zerocomponent = zerocomponent;
