function jac=homT_jac(x,p,J)
global homTds cds
nphase = homTds.nphase;
jac=eye(nphase);x1=x;

if (cds.options.SymDerivative >=1)
  for i=1:J      
    jac = feval(homTds.Jacobian,0,x1,p{:})*jac;
    x1  = feval(homTds.func,0,x1,p{:});
  end
else
  for i=1:nphase
    x1 = x; x1(i) = x1(i)-cds.options.Increment;
    x2 = x; x2(i) = x2(i)+cds.options.Increment;
    for m=1:J    
      x1 = feval(homTds.func, 0, x1, p{:});
      x2 = feval(homTds.func, 0, x2, p{:});
    end
    jac(:,i) =(x2-x1)/(2*cds.options.Increment);
  end 
end
