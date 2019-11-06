function h=mhess(x,p)
global fpmds cds
   if (cds.options.SymDerivative >=2)
       h = feval(fpmds.Hessians, 0, x, p{:});  
   else
      for i=1:(cds.ndim-1)
        x1 = x; x1(i) = x1(i)-cds.options.Increment; 
        x2 = x; x2(i) = x2(i)+cds.options.Increment;
        h(:,:,i) = mjac(x2,p,1)-mjac(x1,p,1); 
      end
      h = h/(2*cds.options.Increment);
   end
  
  
