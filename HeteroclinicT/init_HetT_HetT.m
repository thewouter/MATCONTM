function [x0,v0]= init_HetT_HetT(mapfile, X,nphase,nu,ns, p,ap,J)
%
% Initializes a heteroclinic tangency continuation from a Het-LP
%
global cds hetTds
% check input
if size(ap,2)~=2
    errordlg('Two active parameters are needed for a heteroclinic tangency curve continuation');
end
% initialize hetTds
% X=[x1,..., xn2]^T, xi,i=1,...,n2 are  mesh points 
hetTds.nphase=nphase;
k=size(X,1)-((nphase-nu)*nu+(nphase-ns)*ns);
hetTds.npoints=k/hetTds.nphase;
hetTds.niteration=J;
hetTds.sizep = size(p,1);
hetTds.mapfile = mapfile;
func_handles = feval(hetTds.mapfile);
hetTds.func = func_handles{2};
hetTds.Jacobian  = func_handles{3};
hetTds.JacobianP = func_handles{4};
hetTds.Hessians  = func_handles{5};
hetTds.HessiansP = func_handles{6};
hetTds.Der3      = func_handles{7};
hetTds.Niterations=J;
siz = size(func_handles,2);
if siz > 9
    j=1;
    for i=10:siz
        hetTds.user{j}= func_handles{i};
        j=j+1;
    end
end

hetTds.ActiveParams = ap;
hetTds.P0 = p;
hetTds.p0(ap) = p(hetTds.ActiveParams);
hetTds.nu=nu;
hetTds.ns=ns;
[x,YS,YU,p] = rearr(X);
% hetTds.YS=YS;
% hetTds.YU=YU;
x0=[X;(hetTds.p0(ap))'];
x1=x(1:nphase,1);xN=x(end-nphase+1:end,1);
A1 = hetT_jac(x1,p,J);
AN = hetT_jac(xN,p,J);
[QU, eigvlU, dimU] = Het_computeBase(A1,1,hetTds.nu);
[QS, eigvlS, dimS] = Het_computeBase(AN,0,hetTds.ns);
hetTds.Q0 = QU;
hetTds.Q1 = QS;
cds.ndim = length(x0)+2; 
cds.curve = @heteroclinicT;
curvehandles = feval(cds.curve);
cds.curve_func = curvehandles{1};
cds.curve_options = curvehandles{3};
cds.curve_jacobian = curvehandles{4};
cds.curve_hessians = curvehandles{5}; 
cds.options = feval(cds.curve_options);
cds.options = contset(cds.options,'Increment',1e-5);
jac =BVP_HetT_jac(x,YS,YU,p);

[U,S,V]=svd(full(jac));
hetTds.b=U(:,end);
hetTds.c=V(:,end);
v0=[];
rmfield(cds,'options'); 

% ---------------------------------------------------------------
function [x,YS,YU,p] = rearr(x1)
% Rearranges x1 into all of its components
global hetTds
ap=hetTds.ActiveParams;
x = x1(1:hetTds.nphase*hetTds.npoints,1);
p = hetTds.P0;
idx=hetTds.npoints*hetTds.nphase;
ju=hetTds.nphase-hetTds.nu;
js=hetTds.nphase-hetTds.ns;
YU = reshape(x1(idx+1:idx+ju*hetTds.nu,1),hetTds.nphase-hetTds.nu,hetTds.nu);
idx = idx + ju*hetTds.nu;
YS = reshape(x1(idx+1:idx+js*hetTds.ns,1),hetTds.nphase-hetTds.ns,hetTds.ns);
idx = idx + js*hetTds.ns;x1(end,1);
p(hetTds.ActiveParams) = p(ap);


