function f = BVP_Hom(x,YS,YU,p)
global homds 

% extract ups,  [x0,x1,...,xn]

ups = reshape(x,homds.nphase,homds.npoints);
p = num2cell(p);

% -----------
% Fixed point condition f^J(x0)-x0
J=homds.niteration;
x0=ups(:,1);
xx=x0;
for i=1:J
  xx=feval(homds.func,0,xx,p{:});
end 
f(1:homds.nphase,1)=xx-x0; 
% -----------
% Orbit condition f^J(xi)-xi+1
for i=2:homds.npoints-1
  xx=ups(:,i);
  for k=1:J
    xx=feval(homds.func,0,xx,p{:});
  end    
  f(end+1:end+homds.nphase,1)=xx-ups(:,i+1);
end

% -----------
% Ricatti equations
f(end+1:end+homds.ns*homds.nu,1) = Hom_RicattiEval(x0,p,1,YU);
f(end+1:end+homds.nu*homds.ns,1) = Hom_RicattiEval(x0,p,0,YS);

% -----------
% Last and first vectors along stable and unstable eigenspaces
% boundary projections
Q0U = homds.Q0;
Q1S = homds.Q1;

if homds.nu
  Q1U = Q0U * [-YU'; eye(size(YU,1))];
  for i=1:homds.ns      
    f(end+1,1) = (ups(:,2) - ups(:,1))' * Q1U(:,i);
  end
end

if homds.ns
  Q1S = Q1S * [-YS'; eye(size(YS,1))];
  for i=1:homds.nu
    f(end+1,1) = (ups(:,end) - ups(:,1))' * Q1S(:,i);
  end
end