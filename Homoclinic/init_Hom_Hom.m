function [x,v] = init_Hom_Hom(mapfile, C, p,ap,J)
%
% Initializes a homoclinic orbit continuation from a Hom point
%
global homds cds
% 
[n1,n2]=size(C);% X=[x1,..., xn2], xi,i=1,...,n2 are  mesh points 
homds.nphase=n1;
homds.npoints=n2;
homds.niteration=J;
homds.sizep = size(p,1);

% initialize homds
func_handles = feval(mapfile);
symord = 0; 
symordp = 0;
%
homds.mapfile = mapfile;
homds.func = func_handles{2};
homds.Jacobian  = func_handles{3};
homds.JacobianP = func_handles{4};
homds.Hessians  = func_handles{5};
homds.HessiansP = func_handles{6};
homds.Der3 = func_handles{7};
homds.Der4 = func_handles{8};
homds.Der5 = func_handles{9};
siz = size(func_handles,2);
if siz > 9
  j=1;
  for k=10:siz
    homds.user{j}= func_handles{k};
    j=j+1;
  end
else
  homds.user=[];
end
homds.ActiveParams = ap;
homds.P0 = p;
cds.curve = @homoclinic;
cds.symhess = 1;
cds.symjac  = 1; 
curvehandles = feval(cds.curve);
cds.curve_func = curvehandles{1};
cds.curve_options = curvehandles{3};
cds.curve_jacobian = curvehandles{4};
cds.curve_hessians = curvehandles{5};
cds.curve_testf = curvehandles{6};
cds.options = feval(cds.curve_options);

if     ~isempty(func_handles{9}),   symord = 5; 
elseif ~isempty(func_handles{8}),   symord = 4; 
elseif ~isempty(func_handles{7}),   symord = 3; 
elseif ~isempty(func_handles{5}),   symord = 2; 
elseif ~isempty(func_handles{3}),   symord = 1;
end
if     ~isempty(func_handles{6}),   symordp = 2; 
elseif ~isempty(func_handles{4}),   symordp = 1; 
end
if isempty(cds.options)
    cds.options = contset();
end

cds.options.Increment=1e-5;
cds.options = contset(cds.options, 'SymDerivative', symord);
cds.options = contset(cds.options, 'SymDerivativeP', symordp);

x0=C(:,1); % x0 is saddle fixed point
A0 = homjac(x0,num2cell(p),J);
D0 = eig(A0);
%homds.nu is dimension of the unstable invariant space corresponds to D0
homds.nu = sum(abs(D0)>1);
homds.ns = homds.nphase-homds.nu;

x=x0;
for i=2:homds.npoints
    x(end+1:end+homds.nphase,1)=C(:,i);
end

%  YS and YU, initialized to 0
% homds.YU=zeros(homds.nphase-homds.nu,homds.nu);
for i=1:homds.nu
   x=[x;zeros(homds.nphase-homds.nu,1)];
end
% 
% homds.YS=zeros(homds.nphase-homds.ns,homds.ns);
for i=1:homds.ns
  x=[x;zeros(homds.nphase-homds.ns,1)];
end

x(end+1,1)=p(ap);  %x=(x1,..,xN,YU,YS,ap)^T
v = [];
cds.ndim = length(x);

% ASSIGN SOME VALUES TO HETEROCLINIC FIELDS
% ---------------------------------------
% Third parameter = unstable_flag, 
% 1 if we want the unstable space, 0 if we want the stable one

[QU, eigvlU, dimU] = Hom_computeBase(A0,1,homds.nu);
[QS, eigvlS, dimS] = Hom_computeBase(A0,0,homds.ns);
homds.Q0 = QU;
homds.Q1 = QS;

% <NN> 
homds.riccativectorlength = cds.ndim - homds.npoints * homds.nphase - 1;
