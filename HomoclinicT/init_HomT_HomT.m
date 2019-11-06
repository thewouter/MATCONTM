function [x0,v0]= init_HomT_HomT(mapfile,X,nphase,nu,ns,p,ap,J)
%
% Initializes a homoclinic tangency continuation from a Hom-LP point
%
global cds homTds
% check input
if size(ap,2)~=2
    errordlg('Two active parameters are needed for a homoclinic tangency curve continuation');
end
% initialize homTds
 %X=[x1,..., xn2]^T, xi,i=1,...,n2 are  mesh points 
homTds.nphase=nphase;
k=size(X,1)-(nu*(homTds.nphase-nu)+ns*(homTds.nphase-ns));
homTds.npoints=k/homTds.nphase;
homTds.Niteration=J;
homTds.sizep = size(p,1);
homTds.mapfile = mapfile;
func_handles = feval(homTds.mapfile);
homTds.func = func_handles{2};
homTds.Jacobian  = func_handles{3};
homTds.JacobianP = func_handles{4};
homTds.Hessians  = func_handles{5};
homTds.HessiansP = func_handles{6};
homTds.Der3      = func_handles{7};
homTds.Niterations=J;
siz = size(func_handles,2);
if siz > 9
    j=1;
    for i=10:siz
        homTds.user{j}= func_handles{i};
        j=j+1;
    end
end

homTds.ActiveParams = ap;
homTds.P0 = p;
homTds.p0(ap) = p(homTds.ActiveParams);
homTds.nu=nu;
homTds.ns=ns;
[x,YS,YU,p] = rearr(X);
p=n2c(p);
% homTds.YS=YS;
% homTds.YU=YU;
x0=[X;(homTds.p0(ap))'];
x1=x(1:nphase,1);
cds.curve = @homoclinicT;
curvehandles = feval(cds.curve);
cds.curve_func = curvehandles{1};
cds.curve_options = curvehandles{3};
cds.curve_jacobian = curvehandles{4};
cds.curve_hessians = curvehandles{5}; 
cds.options = feval(cds.curve_options);
cds.options.Increment =1e-5;
A1= homT_jac(x1,p,J);
[QU, eigvlU, dimU] = HomT_computeBase(A1,1,homTds.nu);
[QS, eigvlS, dimS] = HomT_computeBase(A1,0,homTds.ns);
homTds.Q0 = QU;
homTds.Q1 = QS;
cds.ndim = length(x0)+2;

jac =BVP_HomT_jac(x,YS,YU,p);
[U,S,V]=svd(full(jac));
homTds.b=U(:,end);
homTds.c=V(:,end);
v0=[];
%rmfield(cds,'options'); 
% ---------------------------------------------------------------
function [x,YS,YU,p] = rearr(x1)
% Rearranges x1 into all of its components
global homTds

ap=homTds.ActiveParams;
x = x1(1:homTds.nphase*homTds.npoints,1);
p = homTds.P0;
idx=homTds.npoints*homTds.nphase;
ju=homTds.nphase-homTds.nu;
js=homTds.nphase-homTds.ns;
YU = reshape(x1(idx+1:idx+ju*homTds.nu,1),homTds.nphase-homTds.nu,homTds.nu);
idx = idx + ju*homTds.nu;
YS = reshape(x1(idx+1:idx+js*homTds.ns,1),homTds.nphase-homTds.ns,homTds.ns);
idx = idx + js*homTds.ns;x1(end,1);
p(homTds.ActiveParams) = p(ap);
