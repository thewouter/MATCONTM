function H = conthess(x)
% Compute numerically hessian matrices of F(x)
%
% hess is a multidimensional matrix: hess(i,j,k) = d^2 F_i / dx_j dx_k

global cds 
ndim      = cds.ndim;
Increment = cds.options.Increment;

if nargin ~= 1 
  error('conthess needs a point');
end
try
    symhess  = cds.symhess;
catch symhess = 0; end
if symhess
    H = feval(cds.curve_hessians, x);
else
    for i=1:cds.ndim
        x1 = x; x1(i) = x1(i)-cds.options.Increment;
        x2 = x; x2(i) = x2(i)+cds.options.Increment;
        H(:,:,i) = contjac(x2)-contjac(x1);
    end
    H = H/(2*cds.options.Increment); 
end
  
 
%SD:calculates hessians

%SD:calculates hessians
