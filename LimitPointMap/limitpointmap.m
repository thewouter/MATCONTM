function out = limitpointmap
%
% Fixed point curve definition file for a problem in mapfile
% 
global cds lpmds 
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
global cds lpmds
  [x,p] = rearr(arg); p = n2c(p);
  x1=x;n=lpmds.Niterations;
  jac=lpmjac(x1,p,n);
  Bord=[jac-eye(lpmds.nphase) lpmds.borders.w;lpmds.borders.v' 0];
  bunit=[zeros(lpmds.nphase,1);1];
  vext=Bord\bunit;
  wext=Bord'\bunit;
  for i=1:lpmds.Niterations
      x1=feval(lpmds.func,0,x1,p{:});
  end
  func = [x1-x ; vext(end)];
  
  %---------------------------------------------------     
function jac = jacobian(varargin)
global cds lpmds
  n=lpmds.Niterations;
  nap = length(lpmds.ActiveParams); n=lpmds.Niterations; 
  xo = varargin{1}; [x,p] = rearr(xo);p = n2c(p);nphase=size(x,1); 
  jacx=lpmjac(x,p,n)-eye(lpmds.nphase);
  Bord=[jacx lpmds.borders.w;lpmds.borders.v' 0]; 
  bunit=[zeros(lpmds.nphase,1);1];
  vext=Bord\bunit;
  wext=Bord'\bunit;
  jac = [jacx lpmjacp(x,p,n)];
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  vext=vext(1:lpmds.nphase);wext=wext(1:lpmds.nphase);
  AA=zeros(nphase,nphase,n);
  x1=x;xit(:,1)=x1;
  AA(:,:,1)=lpmjac(x1,p,1);
  for m=2:n
    x1=feval(lpmds.func,0,x1,p{:});
    xit(:,m)=x1;
    AA(:,:,m)=lpmjac(x1,p,1);
  end
  hh=lpvecthessvect(xit,p,vext,wext',AA,n);
   for i=1:lpmds.nphase
      jac(lpmds.nphase+1,i)=hh(:,i);
  end
  ss=lpvecthesspvect(xit,p,vext,wext',AA,n);
  for i=1:nap
    jac(lpmds.nphase+1,lpmds.nphase+i)=ss(:,i);
  end
  
%---------------------------------------------------
function hess = hessians(varargin)  
global lpmds cds
    n=lpmds.Niterations;
    xo = varargin{1}; [x,p] =  rearr(xo);p=n2c(p);
    hh = lpmhess(x,p); 
    hp = lpmhessp(x,p);
    x1 = xo; x1(cds.ndim) = x1(cds.ndim) - cds.options.Increment;
    x2 = xo; x2(cds.ndim) = x2(cds.ndim) + cds.options.Increment;
    hpp = (contjac(x2) - contjac(x1)) / (2*cds.options.Increment);
    for i = 1:cds.ndim-1
        hess(:,:,i) = [ hh(:,:,i) hpp(:,i)];
    end
    hess(:,:,cds.ndim) = [ hp(:,:) hpp(:,cds.ndim)]; 
%---------------------------------------------------
function varargout = defaultprocessor(varargin)
global lpmds cds
n=lpmds.Niterations;
  if nargin > 2
    s = varargin{3};
    varargout{3} = s;
  end
   % compute eigenvalues?
  if (cds.options.Multipliers==1)
      xo = varargin{1}; [x,p] = rearr(xo); p = n2c(p);
      n=lpmds.Niterations;
      jac =lpmjac(x,p,n);
      varargout{2} = eig(jac);
  else
      varargout{2} = nan;
  end  

  % all done succesfully
  varargout{1} = 0;
%----------------------------------------------------  
function option = options
global lpmds cds
  option = contset;n=lpmds.Niterations;
  % Check for symbolic derivatives in mapfile
  
  symjac  = ~isempty(lpmds.Jacobian);
  symhes = ~isempty(lpmds.Hessians);
  symDer3 = ~isempty(lpmds.Der3);
   
  symord = 0; 
  if symjac, symord = 1; end
  if symhes, symord = 2; end
  if symDer3, symord = 3; end
  
  option = contset(option, 'SymDerivative', symord);
  option = contset(option, 'Workspace', 1);
  option = contset(option, 'Locators', [0 0 0]);

  symjacp = ~isempty(lpmds.JacobianP); 
  symhessp = ~isempty(lpmds.HessiansP); 
  symordp = 0;
  if symjacp,  symordp = 1; end
  if symhessp, symordp = 2;end
  option = contset(option,'SymDerivativeP',symordp);
 
  cds.symjac  = 1;%1
  cds.symhess = 1;

% -------------------------------------------------------
function [out, failed] = testf(id, x, v)
global cds lpmds 
  n=lpmds.Niterations;
  [x0,p] = rearr(x); p = n2c(p);n=lpmds.Niterations;
  nphase=size(x0,1);
  jac=lpmjac(x0,p,n);%x,eig(jac),pause
  Bord=[jac-eye(lpmds.nphase) lpmds.borders.w;lpmds.borders.v' 0];
  bunit=[zeros(lpmds.nphase,1);1];
  vext=Bord\bunit;
  vext=vext(1:lpmds.nphase);
  wext=Bord'\bunit;
  wext=wext(1:lpmds.nphase);
  failed = [];
     
for i=id
  lastwarn('');
  
  switch i
    case 1 %R1
        
      out(1)=wext'*vext;
    case 2 % FF
      out(2)=det(jac+eye(lpmds.nphase));
    case 3 % FNS
      nphase = lpmds.nphase; 
      BB= jac;
      [bialt_M1,bialt_M2,bialt_M3,bialt_M4]=bialtaa(nphase);
      %BBB=BB(bialt_M1).*BB(bialt_M2)-BB(bialt_M3).*BB(bialt_M4);
      BBB=jac(bialt_M1).*jac(bialt_M2)-jac(bialt_M3).*jac(bialt_M4);
      BBB=BBB-eye(size(BBB,1));
      out(3) = det(BBB);    
      
    case 4 %CP
       out(4)=nf_LPm(lpmds.func,lpmds.Jacobian,lpmds.Hessians,vext,wext,x0,p,n);

    otherwise
      msg = sprintf('Could not evaluate tf %d\n', i);
      failed = [failed i];
  end
end
%------------------------------------------------------
function [out, failed] = userf(userinf, id, x, v)
global cds lpmds
n=lpmds.Niterations;
dim =size(id,2);
failed = [];
for i=1:dim
  lastwarn('');
  [x0,p] = rearr(x); p = n2c(p);
  if (userinf(i).state==1)
      out(i)=feval(lpmds.user{id(i)},0,x0,p{:});
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
global cds lpmds
n=lpmds.Niterations;
ndim = cds.ndim;
[x0,p] = rearr(x); p = n2c(p);xx=x0;n=lpmds.Niterations;
nphase=size(x0,1);
jac=lpmjac(x0,p,n);
Bord=[jac-eye(lpmds.nphase) lpmds.borders.w;lpmds.borders.v' 0];
bunit=[zeros(lpmds.nphase,1);1];
vext=Bord\bunit;
vext=vext(1:lpmds.nphase);
wext=Bord'\bunit;
wext=wext(1:lpmds.nphase);
% WM: Removed SL array
printconsole('label = %s, x = %s \n', s.label , vector2string(x)); 
switch id
  case 1 % R1
    [V,D]=eig(jac-eye(nphase));
    [Y,i]=min(abs(diag(D)));
    vext1=real(V(:,i));
    mu=norm(vext1);
    vext1=vext1/mu;
    [V,D]=eig(jac'-eye(nphase));
    [Y,i]=min(abs(diag(D)));
    wext1=real(V(:,i));
    Bord=[jac-eye(nphase) wext1; vext1' 0];
    genvext1=Bord\[vext1;0];
    genvext1=genvext1(1:nphase)/mu;
    genvext1=genvext1-(vext1'*genvext1)*vext1;
    genwext1=Bord'\[wext1;0];
    genwext1=genwext1(1:nphase);
    mu = vext1'*genwext1;
    wext1 = wext1/mu;  
    genwext1 = genwext1 - (genwext1'*genvext1)*wext1;
    s.data.c=nf_R1m(lpmds.func,lpmds.Jacobian,lpmds.Hessians,jac,vext1,genvext1,wext1,genwext1,nphase,x0,p,n);
    printconsole(' normal form coefficient of R1 = %d\n',s.data.c), 
    s.msg  = sprintf('Resonance 1:1');
  case 2 % LPPD
    A=jac;
    [X,D] = eig(A+eye(nphase));
    [Y,i] = min(abs(diag(D)));
    vext2 = real(X(:,i));
    [X,D] = eig(A'+eye(nphase));
    [Y,i] = min(abs(diag(D)));
    wext2 = real(X(:,i));
    vext = vext/norm(vext);wext = wext/(wext'*vext);
    vext2 = vext2/norm(vext2);wext2 = wext2/(wext2'*vext2);
    s.data.c=nf_LPPDm(lpmds.func,lpmds.Jacobian,lpmds.Hessians,lpmds.Der3,jac,vext,wext,vext2,wext2,nphase,x0,p,n);
    printconsole('Normal form coefficient for LPPD :[a/e , be]= %d, %d, \n',s.data.c(1:2));
    
    if s.data.c(2)>0
        %printconsole('First Lyapunov coefficient for second iterate = %d, \n',s.data.c(3));
        printconsole('First Lyapunov coefficient for second iterate = %d, \n',s.data.c(2));
    end
    s.msg  = sprintf('Fold+Flip'); 
  case 3 % LPNS
      s.data.process_NS = process_mfoldNS(x,jac);
      if strcmp(s.data.process_NS,'Neutral saddle')
          s.msg  = sprintf('Neutral saddle\n');
      else
      k1=process_mfoldNS(x,jac);
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
      q0 = vext/norm(vext);p0 = wext/(vext'*wext);
        s.data.c=nf_LPNSm(lpmds.func,lpmds.Jacobian,lpmds.Hessians,lpmds.Der3,jac,q0,p0,vext1,wext1,nphase,x0,p,n);
        printconsole('Normal form coefficient of LPNS :[ a , b , c, d]= %d, %d, %d, %d\n',s.data.c),
        s.msg  = sprintf('Fold+Neimark_Sacker');
   end
   case 4 % CP
    vext4=vext/norm(vext); 
    wext4=wext/norm(wext'*vext4);
    s.data.c=nf_CPm(lpmds.func,lpmds.Jacobian,lpmds.Hessians,lpmds.Der3,jac,vext4,wext4,nphase,x0,p,n);
    printconsole('Normal form coefficient of CP s= %d\n',s.data.c),     
    s.msg  = sprintf('Cusp');
   otherwise
    s.msg = sprintf('there is not such bifurcation');
end
% Compute eigenvalues for every singularity
[x0,p] = rearr(x); p = n2c(p); n=lpmds.Niterations;
J=lpmjac(x0,p,n)-eye(lpmds.nphase);
if ~issparse(J)
  [v,d]=eig(J);
else
  opt.disp=0;
  % WM: fixed a bug (incompatability between MatLab 6.0 and 5.5?)
  [v,d]=eigs(J,min(6,ndim-2),'lm',opt);
end

s.data.evec = v;
s.data.eval = diag(d)';

failed = 0;
%--------------------------------------------------------
function  [S,L] = singmat    
global lpmds cds
% 0: testfunction must vanish
% 1: testfunction must not vanish
% everything else: ignore this testfunction

  S = [  0 8 8 8 
         8 0 8 8
         1 8 0 8
         8 8 8 0 ]; 
  L = [ 'R1  '; 'LPPD'; 'LPNS'; 'CP  '];
  
%------------------------------------------------------
function [x,v] = locate(id, x1, v1, x2, v2)
msg = sprintf('No locator defined for singularity %d', id);
error(msg);
%------------------------------------------------------
function varargout = init(varargin)
global cds lpmds
  x = varargin{1};
  v = varargin{2};
  WorkspaceInit(x,v);

  % all done succesfully
  varargout{1} = 0;
%--------------------------------------------------------
function varargout = done
global lpmds cds
  WorkspaceDone;
%---------------------------------------------------------
function [res,x,v] = adapt(x,v)
global lpmds
[x1,p] =rearr(x); p = n2c(p);
n=lpmds.Niterations;
jac = lpmjac(x1,p,n);
Bord=[jac-eye(lpmds.nphase) lpmds.borders.w;lpmds.borders.v' 0];
bunit=[zeros(lpmds.nphase,1);1];
vext=Bord\bunit;
wext=Bord'\bunit;
%ERROR OR WARNING
lpmds.borders.v=vext(1:lpmds.nphase)/norm(vext(1:lpmds.nphase));
lpmds.borders.w=wext(1:lpmds.nphase)/norm(wext(1:lpmds.nphase));
res = []; % no re-evaluations needed




%----------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------
function [x,p] = rearr(x0)
%
% [x,p] = rearr(x0)
%
% Rearranges x0 into coordinates (x) and parameters (p)
global lpmds
p = lpmds.P0;
p(lpmds.ActiveParams) = x0((lpmds.nphase+1):end);
x = x0(1:lpmds.nphase);

    
% ---------------------------------------------------------

function WorkspaceInit(x,v)
global cds lpmds opt
n = lpmds.nphase;
  for i=1:cds.nActSing
    if (cds.ActSing(i)==3) && (n<3) 
        %errordlg('Fold+Neimark-Sacker (LPNS) is impossible, ignore this singularity by setting opt=contset(opt,''IgnoreSingularity'',[3])');
        %stop
    end
    if ((cds.ActSing(i)==1) |(cds.ActSing(i)==2))&&(n<2) 
        %errordlg('R1 and fold+flip(LPPD) are impossible, it is better to ignore these singularities by setting opt=contset(opt,''IgnoreSingularity'',[1 2])');
        
    end
       
  end


% calculate some matrices to efficiently compute bialternate products (without loops)
a = reshape(1:(n^2),n,n);
b = zeros(n);
[bia,bin,bip] = bialt(a);
[lpmds.BiAlt_M1_I,lpmds.BiAlt_M1_J,lpmds.BiAlt_M1_V] = find(bip);
[lpmds.BiAlt_M2_I,lpmds.BiAlt_M2_J,lpmds.BiAlt_M2_V] = find(bin);
[lpmds.BiAlt_M3_I,lpmds.BiAlt_M3_J,lpmds.BiAlt_M3_V] = find(bia);

% ------------------------------------------------------

function WorkspaceDone

% -------------------------------------------------------
%SD:continues equilibrium of mapfile
