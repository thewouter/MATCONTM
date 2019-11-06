function f = BVP_HomT(x,YS,YU,p)
global homTds 

% extract ups,  [x0,x1,...,xn]
ups = reshape(x,homTds.nphase,homTds.npoints);

% -----------
% Fixed point condition f^i(x0)-x0
J=homTds.Niterations;
x0=ups(:,1);
xx=x0;
for i=1:J
  xx=feval(homTds.func,0,xx,p{:}); 
end 
f(1:homTds.nphase,1)=xx-x0; 
% -----------
% Orbit condition f^i(xi)-xi+1
for i=2:homTds.npoints-1
  xx=ups(:,i);
  for k=1:J
    xx=feval(homTds.func,0,xx,p{:});
  end    
  f(end+1:end+homTds.nphase,1)=xx-ups(:,i+1);
end

% -----------
% Ricatti equations
f(end+1:end+homTds.ns*homTds.nu,1) = HomT_RicattiEval(x0,p,1,YU);
f(end+1:end+homTds.nu*homTds.ns,1) = HomT_RicattiEval(x0,p,0,YS);

% -----------
% Last and first vectors along stable and unstable eigenspaces
Q0U = homTds.Q0;
Q1S = homTds.Q1;

if homTds.nu
  Q1U = Q0U * [-YU'; eye(size(YU,1))];
  for i=1:homTds.ns      
    f(end+1,1) = (ups(:,2) - ups(:,1))' * Q1U(:,i);
  end
end

if homTds.ns
  Q1S = Q1S * [-YS'; eye(size(YS,1))];
  for i=1:homTds.nu
    f(end+1,1) = (ups(:,end) - ups(:,1))' * Q1S(:,i);
  end
end
