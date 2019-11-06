function h=pdmhess(x,p)

global pdmds cds
 if (cds.options.SymDerivative >=2) 
    h = feval(pdmds.Hessians, 0, x, p{:});
 else
   for i=1:pdmds.nphase
     x1 = x; x1(i) = x1(i)-cds.options.Increment;
     x2 = x; x2(i) = x2(i)+cds.options.Increment; 
     h(:,:,i) = pdmjac(x2,p,1)-pdmjac(x1,p,1);
   end
   h = h/(2*cds.options.Increment);
 end

