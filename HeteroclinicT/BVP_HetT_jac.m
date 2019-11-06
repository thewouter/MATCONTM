function result = BVP_HetT_jac(x,YS,YU,p)
% Jacobian of boundary value problem
%
% ============================================
global hetTds
J=hetTds.niteration;
n=hetTds.nphase;N=hetTds.npoints;
nu=hetTds.nu;ns=hetTds.ns;
ups = reshape(x,n,N);
x1=ups(:,1); xN=ups(:,N);
% p = num2cell(p);
% Allocate space for sparse jacobian
ks=n*N+(n-nu)*nu+(n-ns)*ns;
result = spalloc(ks,ks,floor(ks/2));

% Component 1 (the initial fixed point)
% ===========
A1=hetT_jac(x1,p,J);
result(1:n, 1:n) = A1-eye(n);
% %Derivatives w.r.t active parameter
%jp=hetT_jacp(x1,p,J);
%result(1:n, ks+[1:2]) = jp;

% Component 2 (the iteration conditions)
% ===========
for j=3:N-1
  result((j-2)*n+1:(j-1)*n, (j-2)*n+1:(j-1)*n)=hetT_jac(ups(:,j-1),p,J);
  result((j-2)*n+1:(j-1)*n, (j-1)*n+1:j*n)=-eye(n);
end

% %Derivatives w.r.t active parameter
%for j=3:N-1
%  jp=hetT_jacp(ups(:,j-1),p,J);
%  result((j-2)*n+1:(j-1)*n, ks+[1:2])=jp;
%end

% Component 3 (the final fixed point)
% ===========
AN=hetT_jac(xN,p,J);
result((N-2)*n+1:(N-1)*n,(N-1)*n+1:N*n) = AN-eye(n);
% %Derivatives w.r.t active parameter
%jp=hetT_jacp(xN,p,J);
%result((N-2)*n+1:(N-1)*n, ks+[1:2]) =jp;

% Component 4 % UNSTABLE
% Ricatti blocks from unstable eigenspace
% F(Y_U)=R22Y_U-Y_UR11+E21-Y_UR12Y_U;
% ===========
Q0U = hetTds.Q0;
[R11, R12, E21, R22] = HetT_RicattiCoeff(Q0U,A1,nu);

l=n*(N-1);h=n*N;DD=zeros(n-nu,nu);
for i=1:n-nu
  for j=1:nu
    DD=0*DD;DD(i,j)=1;
    idx1=h+(j-1)*(n-nu)+i;
    result(l+1:l+(n-nu)*nu,idx1)=reshape(R22*DD-DD*R11-YU*R12*DD-DD*R12*YU,(n-nu)*nu,1);
  end
end

% derivatives of F(YU) w.r.t.  x1 
hess=HetT_hess(x1,p,J);
l=n*(N-1);
for i=1:n
  D=Q0U'*hess(:,:,i)*Q0U;
  D1=D(1:nu,1:nu);
  D2=D(1:nu,nu+1:n);
  D3=D(nu+1:n,1:nu);
  D4=D(nu+1:n,nu+1:n);
  for j=1:n-nu
    for s=1:nu;
      idx=l+s+(j-1)*nu;
      result(idx,i)=result(idx,i)+D4(j,:)*YU(:,s)-YU(j,:)*D1(:,s)+D3(j,s);
      for k=1:nu
        result(idx,i)=result(idx,i)-YU(j,k)*(D2(k,:)*YU(:,s));
      end
    end           
  end
end

% % derivatives of F(Y_U) w.r.t.  the active parameter 
% hessp=HetT_hessp(x1,p,J);
% l=n*(N-1); Q0=hetTds.Q0;
% D=Q0'*hessp*Q0;
% D1=D(1:nu,1:nu);
% D2=D(1:nu,1:nu+1:n);
% D3=D(nu+1:n,1:nu);
% D4=D(nu+1:n,nu+1:n);
% for j=1:n-nu
%   for s=1:nu;
%     idx=l+s+(j-1)*nu;
%     result(idx,ks+[1:2])=result(idx,ks+[1:2])+D4(j,:)*YU(:,s)-YU(j,:)*D1(:,s)+D3(j,s);
%     for k=1:nu
%       result(idx,ks+[1:2])=result(idx,ks+[1:2])-YU(j,k)*(D2(k,:)*YU(:,s));           
%     end           
%   end
% end

% Component 5 % STABLE
% Ricatti blocks from stable eigenspace
% F(Y_S)=R22Y_S-Y_SR11+E21-YR12Y_S;
% =========
Q1S = hetTds.Q1;
[R11, R12, E21, R22] = HetT_RicattiCoeff(Q1S,AN,ns);

l=n*(N-1)+(n-nu)*nu; h=N*n+(n-nu)*nu;DD=zeros(n-ns,ns);
for i=1:n-ns
  for j=1:ns
    DD=0*DD;DD(i,j)=1;
    idx1=h+(j-1)*(n-ns)+i;
    result(l+1:l+(n-ns)*ns,idx1)=reshape(R22*DD-DD*R11-YS*R12*DD-DD*R12*YS,(n-ns)*ns,1);
  end
end

% derivatives of F(Y_S) w.r.t. xN
hess=HetT_hess(xN,p,J);
l=n*(N-1)+(n-nu)*nu;h=n*(N-1);
for i=1:n
  D=Q1S'*hess(:,:,i)*Q1S;
  D1=D(1:ns,1:ns);
  D2=D(1:ns,1:ns+1:n);
  D3=D(ns+1:n,1:ns);
  D4=D(ns+1:n,ns+1:n);
  for j=1:n-ns
    for s=1:ns;
      idx=l+s+(j-1)*ns;
      result(idx,h+i)=result(idx,h+i)+D4(j,:)*YS(:,s)-YS(j,:)*D1(:,s)+D3(j,s);
      for k=1:ns
        result(idx,h+i)=result(idx,h+i)-YS(j,k)*(D2(k,:)*YS(:,s));
      end
    end           
  end
end


% Derivatives of F(Y_S) w.r.t. the active parameter
% hessp=HetT_hessp(xN,p,J); 
% l=n*(N-1)+nu*(n-nu);
% Q1=hetTds.Q1;
% D=Q1'*hessp*Q1;
% D1=D(1:ns,1:ns);
% D2=D(1:ns,1:ns+1:n);
% D3=D(ns+1:n,1:ns);
% D4=D(ns+1:n,ns+1:n);
% for j=1:n-ns
%   for s=1:ns;
%     idx=l+s+(j-1)*ns;
%     result(idx,ks+1)=D4(j,:)*YS(:,s)-YS(j,:)*D1(:,s)+D3(j,s);
%     for k=1:ns
%       result(idx,ks+1)=result(idx,ks+1)-YS(j,k)*(D2(k,:)*YS(:,s));    
%     end           
%   end
% end



% Component 6 (First vectors along unstable eigenspaces)
% ===========
% derivatives w.r.t. x1 
Q0U = hetTds.Q0;
QU =Q0U*[-YU'; eye(size(YU,1))];
l=n*(N-1)+(n-nu)*nu+(n-ns)*ns;h=n*N;
for i=1:n-nu
  result(l+i, 1:n)=-QU(:,i)';
end
    
% derivatives w.r.t. x2
for i=1:n-nu
  result(l+i, n+1:2*n)=QU(:,i)';
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

% Component  7 (Last vectors along stable eigenspaces)
% ===========
% derivatives w.r.t. xN-1
Q1S = hetTds.Q1;
QS =Q1S*[-YS'; eye(size(YS,1))];
l=n*(N-1)+(n-nu)*nu+(n-ns)*ns+ns;h=n*N+(n-nu)*nu;
for i=1:n-ns
  result(l+i, n*(N-2)+1:n*(N-1))=+QS(:,i)'; 
end
   
% derivatives w.r.t. xN    
l=n*(N-1)+(n-nu)*nu+(n-ns)*ns+ns;
for i=1:n-ns
  result(l+i, n*(N-1)+1:N*n )=-QS(:,i)';
end
    
% derivatives w.r.t. components of YS_{(nu+i)}   
vect = ups(:,N-1) - xN;
DD=zeros(n-ns,ns);
for i=1:n-ns
  for j=1:ns
    DD=0*DD;DD(i,j)=1;
    idx1 = h+i+(n-ns)*(j-1);
    result(l+(1:nu),idx1)=vect'*Q1S*[-DD 0*eye(size(YS,1))]';
  end
end
