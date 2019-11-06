function [x0,v0]= init_NSm_NSm_Same(mapfile, x, p, ap , find_kappa ,n)
%
% Initializes a Neimark_Sacker bifurcation continuation from a NS (or R1 or R2) point
% 
global cds nsmds

% check input
if size(ap,2)~=2
    errordlg('Two active parameters are needed for a NS-curve continuation');
end
v0=[];
% initialize nsmds
nsmds.mapfile = mapfile;
func_handles = feval(nsmds.mapfile);
nsmds.func = func_handles{2};
nsmds.Jacobian  = func_handles{3};
nsmds.JacobianP = func_handles{4};
nsmds.Hessians  = func_handles{5};
nsmds.HessiansP = func_handles{6};
nsmds.Der3      = func_handles{7};
nsmds.Der4      = func_handles{8};
nsmds.Der5      = func_handles{9};
nsmds.Niterations      = n;
siz = size(func_handles,2);
if siz > 9
    j=1;
    for i=10:siz
        nsmds.user{j}= func_handles{i};
        j=j+1;
    end
end

nsmds.nphase = size(x,1);
nsmds.ActiveParams = ap;
nsmds.P0 = p;
cds.curve = @neimarksackermap;
cds.ndim = length(x)+3;
x0=[x;nsmds.P0(ap)];
[x1,p] = rearr(x0); p = n2c(p);
curvehandles = feval(cds.curve);
cds.curve_func = curvehandles{1};
cds.curve_options = curvehandles{3};
cds.curve_jacobian =curvehandles{4};
cds.curve_hessians = curvehandles{5};
cds.options = feval(cds.curve_options); 
cds.options = contset(cds.options,'Increment',1e-5);
jac = nsmjac(x1,p,n);
nphase = size(x1,1);
nap = length(nsmds.ActiveParams);
% calculate eigenvalues and eigenvectors
[V,D] = eig(jac);
d = diag(D);
% find a 'neutral pair'
idx1=0;idx2=0;
for s=1:nphase
  for j=s+1:nphase
      if ((abs(1-d(s)*d(j))<1e-5) && (abs(find_kappa - real(d(s))) < 1e-5) && (abs(find_kappa - real(d(j))) < 1e-5)) 
         idx1=s; idx2=j;
      end
  end
end

if idx1==0
  warnconsole('No other neutral pair found!');
  global initmsg;
  initmsg='Could not find appropriate eigenvalues';
    x0 = [];
  return;
end

if (abs(abs(d(idx1))-1)<1e-4) %Check if multiplier on the unit circle
  if (angle(d(idx1))<1e-3) %Check if R1
    [V1,D1] = eig(jac-eye(nphase));
    [s,idx2] = min(abs(diag(D1)));
    vext=real(V1(:,idx2)); 
    [V1,D1]=eig(jac'-eye(nphase));
    [s,idx2]=min(abs(diag(D1)));
    wext=real(V1(:,idx2));
    Bord = [jac-eye(nphase) wext;vext' 0];
    genvext = Bord \[vext; 0];genvext=genvext(1:nphase);
    genwext = Bord'\[wext; 0];genwext=genwext(1:nphase);
    [Q,R,E] = qr([vext genvext]);      
    nsmds.borders.v = Q(:,1:2);     
    [Q,R,E] = qr([wext genwext]); 
    nsmds.borders.w = Q(:,1:2);
    k=1; 
  elseif (pi-angle(d(idx1))<1e-3) %Check if R2
    [V1,D1] = eig(jac-eye(nphase));
    [s,idx2] = min(abs(diag(D1)));
    vext=real(V1(:,idx2)); 
    [V1,D1]=eig(jac'-eye(nphase));
    [s,idx2]=min(abs(diag(D1)));
    wext=real(V1(:,idx2));
    Bord = [jac-eye(nphase) wext;vext' 0];
    genvext = Bord \[vext; 0];genvext=genvext(1:nphase);
    genwext = Bord'\[wext; 0];genwext=genwext(1:nphase);
    [Q,R,E] = qr([vext genvext]);      
    nsmds.borders.v = Q(:,1:2);     
    [Q,R,E] = qr([wext genwext]); 
    nsmds.borders.w = Q(:,1:2);
    k=-1;   
  else %True Neimark-Sacker
    [Q,R,E] = qr([real(V(:,idx1)) imag(V(:,idx1))]); 
    nsmds.borders.v = Q(:,1:2);
    [V1,D1] = eig(jac'-d(idx1)*eye(nphase));
    [s1,d1]=min(abs(diag(D1))); 
    [Q,R,E] = qr([real(V1(:,d1)) imag(V1(:,d1))]);
    nsmds.borders.w = Q(:,1:2); 
    k  = real(d(idx1)); 
  end  
else
  warnconsole('Neutral saddle\n');
  [Q,R,E]=qr([V(:,idx1) V(:,idx2)]);
  nsmds.borders.v = Q(:,1:2);         
  [V4,D4] = eig(jac'-d(idx1)*eye(nphase));
  [s4,d4]=min(abs(diag(D4)));
  [V5,D5] = eig(jac'-d(idx2)*eye(nphase));
  [s5,d5]=min(abs(diag(D5)));             
  [Q,R,E]=qr([V4(:,d4) V5(:,d5)]);
  nsmds.borders.w = Q(:,1:2); 
  k=0.5*(d(idx1)+d(idx2));
end  
    
x0 = [x0;k];
% calculate eigenvalues

% ERROR OR WARNING
RED  = jac*jac-2*k*jac+eye(nsmds.nphase);
jacp = nsmjacp(x1,p,n);
A = [jac-eye(nsmds.nphase)  jacp zeros(nsmds.nphase,1)];  
[Q,R] = qr(A');
Bord  = [RED nsmds.borders.w;nsmds.borders.v' zeros(2)];
bunit = [zeros(nsmds.nphase,2);eye(2)];
vext  = Bord\bunit;
wext  = Bord'\bunit;

wext1=jac'*wext(1:nsmds.nphase,1);
vext1=vext(1:nsmds.nphase,1);
nphase=size(x1,1); 
xx1=x1;
AA=zeros(nphase,nphase,n);
AA(:,:,1)=nsmjac(xx1,p,1);
xit=zeros(nphase,n);
for m=2:n    
 xx1=feval(nsmds.func,0,xx1,p{:});
 xit(:,1)=xx1;
 AA(:,:,m)=nsmjac(xx1,p,1);
end  
gx1=nsvecthessvect(xit,p,vext1,wext1',AA,n);
wext2=wext(1:nsmds.nphase,1)';
vext2=jac*vext(1:nsmds.nphase,1);
gx2=nsvecthessvect(xit,p,vext2,wext2,AA,n);
wext3=-2.0*k*wext(1:nsmds.nphase,1)';
vext3=vext(1:nsmds.nphase,1);
gx3=nsvecthessvect(xit,p,vext3,wext3,AA,n);
gxx1=gx1+gx2+gx3;
wext12=wext(1:nsmds.nphase,1)'*jac;
vext12=vext(1:nsmds.nphase,2);
gx12=nsvecthessvect(xit,p,vext12,wext12,AA,n);

wext22=wext(1:nsmds.nphase,1)';
vext22=jac*vext(1:nsmds.nphase,2);
gx22=nsvecthessvect(xit,p,vext22,wext22,AA,n);

wext32=-2.0*k*wext(1:nsmds.nphase,1)';
vext32=vext(1:nsmds.nphase,2);
gx32=nsvecthessvect(xit,p,vext32,wext32,AA,n);
gxx2=gx12+gx22+gx32;

wext31=wext(1:nsmds.nphase,2)'*jac;
vext31=vext(1:nsmds.nphase,1);
gx31=nsvecthessvect(xit,p,vext31,wext31,AA,n);

wext32=wext(1:nsmds.nphase,2)';
vext32=jac*vext(1:nsmds.nphase,1);
gx32=nsvecthessvect(xit,p,vext32,wext32,AA,n);

wext33=-2.0*k*wext(1:nsmds.nphase,2)';
vext33=vext(1:nsmds.nphase,1);
gx33=nsvecthessvect(xit,p,vext33,wext33,AA,n);
gxx3=gx31+gx32+gx33;

wext41=wext(1:nsmds.nphase,2)'*jac;
vext41=vext(1:nsmds.nphase,2);
gx41=nsvecthessvect(xit,p,vext41,wext41,AA,n);

wext42=wext(1:nsmds.nphase,2)';
vext42=jac*vext(1:nsmds.nphase,2);
gx42=nsvecthessvect(xit,p,vext42,wext42,AA,n);

wext43=-2.0*k*wext(1:nsmds.nphase,2)';
vext43=vext(1:nsmds.nphase,2);
gx43=nsvecthessvect(xit,p,vext43,wext43,AA,n);
gxx4=gx41+gx42+gx43;
for i = 1:nsmds.nphase
    gx(1,i)=gxx1(:,i);
    gx(2,i)=gxx2(:,i);
    gx(3,i)=gxx3(:,i);
    gx(4,i)=gxx4(:,i);
end
gk(1,1) =2*wext(1:nsmds.nphase,1)'*jac*vext(1:nsmds.nphase,1);
gk(2,1) =2*wext(1:nsmds.nphase,1)'*jac*vext(1:nsmds.nphase,2);
gk(3,1) =2*wext(1:nsmds.nphase,2)'*jac*vext(1:nsmds.nphase,1);
gk(4,1) =2*wext(1:nsmds.nphase,2)'*jac*vext(1:nsmds.nphase,2);
wext1=wext(1:nsmds.nphase,1)'*jac;
vext1=vext(1:nsmds.nphase,1);
gx1=nsvecthesspvect(xit,p,vext1,wext1,AA,n);

wext2=wext(1:nsmds.nphase,1)';
vext2=jac*vext(1:nsmds.nphase,1);
gx2=nsvecthesspvect(xit,p,vext2,wext2,AA,n);

wext3=-2.0*k*wext(1:nsmds.nphase,1)';
vext3=vext(1:nsmds.nphase,1);
gx3=nsvecthesspvect(xit,p,vext3,wext3,AA,n);
gp1=gx1+gx2+gx3;

wext12=wext(1:nsmds.nphase,1)'*jac;
vext12=vext(1:nsmds.nphase,2);
gx12=nsvecthesspvect(xit,p,vext12,wext12,AA,n);

wext22=wext(1:nsmds.nphase,1)';
vext22=jac*vext(1:nsmds.nphase,2);
gx22=nsvecthesspvect(xit,p,vext22,wext22,AA,n);

wext32=-2.0*k*wext(1:nsmds.nphase,1)';
vext32=vext(1:nsmds.nphase,2);
gx32=nsvecthesspvect(xit,p,vext32,wext32,AA,n);
gp2=gx12+gx22+gx32;

wext31=wext(1:nsmds.nphase,2)'*jac;
vext31=vext(1:nsmds.nphase,1);
gx31=nsvecthesspvect(xit,p,vext31,wext31,AA,n);

wext32=wext(1:nsmds.nphase,2)';
vext32=jac*vext(1:nsmds.nphase,1);
gx32=nsvecthesspvect(xit,p,vext32,wext32,AA,n);

wext33=-2.0*k*wext(1:nsmds.nphase,2)';
vext33=vext(1:nsmds.nphase,1);
gx33=nsvecthesspvect(xit,p,vext33,wext33,AA,n);
gp3=gx31+gx32+gx33;

wext41=wext(1:nsmds.nphase,2)'*jac;
vext41=vext(1:nsmds.nphase,2);
gx41=nsvecthesspvect(xit,p,vext41,wext41,AA,n);

wext42=wext(1:nsmds.nphase,2)';
vext42=jac*vext(1:nsmds.nphase,2);
gx42=nsvecthesspvect(xit,p,vext42,wext42,AA,n);

wext43=-2.0*k*wext(1:nsmds.nphase,2)';
vext43=vext(1:nsmds.nphase,2);
gx43=nsvecthesspvect(xit,p,vext43,wext43,AA,n);
gp4=gx41+gx42+gx43;
for i = 1:nap
    gp(1,i)=gp1(:,i);
    gp(2,i)=gp2(:,i);
    gp(3,i)=gp3(:,i);
    gp(4,i)=gp4(:,i);
end

A = [A;gx gp gk]*Q;
Jres = A(1+nsmds.nphase:end,1+nsmds.nphase:end)';
[Q,R,E] = qr(Jres');
index = [1 1;1 2;2 1;2 2];
[I,J] = find(E(:,1:2));
nsmds.index1 = index(I(1),:);
nsmds.index2 = index(I(2),:);
rmfield(cds,'options'); 

% ---------------------------------------------------------------
function [x,p] = rearr(x0)
% [x,p] = rearr(x0)
% Rearranges x0 into coordinates (x) and parameters (p)
global cds nsmds
nap = length(nsmds.ActiveParams);
p = nsmds.P0;
p(nsmds.ActiveParams) = x0((nsmds.nphase+1):end);
x = x0(1:nsmds.nphase);







