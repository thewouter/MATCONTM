function [x0,v0]= init_FPDm_NS2m(mapfile,eps,x,p,ap,n)
%
% [x1,v1] = init_R2n_NS2(mapfile, x, p, ap)
%
% Initializes a Neimark_Sacker of double period bifurcation continuation from a R2 point if possible
% 
nsmds=[];
global cds nsmds
% check input
if size(ap,2)~=2
    errordlg('Two active parameter are needed for a Neimark_Sacker bifurcation continuation');
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
nsmds.Niterations      = 2*n;
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
%-----Defining Symbolic derivatives-----
  symjac  = ~isempty(nsmds.Jacobian);
  symhes  = ~isempty(nsmds.Hessians);
  symDer3 = ~isempty(nsmds.Der3);
  symord = 0; 
  if symjac, symord = 1; end
  if symhes, symord = 2; end
  if symDer3, symord = 3; end
  cds.options.SymDerivative = symord;
  symjacp  = ~isempty(nsmds.JacobianP); 
  symhessp = ~isempty(nsmds.HessiansP); 
  symordp = 0;
  if symjacp,  symordp = 1; end
  if symhessp, symordp = 2; end
  cds.options.SymDerivativeP = symordp;
%---Branch Switching Algorithm----
  p = n2c(p);nphase = size(x,1);
  A = nsmjac(x,p,n);						
  [X,D] = eig(A-eye(nphase));
  [Y,i] = min(abs(diag(D)));
  vext = X(:,i);
  [X,D] = eig(A'-eye(nphase));
  [Y,i] = min(abs(diag(D)));
  wext = X(:,i);
  [X,D] = eig(A+eye(nphase));
  [Y,i] = min(abs(diag(D)));
  vext2 = X(:,i);
  [X,D] = eig(A'+eye(nphase));
  [Y,i] = min(abs(diag(D)));
  wext2 = X(:,i);
  q2 = vext2/norm(vext2);p2 = wext2/(wext2'*q2);
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/5.0);
  global T1global T2global T3global
  if (cds.options.SymDerivative >= 3)
    T1global=tens1(nsmds.func,nsmds.Jacobian,x,p,n);
    T2global=tens2(nsmds.func,nsmds.Hessians,x,p,n);
    T3global=tens3(nsmds.func,nsmds.Der3,x,p,n);
  end
  h11 = multilinear2(nsmds.func,vext,q2,x,p,n,hessIncrement);   %B(q0,q1)
  q1 = vext/norm(vext)/(p2'*h11);p1 = wext/(wext'*q1);		%rescale q0 such that e=1! and restart computing
  h20 = multilinear2(nsmds.func,q1,q1,x,p,n,hessIncrement);    	%B(q1,q1)
  h11 = multilinear2(nsmds.func,q1,q2,x,p,n,hessIncrement);    	%B(q1,q2)
  h02 = multilinear2(nsmds.func,q2,q2,x,p,n,hessIncrement);    	%B(q2,q2)
  a1 = p1'*h20/2.0;b1 = p1'*h02/2.0;
  if (b1 <= 0)
    printconsole('Switching not possible!\n');
    global initmsg;
    initmsg = 'Switching not possible';
    x0 = [];
    return;
  end  
  Bord =[A-eye(nphase) q1; p1' 0];
  h20 = Bord\[2*a1*q1-h20; 0];
  h11 = [A+eye(nphase) q2 ; p2' 0]\[q2-h11; 0];
  h02 = Bord\[2*b1*q1-h02; 0];
  h2000 = h20(1:nphase);h1100 = h11(1:nphase);h0200 = h02(1:nphase);
  c2 = multilinear3(nsmds.func,q2,q2,q1,x,p,n,ten3Increment);			%  C(q2,q2,q1)
  c2 = c2 + multilinear2(nsmds.func,q1,h0200,x,p,n,hessIncrement);		%+ B(q1,h02)
  c2 = p1'*(c2 + 2.0*multilinear2(nsmds.func,q2,h1100,x,p,n,hessIncrement))/2.0;%+2B(q2,h11)
  c4 = multilinear3(nsmds.func,q2,q2,q2,x,p,n,ten3Increment);			%  C(q2,q2,q2)
  c4 = p2'*(c4 + 3.0*multilinear2(nsmds.func,q2,h0200,x,p,n,hessIncrement))/6.0;%+3B(q2,h02)
  A1 = nsmjacp(x,p,n);   							%jacobianp
  s1=[1;0];s2=[0;1];								%define standard vectors
  gamma1 = p1'*A1*s1;gamma2 = p1'*A1*s2;					%define new basis
  s1 = [ gamma1;gamma2]/(gamma1^2 + gamma2^2);
  s2 = [-gamma2;gamma1];
  hh1 = Bord\[ q1-A1*s1;0];hh1 = hh1(1:nphase);					%hh0010
  hh2 = Bord\[   -A1*s2;0];hh2 = hh2(1:nphase);					%hh0001
  xx1=x;
  xit=zeros(nphase,n);xit(:,1)=x;
  AA=zeros(nphase,nphase,n);
  AA(:,:,1)=nsmjac(x,p,1);
  for m=2:n
     xx1=feval(nsmds.func,0,xx1,p{:});
     xit(:,m)=xx1;
     AA(:,:,m)=nsmjac(xx1,p,1);
  end   
  test1 = nshesspvect(xit,p,q1,AA,n)*s1;						%A1(q1,s1)
  test1 = test1 + multilinear2(nsmds.func,q1,hh1,x,p,n,hessIncrement);		%+B(q1,hh1)
  test2 = nshesspvect(xit,p,q1,AA,n)*s2;						%A1(q1,s2)
  test2 = test2 + multilinear2(nsmds.func,q1,hh2,x,p,n,hessIncrement);		%+B(q1,hh2)
  test3 = nshesspvect(xit,p,q2,AA,n)*s1;						%A1(q2,s1)
  test3 = test3 + multilinear2(nsmds.func,q2,hh1,x,p,n,hessIncrement);		%+B(q2,hh1)
  test4 = nshesspvect(xit,p,q2,AA,n)*s2;						%A1(q2,s2)
  test4 = test4 + multilinear2(nsmds.func,q2,hh2,x,p,n,hessIncrement);		%+B(q2,hh2)
  L = [p1'*test2 2*a1 ; p2'*test4 1];
  cst1 = -L\[p1'*test1 ; p2'*test3 ];
  cst2 = L\[1; 0];
  v10 = s1 + cst1(1)*s2;v01 = cst2(1)*s2;
  dir = [v10 v01]*[-b1; -(2*b1+c2-2*(a1+1)*c4)];				% parameter direction
  x0 =[x + sqrt(eps)*q2 - eps*c4*q1; nsmds.P0(ap) + eps*dir];			% predicted point
  clear T1global T2global T3global
%-----End of branch prediction-----------------
[x1,p] = rearr(x0); p = n2c(p);
curvehandles = feval(cds.curve);
cds.curve_func = curvehandles{1};
cds.curve_options = curvehandles{3};
cds.curve_jacobian =curvehandles{4};
cds.curve_hessians = curvehandles{5};
cds.options = feval(cds.curve_options); 
cds.options = contset(cds.options,'Increment',1e-5);
n = 2*n;
jac = nsmjac(x1,p,n);
nphase = size(x1,1);
nap = length(nsmds.ActiveParams);
% calculate eigenvalues and eigenvectors
[V,D] = eig(jac);
% find pair of complex eigenvalues
d = diag(D);
idx1=0;idx2=0;
for s=1:nphase
  for j=s+1:nphase
    if (abs(1-d(s)*d(j))<0.001)
      idx1=s;
      idx2=j;
    end
  end
end
if idx1==0
   
  printconsole('Neutral saddle\n'); 
  global initmsg;
  initmsg='Neutral saddle';
  x0 = [];
  return;
end
endV=V(:,idx1);
[Q,R,E] = qr([real(V(:,idx1)) imag(V(:,idx1))]);
nsmds.borders.v = Q(:,1:2);
[V,D] = eig(jac');
% find pair of complex eigenvalues
d = diag(D);
idx1=0;idx2=0;
for s=1:nphase
  for j=s+1:nphase
    if (abs(1-d(s)*d(j))<0.001)
      idx1=s; 
      idx2=j;
    end
  end
end
if idx1==0
  printconsole('Neutral saddle\n'); 
  global initmsg;
  initmsg='Neutral saddle';
    x0 = [];
  return;
end
temp=idx1;
if d(idx1)<0
    idx1=idx2;
    idx2=temp;
end    
[Q,R,E] = qr([real(V(:,idx1)) imag(V(:,idx1))]);
nsmds.borders.w = Q(:,1:2);
k  = real(d(idx1));
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
wext1=wext(1:nsmds.nphase,1)'*jac;
vext1=vext(1:nsmds.nphase,1);
AA=zeros(nphase,nphase,n);
xit=zeros(nphase,n);xit(:,1)=x1;
AA(:,:,1)=nsmjac(x1,p,1);
for m=2:n
   xx1=feval(nsmds.func,0,xx1,p{:});
   xit(:,m)=xx1;
   AA(:,:,m)=nsmjac(xx1,p,1);
end

gx1=nsvecthessvect(xit,p,vext1,wext1,AA,n);

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
%
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

wext33=-2.0*k*wext(1:nsmds.nphase,1)';
vext33=vext(1:nsmds.nphase,2);
gx32=nsvecthesspvect(xit,p,vext33,wext33,AA,n);
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



