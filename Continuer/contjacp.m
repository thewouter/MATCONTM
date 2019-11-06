function jacp = contjacp(x)
%
%  contjacp(x)
%
%    Calculates numerical jacobian matrix of F(x), only with respect to active parameters

global cds

if nargin ~= 1 
  error('contjacp needs a point');
end

x1 = x;
x2 = x;

nact = length(cds.options.ActiveParams);
ncoo = cds.ndim - nact;

jacp = ones(cds.ndim-1,nact)*NaN;

for j=ncoo+1:ncoo+nact  %cols
  x1(j) = x(j) - cds.options.Increment;
  x2(j) = x(j) + cds.options.Increment;

  Fx1 = feval(cds.curve_func, x1);
  Fx2 = feval(cds.curve_func, x2);
      
  jacp(:,j-ncoo) = (Fx2-Fx1)/(2*cds.options.Increment);

  x1(j) = x(j);
  x2(j) = x(j);
end

%SD:calculates num jac wrt p_act
