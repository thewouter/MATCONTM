function h=Hom_hess(x,p,J)
global homds cds

if (cds.options.SymDerivative >= 2)&&(J==1)
  h = feval(homds.Hessians, 0, x, p{:});
else
  for i=1:homds.nphase
    x1 = x; x1(i) = x1(i)-cds.options.Increment;
    x2 = x; x2(i) = x2(i)+cds.options.Increment;
    h(:,:,i) = homjac(x2,p,J)-homjac(x1,p,J);
  end
  h = h/(2*cds.options.Increment);
end

