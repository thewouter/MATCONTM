function [x0,v0]= init_FPm_FPm(mapfile, x, p, ap,n)
%
% Defines mapfile
% Sets all parameters for a Fixed Point continuation (p)
% and the active parameter (ap)
%
global fpmds

x0 = [x;p(ap)];
v0 = [];
fpmds.P0 =p;
fpmds.ActiveParams = ap;
fpmds.mapfile = mapfile;
func_handles = feval(fpmds.mapfile);
fpmds.func = func_handles{2};
fpmds.Jacobian  = func_handles{3};
fpmds.JacobianP = func_handles{4};
fpmds.Hessians  = func_handles{5};
fpmds.HessiansP = func_handles{6};
fpmds.Der3      = func_handles{7};
fpmds.Der4      = func_handles{8};
fpmds.Der5      = func_handles{9};
fpmds.Niterations=n;
siz = size(func_handles,2);
if siz > 9
    j=1;
    for i=10:siz
        fpmds.user{j}= func_handles{i};
        j=j+1;
    end
end
fpmds.nphase = size(x,1);
fpmds.v = [];
