function jac = contjac(x)
%
%  jacobian(x)
%
%  Calculates jacobian matrix of F(x), which is to be found
%  in curve file, which is global 
global cds

if nargin ~= 1 
  error('contjac needs a point');
end
if ~isempty(cds.pJacX)
  if x == cds.pJacX
    jac = cds.pJac;
    return;
  end
end
try
    symjac  = cds.symjac;
catch
  symjac=0;
end
if symjac
%if cds.options.SymDerivative >=1
  jac =  feval(cds.curve_jacobian, x);
else
  jac = nan(cds.ndim-1,cds.ndim);
  for j=1:cds.ndim
    x1=x;x1(j) = x(j) - cds.options.Increment;
    x2=x;x2(j) = x(j) + cds.options.Increment;
    jac(:,j) = feval(cds.curve_func, x2)-feval(cds.curve_func, x1);
  end
  jac = jac/(2*cds.options.Increment);
end
cds.pJac = jac;
cds.pJacX = x;
