function [x0,v0]= init_PDm_FP2m(mapfile, x, p, s, h,n)
% 
% Starts fixed point of 2nd iterate continuation from PD
%

global fpmds cds
x0 = [x;p(fpmds.ActiveParams)];
v0=s.data.q;
fpmds.P0 = p;
fpmds.mapfile = mapfile;
if ~isfield(s.data,'q') 
    [x0,v0] = init_FPm_FPm(mapfile,x,p,fpmds.ActiveParams,n);
    return
else
    fpmds.q = s.data.q;
end  
func_handles = feval(fpmds.mapfile);
fpmds.func = func_handles{2};
fpmds.Jacobian  = func_handles{3};
fpmds.JacobianP = func_handles{4};
fpmds.Hessians  = func_handles{5};
fpmds.HessiansP = func_handles{6};
fpmds.Niterations=2*n;
siz = size(func_handles,2);
if siz > 9
    for i=10:siz;
        fpmds.user{i-9}= func_handles{i};
    end
end
v0=[v0;0];
x0 = x0+h*v0;
