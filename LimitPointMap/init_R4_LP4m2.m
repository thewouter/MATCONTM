function [x0,v0,accepted]= init_R4_LP4m2(mapfile,eps,x,p,ap,n,varargin)
%
% [x0,v0]= init_R4_LP4m2(mapfile,eps,x,p,ap,n)
% Initializes a fold continuation of period 4*n from a R4 point if possible
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
lpmds.Niterations=4*n;
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
cds.ndim = length(x)+2;
%-----Defining Symbolic derivatives-----
  symjac  = ~isempty(lpmds.Jacobian);
  symhes  = ~isempty(lpmds.Hessians);
  symDer3 = ~isempty(lpmds.Der3);
  symord = 0; 
  if symjac, symord = 1; end
  if symhes, symord = 2; end
  if symDer3, symord = 3; end
  cds.options.SymDerivative = symord;
  symjacp  = ~isempty(lpmds.JacobianP); 
  symhessp = ~isempty(lpmds.HessiansP); 
  symordp = 0;
  if symjacp,  symordp = 1; end
  if symhessp, symordp = 2; end
  cds.options.SymDerivativeP = symordp;
%---Branch Switching Algorithm----
  p = n2c(p);nphase = size(x,1);
  A = lpmjac(x,p,n);
  [X,D] = eig(A-exp(sqrt(-1)*pi/2)*eye(nphase));
  [Y,i] = min(abs(diag(D)));
  vext = X(:,i)/norm(X(:,i));
  [X,D] = eig(A'+exp(sqrt(-1)*pi/2)*eye(nphase));
  [Y,i] = min(abs(diag(D)));
  wext = X(:,i)/(X(:,i)'*vext);
  [A0,D0] = nf_R4m(lpmds.func,lpmds.Jacobian,lpmds.Hessians,lpmds.Der3,A,vext,wext,nphase,x,p,n);
  zz = A0(1)*A0(1) + A0(2)*A0(2) - 1.0;
  if (zz <= 0)
    printconsole('Switching not possible!\n');
    accepted=0;
    global initmsg; initmsg = 'Switching not possible';
    x0 = [];
    return;
  else 
    accepted =1;
  end
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  global T1global T2global
  if (cds.options.SymDerivative >= 2)
    T1global=tens1(lpmds.func,lpmds.Jacobian,x,p,n);
    T2global=tens2(lpmds.func,lpmds.Hessians,x,p,n);
  end
  A1 = lpmjacp(x,p,n);   							%jacobianp
  temp = (eye(nphase)-A)\A1;							%temp=(I-A)^{INV}*J1
  s1=[1;0];s2=[0;1];								%define standard vectors
  AA=zeros(nphase,nphase,n);
  x1=x;
  xit=zeros(nphase,n);xit(:,1)=x1;
  AA(:,:,1)=lpmjac(x1,p,1);
  for m=2:n
    x1=feval(lpmds.func,0,x1,p{:});
    xit(:,m)=x1;
    AA(:,:,m)=lpmjac(x1,p,1);
  end
  
  test1 = lphesspvect(xit,p,vext,AA,n)*s1; 						% A1(q,s1)
  test1 = test1 + multilinear2(lpmds.func,vext,temp*s1,x,p,n,hessIncrement);	% +B(q,temp*s1)
  gamma1= wext'*test1;
  test1 = lphesspvect(xit,p,vext,AA,n)*s2; 						% A1(q,s2)
  test1 = test1 + multilinear2(lpmds.func,vext,temp*s2,x,p,n,hessIncrement);    % +B(q,temp*s2)
  gamma2= wext'*test1;
  vv = conj([gamma2;-gamma1])/(gamma1*conj(gamma2)-gamma2*conj(gamma1));
  VV = 2*[ real(vv) -imag(vv) ];
  tan4phi = (A0(1)*A0(2)-sqrt(zz))/(A0(2)*A0(2) - 1);
  dir = VV*inv([0 4;-4 0])*[-tan4phi; -1]*(A0(2)+A0(1)*tan4phi)/(1+tan4phi*tan4phi);	  % parameter direction
  phi0 = atan(tan4phi)/4;
  gamma = 1/sqrt(abs(D0))*exp(sqrt(-1.0)*angle(D0)/4);
  xx = (exp(sqrt(-1.0)*phi0)*gamma*vext + exp(-sqrt(-1.0)*phi0)*conj(gamma)*conj(vext));  % phase direction
  x0=[x + sqrt(eps)*xx ;lpmds.P0(ap) + eps*dir];					  % predicted point
  clear T1global T2global
%-----End of branch prediction-----------------
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
