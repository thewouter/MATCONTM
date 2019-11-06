function j=homjac(x,p,n)
global homds cds
nphase = homds.nphase;
j=eye(nphase);x1=x;

if (cds.options.SymDerivative >=1)
  for i=1:n      
    j = feval(homds.Jacobian, 0, x1, p{:})*j;
    x1= feval(homds.func,0,x1,p{:});
  end
else
  for i=1:nphase
    x1 = x; x1(i) = x1(i)-cds.options.Increment;
    x2 = x; x2(i) = x2(i)+cds.options.Increment;
    for m=1:n     
      x1 = feval(homds.func, 0, x1, p{:});
      x2 = feval(homds.func, 0, x2, p{:});
    end
    j(:,i) = (x2-x1)/(2*cds.options.Increment);
  end
end

