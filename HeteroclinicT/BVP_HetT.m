function f = BVP_HetT(x,YS,YU,p)
global hetTds 

% extract ups,  [x0,x1,...,xn]

ups = reshape(x,hetTds.nphase,hetTds.npoints);
p = num2cell(p);

% -----------
% Fixed points conditions
J=hetTds.Niterations;
x0=ups(:,1);
xx=x0;
for i=1:J
xx=feval(hetTds.func,0,xx,p{:}); %f^i(x0)-x0
end 
f(1:hetTds.nphase,1)=xx-x0;
for i=2:hetTds.npoints-2
  xx=ups(:,i);
  for k=1:J
    xx=feval(hetTds.func,0,xx,p{:});
  end    
  f(end+1:end+hetTds.nphase,1)=xx-ups(:,i+1);%f^i(xi)-xi+1
end
x1=ups(:,end);xx=x1;
for i=1:J
  xx=feval(hetTds.func,0,xx,p{:}); 
end 
f(end+1:end+hetTds.nphase,1)=xx-x1;%f^i(x1)-x1

% -----------
% Ricatti equations
f(end+1:end+hetTds.ns*hetTds.nu,1) = HetT_RicattiEval(x0,p,1,YU);
%Y_u output of RicattiEval is a (n-nu)*nu matrix
f(end+1:end+hetTds.nu*hetTds.ns,1) = HetT_RicattiEval(x1,p,0,YS);
%Y_s output of RicattiEval is a (n-ns)*ns matrix

% -----------
% Last and first vectors along stable and unstable eigenspaces
Q0U = hetTds.Q0;
Q1S = hetTds.Q1;
if hetTds.nu
    Q1U = Q0U * [-YU'; eye(size(YU,1))];   
    for i=1:hetTds.nphase-hetTds.nu               
        f(end+1,1) = (ups(:,2) - ups(:,1))' * Q1U(:,i);
    end
end
if hetTds.ns
    Q1S = Q1S * [-YS'; eye(size(YS,1))];
    for i=1:hetTds.nphase-hetTds.ns
        f(end+1,1) = (ups(:,end-1) - ups(:,end))' * Q1S(:,i);
    end
end
