function h=HomT_hess(x,p,J)
global homTds cds

if (cds.options.SymDerivative >= 2)&&(J==1)
  h = feval(homTds.Hessians, 0, x, p{:});
else
  for i=1:homTds.nphase
    x1 = x; x1(i) = x1(i)-cds.options.Increment;
    x2 = x; x2(i) = x2(i)+cds.options.Increment;
    h(:,:,i) = homT_jac(x2,p,J)-homT_jac(x1,p,J);
  end
  h = h/(2*cds.options.Increment);
end

