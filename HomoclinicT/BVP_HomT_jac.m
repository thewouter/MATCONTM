function result = BVP_HomT_jac(x,YS,YU,p)
% Jacobian of boundary value problem
%
% ============================================
global homTds
J=homTds.Niteration;
n=homTds.nphase;N=homTds.npoints;
nu=homTds.nu;ns=homTds.ns;
ups= reshape(x,n,N);
x1 = ups(:,1); 
% p  = num2cell(p);
% Allocate space for sparse jacobian
ks=n*N+(n-nu)*nu+(n-ns)*ns;
result = spalloc(ks,ks,floor(ks/2));

% Component 1 (the initial fixed point)
% ===========
A1=homT_jac(x1,p,J);
result(1:n, 1:n) = A1-eye(n);
%Derivatives w.r.t. active parameter
% jp=homT_jacp(x1,p,J);
% result(1:n, ks+[1:2]) = jp;

% Component 2 (the iteration conditions)
% ===========
for j=3:N
  result((j-2)*n+1:(j-1)*n, (j-2)*n+1:(j-1)*n)=homT_jac(ups(:,j-1),p,J);
  result((j-2)*n+1:(j-1)*n, (j-1)*n+1:j*n)=-eye(n);
end

%Derivatives w.r.t. active parameter
% for j=3:N
%   jp=homT_jacp(ups(:,j-1),p,J);
%   result((j-2)*n+1:(j-1)*n, ks+[1:2])=jp;
% end

% Component 3 UNSTABLE
% Ricatti blocks from unstable eigenspace
% F(Y_U)=R22*Y_U-Y_U*R11+E21-Y_U*R12*Y_U;
% ===========
Q0U = homTds.Q0;
[R11, R12, E21, R22] = HomT_RicattiCoeff(Q0U,A1,nu);

l=n*(N-1);h=n*N;DD=zeros(n-nu,nu);
for i=1:n-nu
  for j=1:nu
    DD=0*DD;DD(i,j)=1;
    idx1=h+(j-1)*(n-nu)+i;
    result(l+1:l+(n-nu)*nu,idx1)=reshape(R22*DD-DD*R11-YU*R12*DD-DD*R12*YU,(n-nu)*nu,1);
  end
end

% derivatives of F(YU) w.r.t. x1 
hess=HomT_hess(x1,p,J);
l=n*(N-1); Q0=homTds.Q0;

for i=1:n
  D=Q0'*hess(:,:,i)*Q0;
  D1=D(1:nu,1:nu);
  D2=D(1:nu,nu+1:n);
  D3=D(nu+1:n,1:nu);
  D4=D(nu+1:n,nu+1:n);
  for j=1:n-nu
    for s=1:nu;
      idx=l+s+(j-1)*nu;
      result(idx,i)=D4(j,:)*YU(:,s)-YU(j,:)*D1(:,s)+D3(j,s);
      for k=1:nu
        result(idx,i)=result(idx,i)-YU(j,k)*(D2(k,:)*YU(:,s));
      end
    end
  end
end

%derivatives of F(Y_U) w.r.t. the active parameters
% hessp=HomT_hessp(x1,p,J);
% l=n*(N-1); Q0=homTds.Q0;
% for jj=1:2
%   D=Q0'*hessp(:,:,jj)*Q0;
%   D1=D(1:nu,1:nu);
%   D2=D(1:nu,1:nu+1:n);
%   D3=D(nu+1:n,1:nu);
%   D4=D(nu+1:n,nu+1:n);
%   for j=1:n-nu
%     for s=1:nu;
%       idx=l+s+(j-1)*nu;
%       result(idx,ks+jj)=D4(j,:)*YU(:,s)-YU(j,:)*D1(:,s)+D3(j,s);
%       for k=1:nu
%         result(idx,ks+jj)=result(idx,ks+jj)-YU(j,k)*(D2(k,:)*YU(:,s));          
%       end           
%     end
%   end
% end

% Component 4 STABLE
% Ricatti blocks from stable eigenspace
% F(Y_S)=R22*YS-YS*R11+E21-Y*R12*YS;
% =========
Q1S = homTds.Q1;
[R11, R12, E21, R22] = HomT_RicattiCoeff(Q1S,A1,ns);

l=n*(N-1)+(n-nu)*nu; h=N*n+(n-nu)*nu;DD=zeros(n-ns,ns);
for i=1:n-ns
  for j=1:ns
    DD=0*DD;DD(i,j)=1;
    idx1=h+(j-1)*(n-ns)+i;
    result(l+1:l+(n-ns)*ns,idx1)=reshape(R22*DD-DD*R11-YS*R12*DD-DD*R12*YS,(n-ns)*ns,1);
  end
end

% derivatives of F(Y_S) w.r.t. x1
hess=HomT_hess(x1,p,J);
Q1=homTds.Q1;
for i=1:n
  D=Q1'*hess(:,:,i)*Q1;
  D1=D(1:ns,1:ns);
  D2=D(1:ns,ns+1:n);
  D3=D(ns+1:n,1:ns);
  D4=D(ns+1:n,ns+1:n);
  for j=1:n-ns
    for s=1:ns;
      idx=l+s+(j-1)*ns;
      result(idx,i)=D4(j,:)*YS(:,s)-YS(j,:)*D1(:,s)+D3(j,s);
      for k=1:ns
        result(idx,i)=result(idx,i)-YS(j,k)*(D2(k,:)*YS(:,s));
      end
    end           
  end
end

% Derivatives of F(Y_S)=R22Y_S-Y_SR11+E21-Y_SR12Y_S w.r.t. the active parameter
% hessp=HomT_hessp(x1,p,J); 
% for jj=1:2
%   D=Q1'*hessp(:,:,jj)*Q1;
%   D1=D(1:ns,1:ns);
%   D2=D(1:ns,ns+1:n);
%   D3=D(ns+1:n,1:ns);
%   D4=D(ns+1:n,ns+1:n);
%   for j=1:n-ns
%     for s=1:ns;
%       idx=l+s+(j-1)*ns;
%       result(idx,ks+jj)=D4(j,:)*homTds.YS(:,s)-homTds.YS(j,:)*D1(:,s)+D3(j,s);
%       for k=1:ns
%         result(idx,ks+jj)=result(idx,ks+jj)-homTds.YS(j,k)*(D2(k,:)*homTds.YS(:,s));    
%       end           
%     end
%   end
% end

% Component 5 (First vector along unstable eigenspaces)
% ===========
% derivatives w.r.t. x1 
Q0U = homTds.Q0;
QU =Q0U*[-YU'; eye(size(YU,1))];
l=n*(N-1)+(n-nu)*nu+(n-ns)*ns;
for i=1:n-nu
  result(l+i,1:n)=-QU(:,i)';
end
    
% derivatives w.r.t. x2
for i=1:n-nu
  result(l+i,n+1:2*n)=QU(:,i)';
end
   
% derivatives w.r.t.  components of YU_{(nu+i)}   
vect = ups(:,2) - x1;
DD=zeros(n-nu,nu);
for i=1:n-nu
  for j=1:nu
    DD=0*DD;DD(i,j)=1;
    idx1 = h+i+(n-nu)*(j-1);
    result(l+(1:ns),idx1)=vect'*Q0U*[-DD 0*eye(size(YU,1))]';
  end
end

% Component 6 (Last vectors along stable eigenspaces)
% ===========
% derivatives w.r.t. xN
Q1S = homTds.Q1;
QS =Q1S*[-YS'; eye(size(YS,1))];
l=n*(N-1)+(n-nu)*nu+(n-ns)*ns+ns;
for i=1:n-ns
  result(l+i, n*(N-1)+1:n*N)=QS(:,i)'; 
end

% derivatives w.r.t. x1   
l=n*(N-1)+(n-nu)*nu+(n-ns)*ns+ns;
for i=1:n-ns
  result(l+i, 1:n )=-QS(:,i)'; 
end

% derivatives w.r.t. components of YS_{(nu+i)}   
vect = ups(:,N) - x1;
DD=zeros(n-ns,ns);
for i=1:n-ns
  for j=1:ns
    DD=0*DD;DD(i,j)=1;
    idx1 = h+i+(n-ns)*(j-1);
    result(l+(1:nu),idx1)=vect'*Q1S*[-DD 0*eye(size(YS,1))]';
  end
end