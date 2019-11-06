function [x,v] = init_Het_Het(mapfile, C, p,ap,J)

global hetds cds

[n1,n2]=size(C);% X=[x1,..., xn2], xi,i=1,...,n2 are  mesh points 
hetds.nphase=n1;
hetds.npoints=n2;
hetds.niteration=J;
hetds.sizep = size(p,1);

% initialize hetds
func_handles = feval(mapfile);
symord = 0; 
symordp = 0;

cds.curve = @heteroclinic;
cds.symjac  = 1; 
cds.symhess = 1;
%%%%%%%%%%
hetds.mapfile = mapfile;
hetds.func = func_handles{2};
hetds.Jacobian  = func_handles{3};
hetds.JacobianP = func_handles{4};
hetds.Hessians  = func_handles{5};
hetds.HessiansP = func_handles{6};
hetds.Der3 = func_handles{7};
hetds.Der4 = func_handles{8};
hetds.Der5 = func_handles{9};
%
siz = size(func_handles,2);
if siz > 9
  j=1;
  for k=10:siz
    hetds.user{j}= func_handles{k};
    j=j+1;
  end
else
  hetds.user=[];
end
hetds.ActiveParams = ap;
hetds.P0 = p;
%%%%%%%%%
curvehandles = feval(cds.curve);
cds.curve_func = curvehandles{1};
cds.curve_options = curvehandles{3};
cds.curve_jacobian = curvehandles{4};
cds.curve_hessians = curvehandles{5};
cds.curve_testf = curvehandles{6};
cds.options = feval(cds.curve_options);
cds.options = contset(cds.options,'Increment',1e-5);

if     ~isempty(func_handles{9}),   symord = 5; 
elseif ~isempty(func_handles{8}),   symord = 4; 
elseif ~isempty(func_handles{7}),   symord = 3; 
elseif ~isempty(func_handles{5}),   symord = 2; 
elseif ~isempty(func_handles{3}),   symord = 1; 
end
if     ~isempty(func_handles{6}),   symordp = 2; 
elseif ~isempty(func_handles{4}),   symordp = 1; 
end
if isempty(cds)
    cds.options = contset();
end

cds.options = contset(cds.options, 'SymDerivative', symord);
cds.options = contset(cds.options, 'SymDerivativeP', symordp);
%
x0=C(:,1);x1=C(:,end); % x0 and x1 are fixed points
%hetds.nu is dimension of the unstable invariant space corresponding to D0
A0 = hetjac(x0,num2cell(p),J);
D0 = eig(A0);
hetds.nu= sum(abs(D0)>1);
%hetds.ns is dimension of the stable invariant space corresponding to D1
A1 = hetjac(x1,num2cell(p),J);
D1 = eig(A1);
hetds.ns = sum(abs(D1)<1);

%  YS and YU, initialized to 0
x=x0;
for i=2:hetds.npoints
    x(end+1:end+hetds.nphase,1)=C(:,i);
end
hetds.YU=zeros(hetds.nphase-hetds.nu,hetds.nu);
for i=1:hetds.nu  
  x=[x;zeros(hetds.nphase-hetds.nu,1)];
end

hetds.YS=zeros(hetds.nphase-hetds.ns,hetds.ns);
for i=1:hetds.ns
 x=[x;zeros(hetds.nphase-hetds.ns,1)];
end

x(end+1,1)=p(ap); %x=(x1,..,xN,YU,YS,ap)^T
v = [];
cds.ndim = length(x);

% ASSIGN SOME VALUES TO HETEROCLINIC FIELDS
% ---------------------------------------

%hetds.YU = zeros(hetds.nphase,hetds.nu);
%hetds.YS = zeros(hetds.nphase,hetds.ns);
% Third parameter = unstable_flag, 
% 1 if we want the unstable space, 0 if we want the stable one

[QU, eigvlU, dimU] = Het_computeBase(A0,1,hetds.nu);
[QS, eigvlS, dimS] = Het_computeBase(A1,0,hetds.ns);
hetds.Q0 = QU;
hetds.Q1 = QS;


% <NN> 
hetds.riccativectorlength = cds.ndim - hetds.npoints * hetds.nphase - 1;

