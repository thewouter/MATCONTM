function out = odefile

% --------------------------------------------------------------------------
function dydt = fun_eval(time,kmrgd,parameters)

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(odefile);
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(time,kmrgd,parameters)
% --------------------------------------------------------------------------
function jacp = jacobianp(time,kmrgd,parameters)
% --------------------------------------------------------------------------
function hess = hessians(time,kmrgd,parameters)
% --------------------------------------------------------------------------
function hessp = hessiansp(time,kmrgd,parameters)
%---------------------------------------------------------------------------
function tens3  = der3(time,kmrgd,parameters)
%---------------------------------------------------------------------------
function tens4  = der4(time,kmrgd,parameters)
%---------------------------------------------------------------------------
function tens5  = der5(time,kmrgd,parameters)