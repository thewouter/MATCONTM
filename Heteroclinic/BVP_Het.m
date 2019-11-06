function f = BVP_Het(x,YS,YU,p)
global hetds 

% extract ups,  [x0,x1,...,xn]
ups = reshape(x,hetds.nphase,hetds.npoints);
p = num2cell(p);
% -----------
% Fixed point condition x0 %f^J(x0)-x0
J=hetds.niteration;
x0=ups(:,1);
xx=x0;
for i=1:J
  xx=feval(hetds.func,0,xx,p{:}); 
end 
f(1:hetds.nphase,1)=xx-x0;
% Orbit condition f^J(x(i))-x(i+1)
for i=2:hetds.npoints-2
  xx=ups(:,i);
  for k=1:J
    xx=feval(hetds.func,0,xx,p{:});
  end   
  f(end+1:end+hetds.nphase,1)=xx-ups(:,i+1);
end
% Fixed point condition x1 %f^J(xN)-xN
xN=ups(:,end);xx=xN;
for i=1:J
  xx=feval(hetds.func,0,xx,p{:}); 
end 
f(end+1:end+hetds.nphase,1)=xx-xN;

% -----------
% Ricatti equations
% Y_u output of RicattiEval is a (n-nu)*nu matrix
% Y_s output of RicattiEval is a (n-ns)*ns matrix
f(end+1:end+hetds.ns*hetds.nu,1) = Het_RicattiEval(x0,p,1,YU);
f(end+1:end+hetds.nu*hetds.ns,1) = Het_RicattiEval(xN,p,0,YS);

% -----------
% Last and first vectors along stable and unstable eigenspaces
Q0U = hetds.Q0;
Q1S = hetds.Q1;
if hetds.nu
  Q1U = Q0U * [-YU'; eye(size(YU,1))];   
  for i=1:hetds.ns    
    f(end+1,1) = (ups(:,2) - ups(:,1))' * Q1U(:,i);
  end
end
if hetds.ns
  Q1S = Q1S * [-YS'; eye(size(YS,1))];
  for i=1:hetds.nu 
    f(end+1,1) = (ups(:,end-1) - ups(:,end))' * Q1S(:,i);
  end
end