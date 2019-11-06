function h=HetT_hess(x,p,J)
global hetTds cds

if (cds.options.SymDerivative >= 2)&&(J==1)
  h = feval(hetTds.Hessians, 0, x, p{:});
else
  for i=1:hetTds.nphase
    x1 = x; x1(i) = x1(i)-cds.options.Increment;
    x2 = x; x2(i) = x2(i)+cds.options.Increment;
    h(:,:,i) = hetT_jac(x2,p,J)-hetT_jac(x1,p,J);
  end
  h = h/(2*cds.options.Increment);
end

