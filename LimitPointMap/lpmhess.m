function h=lpmhess(x,p)
global lpmds cds
  if (cds.options.SymDerivative >=2)
    h = feval(lpmds.Hessians, 0, x, p{:});
else
  for i=1:lpmds.nphase
    x1 = x; x1(i) = x1(i)-cds.options.Increment;
    x2 = x; x2(i) = x2(i)+cds.options.Increment; 
    h(:,:,i) = lpmjac(x2,p,1)-lpmjac(x1,p,1);
  end
 h = h/(2*cds.options.Increment);
 end


