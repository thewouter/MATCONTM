function out = fixedpointmap
%
% Fixed Point of  Map curve definition file for a problem in mapfile
% 

global cds fpmds
    out{1}  = @curve_func;
    out{2}  = @defaultprocessor;
    out{3}  = @options;
    out{4}  = @jacobian;
    out{5}  = @hessians;
    out{6}  = @testf;
    out{7}  = @userf;
    out{8}  = @process;
    out{9}  = @singmat;
    out{10} = @locate;
    out{11} = @init;
    out{12} = @done;
    out{13} = @adapt;
return
%-------------------------------------------------------
function func = curve_func(arg)
global fpmds cds
[x,p] = rearr(arg); p = n2c(p);x1=x;
n=fpmds.Niterations;
for i=1:n
x1=feval(fpmds.func,0,x1,p{:});
end
func=x1-x;  
%---------------------------------------------------------------
function jac = jacobian(varargin)
global fpmds cds
   x0 = varargin{1}; [x,p] = rearr(x0); p = n2c(p);
   n=fpmds.Niterations;
   jac=[mjac(x,p,n)-eye(cds.ndim-1), mjacp(x,p,n)];
   %---------------------------------------------------------------    
function hess = hessians(varargin)  
global fpmds cds
    n=fpmds.Niterations;
    x0 = varargin{1}; [x,p] =  rearr(x0);p=n2c(p); 
    hh = nhess(x,p,n);
    hp = nhessp(x,p,n);
    x1 = x0; x1(cds.ndim) = x1(cds.ndim) - cds.options.Increment;
    x2 = x0; x2(cds.ndim) = x2(cds.ndim) + cds.options.Increment;
    hpp = (contjac(x2) - contjac(x1)) / (2*cds.options.Increment);
    for i = 1:cds.ndim-1
        hess(:,:,i) = [ hh(:,:,i) hpp(:,i)];
     end
    hess(:,:,cds.ndim) = [ hp(:,:) hpp(:,cds.ndim)]; 
   
%---------------------------------------------------------------
function varargout = defaultprocessor(varargin)
global fpmds cds
  if nargin > 2
    s = varargin{3};
    s.data.v = fpmds.v;
    varargout{3} = s;
  end

  % compute eigenvalues?
  n=fpmds.Niterations;
  if (cds.options.Multipliers==1)
      xo = varargin{1}; [x,p] = rearr(xo); p = n2c(p);
      jac = mjac(x,p,n);
      varargout{2} = eig(jac);
  else
      varargout{2}=nan;
  end  
  % all done succesfully
  varargout{1} = 0;
%-------------------------------------------------------------
function option = options
global fpmds cds
  option = contset;
  % Check for symbolic derivatives in mapfile
  
  symjac  = ~isempty(fpmds.Jacobian);
  symhes = ~isempty(fpmds.Hessians);
  symDer3 = ~isempty(fpmds.Der3);
  symDer4 = ~isempty(fpmds.Der4);
  symDer5 = ~isempty(fpmds.Der5);
  
  symord = 0; 
  if symjac,   symord = 1; end
  if symhes,   symord = 2; end
  if symDer3, symord = 3; end
  if symDer4, symord = 4; end
  if symDer5, symord = 5; end
  

  option = contset(option, 'SymDerivative', symord);
  option = contset(option, 'Workspace', 1);
  option = contset(option, 'Adapt', 0);
  option = contset(option, 'Locators', [0 0 0 1]);

  symjacp = ~isempty(fpmds.JacobianP); 
  symhes = ~isempty(fpmds.HessiansP);
  symordp = 0;
  if symjacp, symordp = 1; end
  if symhes,  symordp = 2; end
  option = contset(option, 'SymDerivativeP', symordp);

  cds.symjac  = 1;%
  cds.symhess = 0;
  %----------------------------------------------------------------
function [out, failed] = testf(id, x, v) 
global cds ws fpmds
[x0,p] = rearr(x); p = n2c(p);
ndim = cds.ndim;
J=contjac(x);%eig(J(:,1:ndim-1)+eye(ndim-1)),pause
out(3) = 0;
failed = [];
for i=id
  lastwarn('');
  
  switch i
     case 1 % NS
       BB= J(:,1:ndim-1)+eye(ndim-1);
       [bialt_M1,bialt_M2,bialt_M3,bialt_M4]=bialtaa(ndim-1);
       BB=BB(bialt_M1).*BB(bialt_M2)-BB(bialt_M3).*BB(bialt_M4);
       BB=BB-eye(size(BB,1));    
       out(1) = det(BB); 
     case 2 % PD
       out(2) = det(J(:,1:ndim-1)+2*eye(ndim-1));%eig(J(:,1:ndim-1)+eye(ndim-1)),pause
     case 3 % LP
       out(3) = v(end);
     case 4 % BP
       B = [J; v'];
       out(4) = det(B);
    otherwise
      error('No such testfunction');
  end
  if ~isempty(lastwarn)
    msg = sprintf('Could not evaluate tf %d\n', i);
    failed = [failed i];
  end
end
%-----------------------------------------------------------------
function [out, failed] = userf(userinf, id, x, v)
global cds fpmds
dim =size(id,2);
failed = [];
for i=1:dim
  lastwarn('');
  [x0,p] = rearr(x); p = n2c(p);
  if (userinf(i).state==1)      
      out(i)=(feval(fpmds.user{id(i)},0,x0,p{:}))';  
  else
      out(i)=0;
  end
  if ~isempty(lastwarn)
    msg = sprintf('Could not evaluate userfunction %s\n', id(i).name);
    failed = [failed i];
  end
end
%---------------------------------------------------------------------
function [failed,s] = process(id, x, v, s)
global cds fpmds
 [x0,p] = rearr(x); p = n2c(p);
 nphase=size(x0,1);
 n=fpmds.Niterations;ndim = cds.ndim; 
 % WM: Removed SL array
 printconsole('label = %s, x = %s \n', s.label , vector2string(x));
 p1=p;
 switch id
  case 1 % NS
    s.data.mprocess_NS = process_NSm(x,n);
    if strcmp(s.data.mprocess_NS,'Neutral saddle')
       s.msg  = sprintf('Neutral saddle\n');    
    else 
     x1=x0;p1=p;   
     jac=mjac(x0,p,n);
     % calculate eigenvalues and eigenvectors
     [V,D] = eig(jac);
     % find pair of complex eigenvalues
     d = diag(D);
     idx1=0;idx2=0;
     for i=1:nphase
        for j=i+1:nphase
            if (d(i)== conj(d(j))) && (imag(d(i))~=0)
                idx1=i;
                idx2=j;
            end
        end
      end
    if (idx1==0)||(imag(d(idx1))==0);
      printconsole('Neutral saddle\n');
      a=[];
      return;
    end
     temp=idx1;
   if imag(d(idx1))>0
      idx1=idx2;
      idx2=temp;
   end  
  [ Q,R]=qr([real(V(:,idx1)) imag(V(:,idx1))]);
  borders.v=Q(:,1:2);
  [V,D] = eig(jac');
   % find pair of complex eigenvalues
  d  = diag(D);
  idx1=0;idx2=0;
  for i=1:nphase-1
    for j=i+1:nphase
      if (d(i)== conj(d(j))) && (imag(d(i))~=0)
        idx1=i;idx2=j;
      end
    end
  end
  if idx1==0;
    printconsole('Neutral saddle\n');
    a=[];
    return;
  end 
  temp=idx1;
  if imag(d(idx1))< 0
    idx1=idx2;
    idx2=temp;
  end 
  [Q,R]=qr([real(V(:,idx1)) imag(V(:,idx1))]);
  borders.w=Q(:,1:2);
  RED=jac*jac-2*real(d(idx1))*jac+eye(nphase);
  jacp=mjacp(x0,p,n);
  A=[jac  jacp zeros(nphase,1)];
  [Q,R]=qr(A');
  Bord=[RED borders.w;borders.v' zeros(2)];
  bunit=[zeros(nphase,2);eye(2)];
  vext=Bord\bunit;
  wext=Bord'\bunit;
  alpha=vext(1:nphase,1)'*(jac*vext(1:nphase,2)-d(idx1)*vext(1:nphase,2));
  beta=-vext(1:nphase,1)'*(jac*vext(1:nphase,1)-d(idx1)*vext(1:nphase,1));
  q=alpha*vext(1:nphase,1)+beta*vext(1:nphase,2);
  alpha=wext(1:nphase,1)'*(jac'*wext(1:nphase,2)-d(idx2)*wext(1:nphase,2));
  beta=-wext(1:nphase,1)'*(jac'*wext(1:nphase,1)-d(idx2)*wext(1:nphase,1));
  p=alpha*wext(1:nphase,1)+beta*wext(1:nphase,2);
  q=q/norm(q);   
  p=p/(q'*p);
  s.msg  = sprintf('Neimark_Sacker');
  A=mjac(x1,p1,n);
  s.data.c=nf_NSm(fpmds.func,fpmds.Jacobian,fpmds.Hessians,fpmds.Der3,A,q,p,nphase,x0,p1,d(idx1),n);
  printconsole(' normal form coefficient of NS = %d\n',s.data.c),
  end
  case 2 %PD
    jac =mjac(x0,p,n);
    [V,D]= eig(jac+eye(nphase));
    [Y,i]=min(abs(diag(D)));
    vext=real(V(:,i));
    vext=vext/norm(vext);
    [V,D]= eig(jac'+eye(nphase));
    [Y,i]=min(abs(diag(D)));
    wext=real(V(:,i));      
    wext=wext/(vext'*wext);
    s.data.q=vext;    
    s.data.b=nf_PDm(fpmds.func,fpmds.Jacobian,fpmds.Hessians,fpmds.Der3,jac,vext,wext,nphase,x0,p,n);
    printconsole(' normal form coefficient of PD = %d\n',s.data.b),    
    s.msg=sprintf('Period_doubling \n');   
  case 3 % LP
    jac =mjac(x0,p,n);
    [V,D]= eig(jac-eye(nphase));
    [Y,i]=min(abs(diag(D)));
    vext=real(V(:,i));
    vext=vext/norm(vext);
    [V,D]= eig(jac'-eye(nphase));
    [Y,i]=min(abs(diag(D)));
    wext=real(V(:,i));      
    wext=wext/(vext'*wext);
    s.data.a =nf_LPm(fpmds.func,fpmds.Jacobian,fpmds.Hessians,vext,wext,x0,p,n);
    printconsole('normal form coefficient of LP =%d\n',s.data.a);
    s.msg=sprintf('Limit point\n');     
  case 4 %BP
    s.msg=sprintf('Branch point\n');  
    s.data.v=v;
end

% Compute eigenvalues for every singularity
J=contjac(x);
if ~issparse(J)
  [v,d]=eig(J(:,1:ndim-1));
else
  opt.disp=0;
  % WM: fixed a bug (incompatability between MatLab 6.0 and 5.5?)
  [v,d]=eigs(J(:,1:ndim-1),min(6,ndim-1),'lm',opt);
end
d=d+eye(nphase);
s.data.evec = v;
s.data.eval = diag(d)';

failed = 0;

%------------------------------------------------------------
function [S,L] = singmat
global fpmds cds
% 0: testfunction must vanish
% 1: testfunction must not vanish
% everything else: ignore this testfunction

  S = [  0 8 8 8
         8 0 8 8 
         8 8 0 1
         8 8 8 0 ];

  L = [ 'NS  ';'PD  '; 'LP  ';'BP  ' ];

%--------------------------------------------------------
function [x,v] = locate(id, x1, v1, x2, v2)
switch id
  case 4
    [x,v] = locateBP(id, x1, v1, x2, v2);
  otherwise
    msg = sprintf('No locator defined for singularity %d', id);
    error(msg);
end
%---------------------------------------------------------
function varargout = init(varargin)
global fpmds cds
  x = varargin{1};
  v = varargin{2};
  WorkspaceInit(x,v);

  % all done succesfully
  varargout{1} = 0;
%---------------------------------------------------------
function varargout = done
global fpmds cds
  WorkspaceDone;

%----------------------------------------------------------  
function [res,x,v] = adapt(x,v)
res = []; % no re-evaluations needed

  


%----------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------

function [x,p] = rearr(x0)
%
% [x,p] = rearr(x0)
%
% Rearranges x0 into coordinates (x) and parameters (p)
global cds fpmds

nap = length(fpmds.ActiveParams);
ncoo = cds.ndim-nap;

p = fpmds.P0;
p(fpmds.ActiveParams) = x0((ncoo+1):end);
x = x0(1:ncoo);

% ---------------------------------------------------------------
function [x,v] = locateBP(id, x1, v1, x2, v2)
global fpmds cds
[x0,p] = rearr(x1); p = n2c(p); 
ndim = cds.ndim;
x = x1;
b = 0;

J = contjac(x1);
%J=fpnjacp(x0,p);
if ~issparse(J)
  [v,d]=eig(J(:,1:ndim-1));
else
  opt.disp=0;
  [v,d]=eigs(J(:,1:ndim-1), 'SM', opt);
end
[y,i]=min(abs(diag(d)));
p = v(:,i);
b = 0;
x = x1;
converged = 0;
i = 0;

u = [x; b; p];

[A,f]=locjac(x,b,p);
while i < cds.options.MaxCorrIters
  
  du = A\f;
  u = u - du;

  x = u(1:ndim);
  b = u(ndim+1);
  p = u(ndim+2:2*ndim);

  [A,f]=locjac(x,b,p);
  
  % WM: VarTol and FunTol were switched
  if norm(du) < cds.options.VarTolerance & norm(f) < cds.options.FunTolerance break; end

  i = i+1;
end

v = 0.5*(v1+v2);

% ---------------------------------------------------------------

function [A, f] = locjac(x, b, p)
% A = mjac of system
% f = system evaluated at (x,b,p)
global cds

ndim = cds.ndim;

II = eye(ndim-1);
J = contjac(x);
H = conthess(x);

F1 = [J, p, b*II];
for j=1:ndim
  for k=j:ndim
    F21(j,k) = H(:,j,k)'*p;
    F21(k,j) = F21(j,k);
  end
end

F22 = zeros(ndim,1);
F23 = J';

F3 = [zeros(1,ndim), 0, 2*p'];

A = [ F1; F21, F22, F23; F3 ];

f = [feval(cds.curve_func, x) + b*p; J(:,1:ndim-1)'*p; p'*J(:,ndim); p'*p-1];

% ---------------------------------------------------------

function WorkspaceInit(x,v)
global cds fpmds
nphase=fpmds.nphase;
  for i=1:cds.nActTest
      if (cds.ActTest(i)==1) && (nphase<2)      
         errordlg(' Neimark-Sacker (NS) is impossible, ignore this singularity by setting opt=contset(opt,''IgnoreSingularity'',[1])');
       %stop
      end
end
% calculate some matrices to efficiently compute bialternate products (without loops)
n = cds.ndim-1;
a = reshape(1:(n^2),n,n);
[bia,bin,bip] = bialt(a);
if any(any(bip))
    [fpmds.BiAlt_M1_I,fpmds.BiAlt_M1_J,fpmds.BiAlt_M1_V] = find(bip);
else
    fpmds.BiAlt_M1_I=1;fpmds.BiAlt_M1_J=1;fpmds.BiAlt_M1_V=n^2+1;
end    
if any(any(bin))
    [fpmds.BiAlt_M2_I,fpmds.BiAlt_M2_J,fpmds.BiAlt_M2_V] = find(bin);
else
     fpmds.BiAlt_M2_I=1;fpmds.BiAlt_M2_J=1;fpmds.BiAlt_M2_V=n^2+1;
end
if any(any(bia))
    [fpmds.BiAlt_M3_I,fpmds.BiAlt_M3_J,fpmds.BiAlt_M3_V] = find(bia);
else
    fpmds.BiAlt_M3_I=1;fpmds.BiAlt_M3_J=1;fpmds.BiAlt_M3_V=n^2+1;
end

% ------------------------------------------------------
function WorkspaceDone

% -------------------------------------------------------


%SD:continues equilibrium of mapfile
