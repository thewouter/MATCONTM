function [x0,v0]= init_LPm_LPm(mapfile, x, p, ap,n,varargin)
%
% Initializes a fold continuation from a LP point
%
global cds lpmds
% check input
if size(ap,2)~=2
    errordlg('Two active parameters are needed for a Limitpoint bifurcation curve continuation');
end
% initialize lpmds
lpmds.mapfile = mapfile;
func_handles = feval(lpmds.mapfile);
lpmds.func = func_handles{2};
lpmds.Jacobian  = func_handles{3};
lpmds.JacobianP = func_handles{4};
lpmds.Hessians  = func_handles{5};
lpmds.HessiansP = func_handles{6};
lpmds.Der3      = func_handles{7};
lpmds.Niterations=n;
siz = size(func_handles,2);
if siz > 9
    j=1;
    for i=10:siz
        lpmds.user{j}= func_handles{i};
        j=j+1;
    end
end
lpmds.nphase = size(x,1);
lpmds.ActiveParams = ap;
lpmds.P0 = p;
if size(varargin,1)>0,lpmds.BranchParams=varargin{1};else lpmds.BranchParams=[];end 
cds.curve = @limitpointmap;
x0 = x; x0(lpmds.nphase+1:lpmds.nphase+2,:) = lpmds.P0(ap);
cds.ndim = length(x)+2; 
[x,p] =rearr(x0); p = n2c(p);
curvehandles = feval(cds.curve);
cds.curve_func = curvehandles{1};
cds.curve_options = curvehandles{3};
cds.curve_jacobian = curvehandles{4};
cds.curve_hessians = curvehandles{5}; 
cds.options = feval(cds.curve_options);
cds.options = contset(cds.options,'Increment',1e-5);
n=lpmds.Niterations;
jac =lpmjac(x,p,n)-eye(cds.ndim-2);
% calculate eigenvalues
V = eig(jac);
[Y,i] = min(abs(V));
% ERROR OR WARNING
RED = jac-V(i)*eye(lpmds.nphase);
lpmds.borders.v = real(null(RED));
lpmds.borders.w = real(null(RED'));
v0=[];
rmfield(cds,'options');

% ---------------------------------------------------------------
function [x,p] = rearr(x0)
% [x,p] = rearr(x0)
% Rearranges x0 into coordinates (x) and parameters (p)
global cds lpmds
nap = length(lpmds.ActiveParams);
nphase = cds.ndim-nap;
p = lpmds.P0;
p(lpmds.ActiveParams) = x0((nphase+1):end);
x = x0(1:nphase);
