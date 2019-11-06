function j=cjac(mapfile,jacobian,x,p)
global cds
nphase=size(x,1);
 if (cds.options.SymDerivative >=1) 
     j = feval(jacobian, 0, x, p{:});
 else
  for i=1: nphase
    x1 = x; x1(i) = x1(i)-cds.options.Increment;
    x2 = x; x2(i) = x2(i)+cds.options.Increment;
    j(:,i) = feval(mapfile, 0, x2, p{:})-feval(mapfile, 0, x1,  p{:});
  end
  j = j/(2*cds.options.Increment);
end
