function out = neimarksackermap
%
% Neimark_sacker curve definition file for a problem in mapfile
% 
global cds nsmds
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
global cds nsmds
  [x,p,k] = rearr(arg); p=n2c(p); n=nsmds.Niterations;
  jac = nsmjac(x,p,n);
  RED=jac*jac-2*k*jac+eye(nsmds.nphase);
  Bord=[RED nsmds.borders.w;nsmds.borders.v' zeros(2)];
  bunit=[zeros(nsmds.nphase,2);eye(2)];
  vext=Bord\bunit;
  vext1=vext(nsmds.nphase+nsmds.index1(1),nsmds.index1(2));
  vext2=vext(nsmds.nphase+nsmds.index2(1),nsmds.index2(2));
  x1=x;
  for i=1:n
  x1=feval(nsmds.func,0,x1,p{:});
  end
  func = [x1-x; vext1;vext2];
   
%--------------------------------------------------------  
function jac = jacobian(varargin)
  global cds nsmds
  n=nsmds.Niterations;
  nap = length(nsmds.ActiveParams); 
  x0 = varargin{1}; [x,p,k] = rearr(x0); p = n2c(p);     
  J=nsmjac(x,p,n);
  RED=J*J-2*k*J+eye(nsmds.nphase);
  Bord=[RED nsmds.borders.w;nsmds.borders.v' zeros(2)];
  bunit=[zeros(nsmds.nphase,2);eye(2)];
  vext=Bord\bunit;
  wext=Bord'\bunit;
  jac=[J-eye(nsmds.nphase)  nsmjacp(x,p,n) zeros(nsmds.nphase,1)];
  hess=nsmhess(x,p,n);
  for i=1:nsmds.nphase
    jac(nsmds.nphase+1,i)=-wext(1:nsmds.nphase,nsmds.index1(1))'*(J*hess(:,:,i)+hess(:,:,i)*J-2*k*hess(:,:,i))*vext(1:nsmds.nphase,nsmds.index1(2));
    jac(nsmds.nphase+2,i)=-wext(1:nsmds.nphase,nsmds.index2(1))'*(J*hess(:,:,i)+hess(:,:,i)*J-2*k*hess(:,:,i))*vext(1:nsmds.nphase,nsmds.index2(2));
  end
  jac(nsmds.nphase+1,nsmds.nphase+nap+1)=2*wext(1:nsmds.nphase,nsmds.index1(1))'*J*vext(1:nsmds.nphase,nsmds.index1(2));
  jac(nsmds.nphase+2,nsmds.nphase+nap+1)=2*wext(1:nsmds.nphase,nsmds.index2(1))'*J*vext(1:nsmds.nphase,nsmds.index2(2));
  hessp=nsmhessp(x,p,n);
  for i=1:nap
    jac(nsmds.nphase+1,nsmds.nphase+i)=-wext(1:nsmds.nphase,nsmds.index1(1))'*(J*hessp(:,:,i)+hessp(:,:,i)*J-2*k*hessp(:,:,i))*vext(1:nsmds.nphase,nsmds.index1(2));
    jac(nsmds.nphase+2,nsmds.nphase+i)=-wext(1:nsmds.nphase,nsmds.index2(1))'*(J*hessp(:,:,i)+hessp(:,:,i)*J-2*k*hessp(:,:,i))*vext(1:nsmds.nphase,nsmds.index2(2));
  end 
%------------------------------------------------------
function hess = hessians(varargin)  
hess =[];
%------------------------------------------------------
function varargout = defaultprocessor(varargin)
global cds nsmds
%elseif strcmp(arg,'defaultprocessor')
  if nargin > 2
    s = varargin{3};
    varargout{3} = s;
  end
 % compute eigenvalues?
  if (cds.options.Multipliers==1)
      n=nsmds.Niterations;
      x0 = varargin{1}; [x,p] = rearr(x0); p = n2c(p);
      jac =nsmjac(x,p,n);
      varargout{2} = eig(jac);
  else
      varargout{2}= nan;
  end  
  % all done succesfully
  varargout{1} = 0;
%-------------------------------------------------------  
function option = options
global cds nsmds
  option = contset;
  % Check for symbolic derivatives in mapfile
  
  symjac  = ~isempty(nsmds.Jacobian);
  symhes  = ~isempty(nsmds.Hessians);
  symDer3 = ~isempty(nsmds.Der3);
  symDer4 = ~isempty(nsmds.Der4);
  symDer5 = ~isempty(nsmds.Der5);
    
  symord = 0; 
  if symjac, symord =  1; end
  if symhes, symord =  2; end
  if symDer3, symord = 3; end
  if symDer4, symord = 4; end
  if symDer5, symord = 5; end

  option = contset(option, 'SymDerivative', symord);
  option = contset(option, 'Workspace', 1);
  option = contset(option, 'Locators', [0 0 0]);

  symjacp = ~isempty(nsmds.JacobianP); 
  symhessp= ~isempty(nsmds.HessiansP); 
  symordp = 0;
  if symjacp,  symordp = 1;end
  if symhessp, symordp = 2;end
  option=contset(option,'SymDerivativeP',symordp);
  
  cds.symjac  = 1;
  cds.symhess = 1;

% ---------------------------------------------------------------

function [out, failed] = testf(id, x, v)
global  cds nsmds 
n=nsmds.Niterations;nphase = nsmds.nphase;
[x0,p,k] = rearr(x); p1 = n2c(p);
jac=nsmjac(x0,p1,n);
RED=jac*jac-2*k*jac+eye(nphase);
Bord=[RED nsmds.borders.w;nsmds.borders.v' zeros(2)];
bunit=[zeros(nphase,2);eye(2)];
vext=Bord\bunit;
wext=Bord'\bunit;
failed = [];
for i=id
  lastwarn('');
switch i
  case 1 % CH (Chenciner) 
   [V,D] = eig(jac);
   % find pair of complex eigenvalues
   d = diag(D);idx1=0;idx2=0;
   for i1=1:nphase
     for j=i+1:nphase
       if (d(i1)== conj(d(j))) && (imag(d(i1))~=0) && (abs(real(d(i1)-k))<1e-5)&&(abs(d(i1)*d(j)-1)<1e-5)
         idx1=i1;idx2=j;
       end
     end
   end
   if (idx1==0)||(imag(d(idx1))==0);
     out(1)=111;
   else
     if imag(d(idx1))<0
       idx1=idx2;
     end  
     q=V(:,idx1);
   end
   if (idx1==0)||(imag(d(idx1))==0);
     out(1)=111;         
   else
     [V,D] = eig(jac');  
     d1 = diag(D);
     [Y,j]=min(abs(d1-conj(d(idx1))));    
     p=V(:,j);
     q=q/norm(q);
     p=p/(q'*p);
     out(1)=nf_NSm(nsmds.func,nsmds.Jacobian,nsmds.Hessians,nsmds.Der3,jac,q,p,nphase,x0,p1,d(idx1),n);
   end
  case 2 % PDNS  (Flip+Neimark-Sacker)
      out(2) =det(jac+eye(nsmds.nphase));
  case 3 % LPNS  (Fold+Neimark-Sacker) 
      out(3)=det(jac-eye(nsmds.nphase));
  case 4   %R1 (Resonance 1:1)
      out(4)= k-1;
  case 5 % NSNS  (Double Neimark-Sacker) 
      [Q,R]=qr(wext(1:nsmds.nphase,1:2));
      Q1=Q(1:nsmds.nphase,3:nsmds.nphase); 
      A = [Q1'*jac*Q1 zeros(nsmds.nphase-2,1)];
      [bialt_M1,bialt_M2,bialt_M3,bialt_M4]=bialtaa(nsmds.nphase-2); 
      B=A(bialt_M1).*A(bialt_M2)-A(bialt_M3).*A(bialt_M4);
      B=B-eye(size(B,1));
      out(5) = det(B);     
  case 6  % R2  (Resonance1:2)
      out(6)=k+1;
  case 7  % R3  (Resonance1:3)
      out(7)=k+1/2.0;
  case 8  % R4  (Resonance1:4)
      out(8)=k;
  otherwise
    error('No such testfunction');
  end  
end

%-------------------------------------------------------
function [out, failed] = userf(userinf, id, x, v)
global cds nsmds
dim =size(id,2);
failed = [];
for i=1:dim
  lastwarn('');
  [x0,p] = rearr(x); p = n2c(p);
  if (userinf(i).state==1)
      out(i)=feval(nsmds.user{id(i)},0,x0,p{:});
  else
      out(i)=0;
  end
  if ~isempty(lastwarn)
    msg = sprintf('Could not evaluate userfunction %s\n', id(i).name);
    failed = [failed i];
  end
end
% ---------------------------------------------------------------

function [failed,s] = process(id, x, v, s)
global cds nsmds opt
ndim = cds.ndim;
n=nsmds.Niterations;
[x0,p,k] = rearr(x); p1 = n2c(p);
nphase=size(x0,1);
% WM: Removed SL array
printconsole('label = %s, x = %s \n', s.label , vector2string(x)); 
jac=nsmjac(x0,p1,n);
RED=jac*jac-2*k*jac+eye(nsmds.nphase);
Bord=[RED nsmds.borders.w;nsmds.borders.v' zeros(2)];
bunit=[zeros(nsmds.nphase,2);eye(2)];
vext=Bord\bunit;
wext=Bord'\bunit;
d1=k+sqrt(-1.0)*abs(sqrt(1-k*k));
d2=conj(d1);
alpha=vext(1:nphase,1)'*(jac*vext(1:nphase,2)-d1*vext(1:nphase,2));
beta=-vext(1:nphase,1)'*(jac*vext(1:nphase,1)-d1*vext(1:nphase,1));
q=alpha*vext(1:nphase,1)+beta*vext(1:nphase,2);
alpha=wext(1:nphase,1)'*(jac'*wext(1:nphase,2)-d2*wext(1:nphase,2));
beta=-wext(1:nphase,1)'*(jac'*wext(1:nphase,1)-d2*wext(1:nphase,1));
p=alpha*wext(1:nphase,1)+beta*wext(1:nphase,2);
q=q/norm(q);
p=p/(q'*p);
switch id
  case 1 % CH
    s.data.c=nf_CHm(nsmds.func,nsmds.Jacobian,nsmds.Hessians,nsmds.Der3,nsmds.Der4,nsmds.Der5,jac,q,p,nphase,x0,p1,n);
    printconsole('Normal form coefficient of CH = %d\n', s.data.c); 
    s.msg  = sprintf('Chenciner bifurcation');  
  case 2 % PDNS
    [V,D]=eig(jac+eye(nphase));
    [Y,i]=min(abs(diag(D)));
    q2=real(V(:,i));
    [V,D]=eig(jac'+eye(nphase));
    [Y,i]=min(abs(diag(D)));
    p2=real(V(:,i));
    q2=q2/norm(q2);
    p2=p2/(q2'*p2);
    s.data.c=nf_PDNSm(nsmds.func,nsmds.Jacobian,nsmds.Hessians,nsmds.Der3,jac,q2,p2,q,p,nphase,x0,p1,n);
    printconsole('Normal form coefficient for PDNS :[a , b, c, d]= %d, %d, %d, %d\n', s.data.c);
    s.msg  = sprintf('Flip+Neimark-Sacker');
  case 3 % LPNS
      
    [V,D]=eig(jac-eye(nphase));
    [Y,i]=min(abs(diag(D)));
    q2=real(V(:,i));
    [V,D]=eig(jac'-eye(nphase));
    [Y,i]=min(abs(diag(D)));
    p2=real(V(:,i));
    q2=q2/norm(q2);
    p2=p2/(q2'*p2);
    s.data.c=nf_LPNSm(nsmds.func,nsmds.Jacobian,nsmds.Hessians,nsmds.Der3,jac,q2,p2,q,p,nphase,x0,p1,n);
    printconsole('Normal form coefficient for LPNS :[s, a , b , c]= %d, %d, %d, %d\n',s.data.c);
    s.msg  = sprintf('Fold+Neimark-Sacker');
  case 4 % R1
    [V,D]=eig(jac-eye(nphase));
    [Y,i]=min(abs(diag(D)));
    vext4=real(V(:,i));
    mu = norm(vext4);
    vext4=vext4/mu;
    [V,D]=eig(jac'-eye(nphase));
    [Y,i]=min(abs(diag(D)));
    wext4=real(V(:,i));
    Bord=[jac-eye(nphase) wext4; vext4' 0];
    genvext4=Bord\[vext4;0];
    genvext4=genvext4(1:nphase)/mu;
    genvext4=genvext4-(vext4'*genvext4)*vext4;  
    genwext4=Bord'\[wext4;0];
    genwext4=genwext4(1:nphase);
    mu = vext4'*genwext4;
    wext4 = wext4/mu;  
    genwext4 = genwext4 - (genwext4'*genvext4)*wext4;
    genwext4 = genwext4/mu;    
    s.data.c=nf_R1m(nsmds.func,nsmds.Jacobian,nsmds.Hessians,jac,vext4,genvext4,wext4,genwext4,nphase,x0,p1,n);    
    printconsole('Normal form coefficient of R1 : s = %i\n',s.data.c),
    s.msg  = sprintf('Resonance1:1');
  case 5 %NSNS      
      [Q,R]=qr(wext(1:nsmds.nphase,1:2));
      Q1=Q(1:nsmds.nphase,3:nsmds.nphase);
      jac1=Q1'*jac*Q1;
      s.data.process_NS = process_doubleNS(x,jac1);  
      if strcmp(s.data.process_NS,'Neutral saddle')       
        s.msg  = sprintf('Neutral saddle\n');
      else
        s.data.v=v;
        d11=s.data.process_NS;
        [V,D]=eig(jac);
        d=diag(D);
        [Y,i]=min(abs(d-d11));
        vext=V(:,i);
        [V,D]=eig(jac');
        d=diag(D);
        [Y,i]=min(abs(d-conj(d11)));
        wext=V(:,i);
        vext=vext/norm(vext);
        wext=wext/(vext'*wext);
        s.data.c=nf_NSNSm(nsmds.func,nsmds.Jacobian,nsmds.Hessians,nsmds.Der3,jac,q,p,vext,wext,nphase,x0,p1,n);
        s.data.kappa = x(end);
        printconsole('Normal form coefficient of NSNS : [a11, a12, a21, a22] = %d, %d, %d, %d\n',s.data.c),
        s.msg=sprintf('Double Neimark-Sacker'); 
      end  
  case 6 % R2
      
    [V,D]=eig(jac+eye(nphase));
    [Y,i]=min(abs(diag(D)));
    vext6=real(V(:,i));    
    mu = norm(vext6); 
    vext6=vext6/mu;       
    [V,D]=eig(jac'+eye(nphase));
    [Y,i]=min(abs(diag(D)));
    wext6=real(V(:,i));
    Bord=[jac+eye(nphase) wext6; vext6' 0]; 
    genvext6=Bord\[vext6;0];    
    genvext6=genvext6(1:nphase)/mu; 
    genvext6 = genvext6 - (vext6'*genvext6)*vext6;
    genwext6=Bord'\[wext6;0];
    genwext6=genwext6(1:nphase);
    mu=vext6'*genwext6;
    wext6=wext6/mu;
    genwext6 = genwext6 - (genwext6'*genvext6)*wext6;
    genwext6=genwext6/mu;
    s.data.c=nf_R2m(nsmds.func,nsmds.Jacobian,nsmds.Hessians,nsmds.Der3,jac,vext6,genvext6,wext6,genwext6,nphase,x0,p1,n);
    printconsole('Normal form coefficient of R2 : [c , d] = %d, %d\n',s.data.c), 
    s.msg  = sprintf('Resonance1:2');
    
  case 7 % R3      
    d1=exp(j*2*pi/3.0);
    [V,D]=eig(jac-d1*eye(nphase));
    [Y,i]=min(abs(diag(D)));
    vext7=V(:,i);
    [V,D]=eig(jac'-conj(d1)*eye(nphase));
    [Y,i]=min(abs(diag(D)));
    wext7=V(:,i);
    vext7=vext7/norm(vext7);
    wext7=wext7/(vext7'*wext7);
    s.data.c=nf_R3m(nsmds.func,nsmds.Jacobian,nsmds.Hessians,nsmds.Der3,jac,vext7,wext7,nphase,x0,p1,n);
    printconsole('Normal form coefficient of R3 : Re(c_1) = %d\n', s.data.c),    
    s.msg  = sprintf('Resonance1:3');
  case 8 %R4      
    d1=exp(j*pi/2.0);
    [V,D]=eig(jac-d1*eye(nphase));
    [Y,i]=min(abs(diag(D)));
    vext8=V(:,i);
    [V,D]=eig(jac'-conj(d1)*eye(nphase));
    [Y,i]=min(abs(diag(D)));
    wext8=V(:,i);
    vext8=vext8/norm(vext8);
    wext8=wext8/(vext8'*wext8);
    [s.data.c,d]=nf_R4m(nsmds.func,nsmds.Jacobian,nsmds.Hessians,nsmds.Der3,jac,vext8,wext8,nphase,x0,p1,n);
    printconsole('Normal form coefficient of R4 : A = %d + %d i\n', s.data.c);      
    s.msg  = sprintf('Resonance1:4'); 
end

% Compute eigenvalues for every singularity
[x0,p] = rearr(x); p = n2c(p); 
J=nsmjac(x0,p,n);
if ~issparse(J)
  [v,d]=eig(J);
else
  opt.disp=0;
  [v,d]=eigs(J,min(6,ndim-2),'lm',opt);
end

s.data.evec = v;
s.data.eval = diag(d)';

failed = 0;
%-------------------------------------------------------
function [S,L] = singmat
global nsmds cds
%elseif strcmp(arg, 'singmat')    
% 0: testfunction must vanish
% 1: testfunction must not vanish
% everything else: ignore this testfunction

  S = [  0 8 8 8 8 8 8 8
         8 0 8 8 8 1 8 8
         8 8 0 1 8 8 8 8 
         8 8 0 0 8 8 8 8
         8 8 8 8 0 8 8 8
         8 0 8 8 8 0 8 8
         8 8 8 8 8 8 0 8 
         8 8 8 8 8 8 8 0 ];
     
  L = [ 'CH  '; 'PDNS'; 'LPNS';'R1  '; 'NSNS'; 'R2  ';'R3  '; 'R4  ' ];

%-------------------------------------------------------
function [x,v] = locate(id, x1, v1, x2, v2)
msg = sprintf('No locator defined for singularity %d', id);
error(msg);
  
%-------------------------------------------------------
function varargout = init(varargin)
global nsmds cds
  x = varargin{1};
  v = varargin{2};
  WorkspaceInit(x,v);

  % all done succesfully
  varargout{1} = 0;
%-------------------------------------------------------
function varargout = done
global nsmds cds
  WorkspaceDone;
  
%------------------------------------------------------
function [res,x,v] = adapt(x,v)
global nsmds
n=nsmds.Niterations;
nap=length(nsmds.ActiveParams);
[x0,p,k] = rearr(x); p1 = n2c(p);
jac=nsmjac(x0,p1,n);
RED=jac*jac-2*k*jac+eye(nsmds.nphase);
Bord=[RED nsmds.borders.w;nsmds.borders.v' zeros(2)];
bunit=[zeros(nsmds.nphase,2);eye(2)];
vext=Bord\bunit;
[vext,r]=qr(vext);
vext=vext(:,1:2);nsmds.borders.v=vext(1:nsmds.nphase,:);
wext=Bord'\bunit;
[wext,r]=qr(wext);
wext=wext(:,1:2);nsmds.borders.w=wext(1:nsmds.nphase,:);
jacp=nsmjacp(x0,p1,n);
A=[jac-eye(nsmds.nphase) jacp zeros(nsmds.nphase,1)];%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Q,R]=qr(A');
hess=nsmhess(x0,p1,n);
for i = 1:nsmds.nphase
    gx(1,i) = -wext(1:nsmds.nphase,1)'*(jac*hess(:,:,i)+hess(:,:,i)*jac-2*k*hess(:,:,i))*vext(1:nsmds.nphase,1);
    gx(2,i) = -wext(1:nsmds.nphase,1)'*(jac*hess(:,:,i)+hess(:,:,i)*jac-2*k*hess(:,:,i))*vext(1:nsmds.nphase,2);
    gx(3,i) = -wext(1:nsmds.nphase,2)'*(jac*hess(:,:,i)+hess(:,:,i)*jac-2*k*hess(:,:,i))*vext(1:nsmds.nphase,1);
    gx(4,i) = -wext(1:nsmds.nphase,2)'*(jac*hess(:,:,i)+hess(:,:,i)*jac-2*k*hess(:,:,i))*vext(1:nsmds.nphase,2);
end
gk(1,1) =2*wext(1:nsmds.nphase,1)'*jac*vext(1:nsmds.nphase,1);
gk(2,1) =2*wext(1:nsmds.nphase,1)'*jac*vext(1:nsmds.nphase,2);
gk(3,1) =2*wext(1:nsmds.nphase,2)'*jac*vext(1:nsmds.nphase,1);
gk(4,1) =2*wext(1:nsmds.nphase,2)'*jac*vext(1:nsmds.nphase,2);
hessp = nsmhessp(x0,p1,n);

for i = 1:nap
    gp(1,i) = -wext(1:nsmds.nphase,1)'*(jac*hessp(:,:,i)+hessp(:,:,i)*jac-2*k*hessp(:,:,i))*vext(1:nsmds.nphase,1);
    gp(2,i) = -wext(1:nsmds.nphase,1)'*(jac*hessp(:,:,i)+hessp(:,:,i)*jac-2*k*hessp(:,:,i))*vext(1:nsmds.nphase,2);
    gp(3,i) = -wext(1:nsmds.nphase,2)'*(jac*hessp(:,:,i)+hessp(:,:,i)*jac-2*k*hessp(:,:,i))*vext(1:nsmds.nphase,1);
    gp(4,i) = -wext(1:nsmds.nphase,2)'*(jac*hessp(:,:,i)+hessp(:,:,i)*jac-2*k*hessp(:,:,i))*vext(1:nsmds.nphase,2);
end

A = [A;gx gp gk]*Q;
Jres = A(1+nsmds.nphase:end,1+nsmds.nphase:end);
[Q,R,E] = qr(Jres');
index = [1 1;1 2;2 1;2 2];
[I,J] = find(E(:,1:2));
nsmds.index1 = index(I(1),:);
nsmds.index2 = index(I(2),:);
res = []; % no re-evaluations needed

%----------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------

function [x,p,k] = rearr(x0)
%
% Rearranges x0 into coordinates (x) and parameters (p)
%
global nsmds
p = nsmds.P0;
p(nsmds.ActiveParams) = x0((nsmds.nphase+1):(end-1));
x = x0(1:nsmds.nphase);
k=x0(end);

% ---------------------------------------------------------
% 
function WorkspaceInit(x,v)
global cds nsmds opt
nphase=nsmds.nphase;

for i=1:cds.ActTest
  if (cds.ActTest(i)==5) && (nphase<4)   
    opt=contset(opt,'IgnoreSingularity',[5]); 
    errordlg('Double Neimark-Sacker (NSNS) is impossible, ignore this singularity by setting opt=contset(opt,''IgnoreSingularity'',[5])');
  end
      
  if ((cds.ActTest(i)==2) || (cds.ActTest(i)==3)) && (nphase<3)
    errordlg('fold +Neimark-Sacker (LPNS) and flip +Neimark-Sacker (PDNS) are impossible, it is better to ignore these singularities by setting opt=contset(opt,''IgnoreSingularity'',[2 3])');
  end  
end

% calculate some matrices to efficiently compute bialternate products (without loops)
n = nsmds.nphase-2;
a = reshape(1:(n^2),n,n);
[bia,bin,bip] = bialt(a);
if any(any(bip))
    [nsmds.BiAlt_M1_I,nsmds.BiAlt_M1_J,nsmds.BiAlt_M1_V] = find(bip);
else
    nsmds.BiAlt_M1_I=1;nsmds.BiAlt_M1_J=1;nsmds.BiAlt_M1_V=n^2+1;
end    
if any(any(bin))
    [nsmds.BiAlt_M2_I,nsmds.BiAlt_M2_J,nsmds.BiAlt_M2_V] = find(bin);
else
     nsmds.BiAlt_M2_I=1;nsmds.BiAlt_M2_J=1;nsmds.BiAlt_M2_V=n^2+1;
end
if any(any(bia))
    [nsmds.BiAlt_M3_I,nsmds.BiAlt_M3_J,nsmds.BiAlt_M3_V] = find(bia);
else
    nsmds.BiAlt_M3_I=1;nsmds.BiAlt_M3_J=1;nsmds.BiAlt_M3_V=n^2+1;
end

% ------------------------------------------------------
function WorkspaceDone
% -------------------------------------------------------
