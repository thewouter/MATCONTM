function out = perioddoublingmap
%
% Perioddoubling curve definition file for a problem in mapfile
% 
global cds pdmds
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

%----------------------------------------------------
function func = curve_func(arg)
  global cds pdmds
  n=pdmds.Niterations;
  [x,p] = rearr(arg); p = n2c(p);x1=x;
  jac = pdmjac(x,p,n);
  Bord=[jac+eye(pdmds.nphase) pdmds.borders.w;pdmds.borders.v' 0];
  bunit=[zeros(pdmds.nphase,1);1];
  vext=Bord\bunit;
  %wext=Bord'\bunit;
  for i=1:pdmds.Niterations
  x1=feval(pdmds.func,0,x1,p{:});
  end
  func = [x1-x ; vext(end)];
  
  %---------------------------------------------------     
function jac = jacobian(varargin)
global cds pdmds
  n=pdmds.Niterations;
  nap = length(pdmds.ActiveParams);
  xo = varargin{1}; [x,p] = rearr(xo); p = n2c(p);
  nphase=size(x,1);
  jac = pdmjac(x,p,n)+eye(pdmds.nphase);
  Bord=[jac pdmds.borders.w;pdmds.borders.v' 0]; 
  bunit=[zeros(pdmds.nphase,1);1];
  vext=Bord\bunit;
  wext=Bord'\bunit;
  jac = [pdmjac(x,p,n)-eye(pdmds.nphase) pdmjacp(x,p,n)]; 
  wext=wext(1:pdmds.nphase);vext=vext(1:pdmds.nphase);
  x1=x;
  xit=zeros(nphase,n);xit(:,1)=x;
  AA=zeros(nphase,nphase,n);
  AA(:,:,1)=pdmjac(x1,p,1);
  for m=2:n
    x1=feval(pdmds.func,0,x1,p{:});
    xit(:,m)=x1;
    AA(:,:,m)=pdmjac(x1,p,1);
  end
  hh=pdvecthessvect(xit,p,vext,wext',AA,n); %
  for i=1:pdmds.nphase
   jac(pdmds.nphase+1,i)=hh(:,i);
  end
  ss=pdvecthesspvect(xit,p,vext,wext',AA,n);%
  for i=1:nap
   jac(pdmds.nphase+1,pdmds.nphase+i)=ss(:,i);
  end

%---------------------------------------------------
function hess = hessians(varargin)
  hess =[];
%---------------------------------------------------
function varargout = defaultprocessor(varargin)
global pdmds cds
  n=pdmds.Niterations;
  if nargin > 2
    s = varargin{3};
    varargout{3} = s;
  end
  % compute eigenvalues?
  if (cds.options.Multipliers==1)
      xo = varargin{1}; [x,p] = rearr(xo); p = n2c(p);
      n=pdmds.Niterations;
      jac =pdmjac(x,p,n);
      varargout{2} = eig(jac);
  else
      varargout{2} = nan;
  end  

  % all done succesfully
  varargout{1} = 0;
%----------------------------------------------------  
function option = options
global pdmds cds
  option = contset;
  n=pdmds.Niterations;
  % Check for symbolic derivatives in mapfile
  
  symjac  = ~isempty(pdmds.Jacobian);
  symhes = ~isempty(pdmds.Hessians);
  symDer3 = ~isempty(pdmds.Der3);
  symDer4 = ~isempty(pdmds.Der4);
  symDer5 = ~isempty(pdmds.Der5);
  
  symord = 0; 
  if symjac, symord = 1; end
  if symhes, symord = 2; end
  if symDer3, symord = 3; end
  if symDer4, symord = 4; end
  if symDer5, symord = 5; end

  option = contset(option, 'SymDerivative', symord);
  option = contset(option, 'Workspace', 1);
  option = contset(option, 'Locators', [0 0 0]);

  symjacp = ~isempty(pdmds.JacobianP); 
  symhessp = ~isempty(pdmds.HessiansP); 
  symordp = 0;
  if symjacp,  symordp = 1; end
  if symhessp, symordp = 2;end
  option = contset(option,'SymDerivativeP',symordp);
  cds.symjac  = 1;%1
  cds.symhess = 1;%1

% -------------------------------------------------------
function [out, failed] = testf(id, x, v)
global cds pdmds 
  n=pdmds.Niterations;
  [x0,p] = rearr(x); p = n2c(p);
  nphase=size(x0,1);
  jac = pdmjac(x,p,n);
  Bord=[jac+eye(nphase) pdmds.borders.w;pdmds.borders.v' 0];
  bunit=[zeros(pdmds.nphase,1);1];
  vext=Bord\bunit;
  vext=vext(1:pdmds.nphase);
  wext=Bord'\bunit;
  wext=wext(1:pdmds.nphase);
  jac = pdmjac(x0,p,n);
  failed = [];

for i=id
  lastwarn('');
  
  switch i
    case 1 % R2
      out(1)=wext'*vext;
    case 2 % fold+flip
      out(2)=det(pdmjac(x,p,n)-eye(pdmds.nphase));
    case 3 % PDNS
      nphase = pdmds.nphase;
      BB= pdmjac(x,p,n);
      [bialt_M1,bialt_M2,bialt_M3,bialt_M4]=bialtaa(nphase);
      BBB=BB(bialt_M1).*BB(bialt_M2)-BB(bialt_M3).*BB(bialt_M4);
      BBB=BBB-eye(size(BBB,1)); 
      out(3) = det(BBB);
    case 4 %GPD
      vext4=vext/norm(vext);
      wext4=wext/(vext'*wext);
      out(4) = nf_PDm(pdmds.func,pdmds.Jacobian,pdmds.Hessians,pdmds.Der3,jac,vext4,wext4,nphase,x0,p,n);
    otherwise
    msg = sprintf('Could not evaluate tf %d\n', i);
    failed = [failed i];
  end
end

%------------------------------------------------------
function [out, failed] = userf(userinf, id, x, v)
global cds pdmds
n=pdmds.Niterations;
dim =size(id,2);
failed = [];
for i=1:dim
  lastwarn('');
  [x0,p] = rearr(x); p = n2c(p);
  if (userinf(i).state==1)
      out(i)=feval(pdmds.user{id(i)},0,x0,p{:});
  else
      out(i)=0;
  end
  if ~isempty(lastwarn)
    msg = sprintf('Could not evaluate userfunction %s\n', id(i).name);
    failed = [failed i];
  end
end
%---------------------------------------------------------
function [failed,s] = process(id, x, v, s)
global cds pdmds
  n=pdmds.Niterations;
  [x0,p] = rearr(x); p = n2c(p);
  nphase=size(x0,1);
  jac = pdmjac(x0,p,n);%eig(jac),x0,pause
  Bord=[jac+eye(nphase) pdmds.borders.w;pdmds.borders.v' 0];
  bunit=[zeros(pdmds.nphase,1);1];
  vext=Bord\bunit;
  vext=vext(1:pdmds.nphase);
  wext=Bord'\bunit;
  wext=wext(1:pdmds.nphase); 
  failed = []; 

% WM: Removed SL array
printconsole('label = %s, x = %s \n', s.label , vector2string(x)); 
switch id
  case 1 % R2
    [V,D]=eig(jac+eye(nphase));
    [Y,i]=min(abs(diag(D)));
    vext2=real(V(:,i));
    mu = norm(vext2); 
    vext2=vext2/mu;  
    [V,D]=eig(jac'+eye(nphase));
    [Y,i]=min(abs(diag(D)));
    wext2=real(V(:,i));
    Bord=[jac+eye(nphase) wext2; vext2' 0];
    genvext2=Bord\[vext2;0];
    genvext2=genvext2(1:nphase)/mu;
    genvext2 = genvext2 - (vext2'*genvext2)*vext2;
    genwext2=Bord'\[wext2;0];
    genwext2=genwext2(1:nphase);
    mu=vext2'*genwext2;
    wext2=wext2/mu;
    genvext2 = genvext2 - (genwext2'*genvext2)*vext2;
    genwext2=genwext2/mu;
    s.data.c=nf_R2m(pdmds.func,pdmds.Jacobian,pdmds.Hessians,pdmds.Der3,jac,vext2,genvext2,wext2,genwext2,nphase,x0,p,n);
    printconsole('Normal form coefficient for R2 :[c , d]= %d, %d\n',s.data.c),
    s.msg  = sprintf('Resonance 1:2');
  case 2 % LPPD
    A=jac;
    [X,D] = eig(A-eye(nphase));
    [Y,i] = min(abs(diag(D)));
    vext2 = real(X(:,i));
    [X,D] = eig(A'-eye(nphase));
    [Y,i] = min(abs(diag(D)));
    wext2 =real(X(:,i));
    q1 = vext/norm(vext);p1 = wext/(wext'*q1);
    q0 = vext2/norm(vext2);p0 = wext2/(wext2'*q0);   
    s.data.c=nf_LPPDm(pdmds.func,pdmds.Jacobian,pdmds.Hessians,pdmds.Der3,A,q0,p0,q1,p1,nphase,x0,p,n);   
    printconsole('Normal form coefficient for LPPD :[a/e , be]= %d, %d, \n',s.data.c(1:2));
    if s.data.c(2)>0
      printconsole('First Lyapunov coefficient for second iterate = %d, \n',s.data.c(2));
    end
    s.msg  = sprintf('LPPD');   
  case 3 % PDNS
    s.data.process_NS = process_flipNS(x,jac);
    if strcmp(s.data.process_NS,'Neutral saddle')
      s.msg  = sprintf('Neutral saddle\n');
    else
      k1=process_flipNS(x,jac);
      d11=k1+sqrt(-1.0)*abs(sqrt(1-k1*k1));
      d22=conj(d11);
      [V,D]=eig(jac-d11*eye(nphase));
      [Y,i]=min(abs(diag(D)));
      vext1=V(:,i);
      [V,D]=eig(jac'-d22*eye(nphase));
      [Y,i]=min(abs(diag(D)));
      wext1=V(:,i);
      vext1=vext1/norm(vext1);
      wext1=wext1/(vext1'*wext1);
      [V,D]=eig(jac+eye(nphase));
      [Y,i]=min(abs(diag(D)));
      vext2=real(V(:,i));
      [V,D]=eig(jac'+eye(nphase));
      [Y,i]=min(abs(diag(D)));
      wext2=real(V(:,i)); 
      vext2=vext2/norm(vext2);
      wext2=wext2/(vext2'*wext2);
      s.data.c=nf_PDNSm(pdmds.func,pdmds.Jacobian,pdmds.Hessians,pdmds.Der3,jac,vext2,wext2,vext1,wext1,nphase,x0,p,n);
      printconsole('Normal form coefficient for PDNS :[a , b , c , d]= %d, %d, %d, %d\n',s.data.c);
      s.msg  = sprintf('Flip+Neimark_Sacker');
    end
  case 4 % GPD
    vext4=vext/norm(vext);
    wext4=wext/(wext'*vext4);       
    s.data.c=nf_DPDm(pdmds.func,pdmds.Jacobian,pdmds.Hessians,pdmds.Der3,pdmds.Der4,pdmds.Der5,jac,vext4,wext4,nphase,x0,p,n); 
    printconsole('Normal form coefficient of GPD = %s\n', s.data.c);     
    s.msg  = sprintf('Generalized Flip');
  otherwise
    s.msg = sprintf('there is not such bifurcation');
end

% Compute eigenvalues for every singularity
[x0,p] = rearr(x); p = n2c(p); 
J=pdmjac(x0,p,n); 
if ~issparse(J)
  [v,d]=eig(J);
else
  opt.disp=0;
  [v,d]=eigs(J,min(6,ndim-2),'lm',opt);
end

s.data.evec = v;
s.data.eval = diag(d)';

failed = 0;
%--------------------------------------------------------
function  [S,L] = singmat    
global pdmds cds
% 0: testfunction must vanish
% 1: testfunction must not vanish
% everything else: ignore this testfunction

  S = [  0 8 8 8 
         8 0 8 8
         1 8 0 8
         8 8 8 0 ]; 
  L = [ 'R2  '; 'LPPD'; 'PDNS'; 'GPD '];
  
%------------------------------------------------------
function [x,v] = locate(id, x1, v1, x2, v2)
msg = sprintf('No locator defined for singularity %d', id);
error(msg);
%------------------------------------------------------
function varargout = init(varargin)
global cds pdmds
  x = varargin{1};
  v = varargin{2};
  WorkspaceInit(x,v);

  % all done succesfully
  varargout{1} = 0;
%--------------------------------------------------------
function varargout = done
global pdmds cds
  WorkspaceDone;
%---------------------------------------------------------
function [res,x,v] = adapt(x,v)
global pdmds
[x1,p] =rearr(x); p = n2c(p);n=pdmds.Niterations; 
jac = pdmjac(x1,p,n)+eye(pdmds.nphase);
Bord=[jac pdmds.borders.w;pdmds.borders.v' 0];
bunit=[zeros(pdmds.nphase,1);1];
vext=Bord\bunit;
wext=Bord'\bunit;
%ERROR OR WARNING
pdmds.borders.v=vext(1:pdmds.nphase)/norm(vext(1:pdmds.nphase));
pdmds.borders.w=wext(1:pdmds.nphase)/norm(wext(1:pdmds.nphase));
res = []; % no re-evaluations needed




%----------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------
function [x,p] = rearr(x0)
%
% [x,p] = rearr(x0)
%
% Rearranges x0 into coordinates (x) and parameters (p)
global pdmds
p = pdmds.P0;
p(pdmds.ActiveParams) = x0((pdmds.nphase+1):end);
x = x0(1:pdmds.nphase);

    
% ---------------------------------------------------------

function WorkspaceInit(x,v)
global cds pdmds opt
n = pdmds.nphase;
  for i=1:cds.nActSing
    if (cds.ActSing(i)==3)&& (n<3) 
       % errordlg('Flip+Neimark-Sacker (PDNS) is impossible, ignore this singularity by setting opt=contset(opt,''IgnoreSingularity'',[3])');
        %stop
    end
    if ((cds.ActSing(i)==1)| (cds.ActSing(i)==2))&& (n <2) 
        %errordlg('R2 and fold+flip (LPPD) are impossible, it is better to ignore these singularities by setting opt=contset(opt,''IgnoreSingularity'',[1 2])');
        
    end
  end


% calculate some matrices to efficiently compute bialternate products (without loops)
a = reshape(1:(n^2),n,n);
b = zeros(n);
[bia,bin,bip] = bialt(a);
[pdmds.BiAlt_M1_I,pdmds.BiAlt_M1_J,pdmds.BiAlt_M1_V] = find(bip);
[pdmds.BiAlt_M2_I,pdmds.BiAlt_M2_J,pdmds.BiAlt_M2_V] = find(bin);
[pdmds.BiAlt_M3_I,pdmds.BiAlt_M3_J,pdmds.BiAlt_M3_V] = find(bia);

% ------------------------------------------------------

function WorkspaceDone

% -------------------------------------------------------
%SD:continues equilibrium of mapfile
