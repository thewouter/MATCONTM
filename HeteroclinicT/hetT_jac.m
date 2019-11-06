function jac=hetT_jac(x,p,J)
global hetTds cds
nphase = hetTds.nphase;
jac=eye(nphase);x1=x;
p=n2c(p);
if (cds.options.SymDerivative >=1)
    for i=1:J      
       jac = feval(hetTds.Jacobian, 0, x1, p{:})*jac;
       x1=feval(hetTds.func,0,x1,p{:});
   end
else
     for i=1:nphase
       x1 = x; x1(i) = x1(i)-cds.options.Increment;
       x2 = x; x2(i) = x2(i)+cds.options.Increment;
       for m=1:J    
        x1= feval(hetTds.func, 0, x1, p{:});
        x2=  feval(hetTds.func, 0, x2,p{:});
       end
        jac(:,i) =(x2-x1)/(2*cds.options.Increment);
     end
  
end
