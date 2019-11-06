function [x0,v0]= init_PDm_PDm(mapfile, x, p, ap, n, varargin)
%
% Initializes a perioddoubling continuation from a PD point
%
global cds pdmds
% check input
if size(ap,2)~=2
    errordlg('Two active parameters are needed for a PD-curve continuation');
end
% initialize pdmds
pdmds.mapfile = mapfile;
func_handles = feval(pdmds.mapfile);
pdmds.func = func_handles{2};
pdmds.Jacobian  = func_handles{3};
pdmds.JacobianP = func_handles{4};
pdmds.Hessians  = func_handles{5};
pdmds.HessiansP = func_handles{6};
pdmds.Der3      = func_handles{7};
pdmds.Der4      = func_handles{8};
pdmds.Der5      = func_handles{9};
pdmds.Niterations=n;
siz = size(func_handles,2);
if siz > 9
    j=1;
    for i=10:siz
        pdmds.user{j}= func_handles{i};
        j=j+1;
    end
end

pdmds.nphase = size(x,1);
pdmds.ActiveParams = ap;
pdmds.P0 = p;
if size(varargin,1)>0,pdmds.BranchParams=varargin{1};else pdmds.BranchParams=[];end
x0 = x; x0(pdmds.nphase+1:pdmds.nphase+2,:) = pdmds.P0(ap);  
cds.curve = @perioddoublingmap; 
cds.ndim = length(x)+2; 
[x,p] =rearr(x0); p = n2c(p);
curvehandles = feval(cds.curve);
cds.curve_func = curvehandles{1}; 
cds.curve_options = curvehandles{3};
cds.curve_jacobian = curvehandles{4};
cds.curve_hessians = curvehandles{5};
cds.options = feval(cds.curve_options);
cds.options = contset(cds.options,'Increment',1e-5); 
jac = pdmjac(x,p,n)+eye(pdmds.nphase);
% calculate eigenvalues
V = eig(jac);
[Y,i] = min(abs(V));
% ERROR OR WARNING
RED = jac-V(i)*eye(pdmds.nphase);
pdmds.borders.v = real(null(RED));
pdmds.borders.w = real(null(RED'));
v0=[];
rmfield(cds,'options');

% ---------------------------------------------------------------
function [x,p] = rearr(x0)
% [x,p] = rearr(x0)
% Rearranges x0 into coordinates (x) and parameters (p)
global cds pdmds
nap = length(pdmds.ActiveParams);
nphase = cds.ndim-nap;
p = pdmds.P0;
p(pdmds.ActiveParams) = x0((nphase+1):end);
x = x0(1:nphase);



